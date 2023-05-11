//
//  UpdateableModelViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/9.
//

import UIKit
import CoreML


class UpdateableModelViewController: UIViewController {
    
    let image = UIImage(named: "3")!
    
    lazy var imageView: UIImageView = {
        let v = UIImageView()
        v.image = image
        return v
    }()
    
    lazy var label: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 18)
        l.text = ""
        return l
    }()
    
    
    var updatedDrawingClassifier: UpdatableDrawingClassifier!
    var baseDrawingClassifier: UpdatableDrawingClassifier!
    
    let defaultModelURL = UpdatableDrawingClassifier.urlOfModelInThisBundle
    let appDirectory = FileManager.default.urls(for: .applicationSupportDirectory,
                                                               in: .userDomainMask).first!
    lazy var tempUpdatedModelURL = appDirectory.appendingPathComponent("personalized_tmp.mlmodelc")
    lazy var updatedModelURL = appDirectory.appendingPathComponent("personalized.mlmodelc")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let scale = image.size.width / image.size.height
        
        imageView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.width / scale)
        view.addSubview(imageView)
        
        label.frame = CGRect(x: 0, y: 100 + imageView.frame.height, width: view.frame.width, height: 200)
        view.addSubview(label)
        
        
        baseDrawingClassifier = try! UpdatableDrawingClassifier(configuration: MLModelConfiguration())
        
        // 未更新前的模型进行测试
        let output = try! baseDrawingClassifier.prediction(input: UpdatableDrawingClassifierInput(drawingWith: UIImage(named: "3")!.cgImage!))
        print("未更新前的预测：'\(output.label)'")
        
        label.text = label.text!.appending("模型未更新前的预测结果：\(output.label)\n")
        
        
        // 定义预期的预测结果
        let outputValue = MLFeatureValue(string: "手写数字3")
        // 更新的输入参数名
        let inputName = "drawing"  // 图片参数
        let labelName = "label"    // 预测结果参数
        
        // 获取模型的描述
        let description = baseDrawingClassifier.model.modelDescription
        // 获取输入参数的描述
        let imageInputDescription = description.inputDescriptionsByName[inputName]!
        // 获取图片约束字段
        let imageConstraint = imageInputDescription.imageConstraint!
        // 将图片封装成特征对象
        let imageFeatureValue = try! MLFeatureValue(cgImage: UIImage(named: "3")!.cgImage!,
                                                    constraint: imageConstraint)
        // 组合预期结果与对应的特征对象
        let dataPointFeatures: [String: MLFeatureValue] = [inputName: imageFeatureValue,
                                                           labelName: outputValue]
        // 定义特征Provider对象
        let provider = try! MLDictionaryFeatureProvider(dictionary: dataPointFeatures)
        
        // 使用一组provider创建更新任务
        let updateTask = try? MLUpdateTask(forModelAt: defaultModelURL,
                                           trainingData: MLArrayBatchProvider(array: [provider]),
                                           configuration: nil,
                                           completionHandler: updateModelCompletionHandler)
        // 执行更新任务
        updateTask!.resume()
    }
    
    func updateModelCompletionHandler(updateContext: MLUpdateContext) {
        saveUpdatedModel(updateContext)
        print("更新完成")
        
        // 重新预测
        updatedDrawingClassifier = try! UpdatableDrawingClassifier(contentsOf: updatedModelURL)
        let output = try! updatedDrawingClassifier.prediction(input: UpdatableDrawingClassifierInput(drawingWith: UIImage(named: "3")!.cgImage!))
        print("更新后的预测：'\(output.label)'")
        DispatchQueue.main.async {
            self.label.text = self.label.text!.appending("新的预测结果：\(output.label)\n")
        }
    }
    
    
    func saveUpdatedModel(_ updateContext: MLUpdateContext) {
        let updatedModel = updateContext.model
        let fileManager = FileManager.default
        
        do {
            // Create a directory for the updated model.
            try fileManager.createDirectory(at: tempUpdatedModelURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            
            // Save the updated model to temporary filename.
            try updatedModel.write(to: tempUpdatedModelURL)
            
            // Replace any previously updated model with this one.
            _ = try fileManager.replaceItemAt(updatedModelURL,
                                              withItemAt: tempUpdatedModelURL)
            
            print("Updated model saved to:\n\t\(updatedModelURL)")
        } catch let error {
            print("Could not save updated model to the file system: \(error)")
            return
        }
    }

}
