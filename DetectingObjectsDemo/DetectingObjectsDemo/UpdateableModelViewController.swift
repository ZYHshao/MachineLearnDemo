//
//  UpdateableModelViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/9.
//

import UIKit
import CoreML

extension UpdatableDrawingClassifier {
    /// Returns the image constraint for the model's "drawing" input feature.
    var imageConstraint: MLImageConstraint {
        let description = model.modelDescription
        
        let inputName = "drawing"
        let imageInputDescription = description.inputDescriptionsByName[inputName]!
        
        return imageInputDescription.imageConstraint!
    }
}

class UpdateableModelViewController: UIViewController {
    var updatedDrawingClassifier: UpdatableDrawingClassifier?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let classifier = try! UpdatableDrawingClassifier(configuration: MLModelConfiguration())
        
        // 未更新前的模型进行测试
        let output = try! classifier.prediction(input: UpdatableDrawingClassifierInput(drawingWith: UIImage(named: "3")!.cgImage!))
        print("未更新前的预测：'\(output.label)'")
        
        let defaultModelURL = UpdatableDrawingClassifier.urlOfModelInThisBundle
        
        
        func updateModelCompletionHandler(updateContext: MLUpdateContext) {
            // Save the updated model to the file system.
            saveUpdatedModel(updateContext)
            
            // Begin using the saved updated model.
            loadUpdatedModel()
            
            print("更新完成")
            
            // 重新预测
            let newClassifier = try? UpdatableDrawingClassifier(contentsOf: updatedModelURL)
            let output = try! newClassifier?.prediction(input: UpdatableDrawingClassifierInput(drawingWith: UIImage(named: "3")!.cgImage!))
            print("更新后的预测：'\(output?.label)'")
        }
        let outputValue = MLFeatureValue(string: "数字3")
        let inputName = "drawing"
        let outputName = "label"
        

        
        let imageFeatureValue = try! MLFeatureValue(cgImage: UIImage(named: "3")!.cgImage!,
                                                    constraint: classifier.imageConstraint)
        let dataPointFeatures: [String: MLFeatureValue] = [inputName: imageFeatureValue,
                                                           outputName: outputValue]
        
        let provider = try! MLDictionaryFeatureProvider(dictionary: dataPointFeatures)
        
        var featureProviders = [MLFeatureProvider]()
        featureProviders.append(provider)
        // Create an Update Task.
        let updateTask = try? MLUpdateTask(forModelAt: defaultModelURL,
                                           trainingData: MLArrayBatchProvider(array: featureProviders),
                                           configuration: nil,
                                           completionHandler: updateModelCompletionHandler)
          
        updateTask!.resume()
    }
    
    let appDirectory = FileManager.default.urls(for: .applicationSupportDirectory,
                                                               in: .userDomainMask).first!
    lazy var tempUpdatedModelURL = appDirectory.appendingPathComponent("personalized_tmp.mlmodelc")
    lazy var updatedModelURL = appDirectory.appendingPathComponent("personalized.mlmodelc")
    
    func loadUpdatedModel() {
        guard FileManager.default.fileExists(atPath: updatedModelURL.path) else {
            // The updated model is not present at its designated path.
            return
        }
        
        // Create an instance of the updated model.
        guard let model = try? UpdatableDrawingClassifier(contentsOf: updatedModelURL) else {
            return
        }
        
        // Use this updated model to make predictions in the future.
        updatedDrawingClassifier = model
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
