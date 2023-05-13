//
//  ClassifyModelViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/13.
//

import UIKit
import CoreML

class ClassifyModelViewController: UIViewController {
    
    
    let image = UIImage(named: "m")!
    
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
    
    // mobileNet2模型
    let mobileNet2 = try! MobileNetV2(configuration: MLModelConfiguration())
    // resent50模型
    let resnet50 = try! Resnet50(configuration: MLModelConfiguration())
    // squeezeNet 模型
    let squeezeNet = try! SqueezeNet(configuration: MLModelConfiguration())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let scale = image.size.width / image.size.height
        
        imageView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.width / scale)
        view.addSubview(imageView)
        
        label.frame = CGRect(x: 0, y: 100 + imageView.frame.height, width: view.frame.width, height: 400)
        view.addSubview(label)
        
        let mobileNet2Input = try! MobileNetV2Input(imageWith: image.cgImage!)
        let resnet50Input = try! Resnet50Input(imageWith: image.cgImage!)
        let squeezeNetInput = try! SqueezeNetInput(imageWith: image.cgImage!)
        
        // 进行图像识别
        let mobileOutput = try! mobileNet2.prediction(input: mobileNet2Input)
        let resnetOutput = try! resnet50.prediction(input: resnet50Input)
        let squeezeOutput = try! squeezeNet.prediction(input: squeezeNetInput)
        
        label.text = label.text?.appending("mobileNet2模型预测结果：\n最可能：\(mobileOutput.classLabel)\n\n")
        label.text = label.text?.appending("resnet50模型预测结果：\n最可能：\(resnetOutput.classLabel)\n\n")
        label.text = label.text?.appending("squeeze模型预测结果：\n最可能：\(squeezeOutput.classLabel)\n\n")
        
    }

}
