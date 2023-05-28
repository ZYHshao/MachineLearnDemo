//
//  CustomModelViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/28.
//

import UIKit
import CoreML

class CustomModelViewController: UIViewController {
    
    let image = UIImage(named: "mingren")!
    let image2 = UIImage(named: "zuozhu")!
    
    lazy var imageView: UIImageView = {
        let v = UIImageView()
        v.image = image
        return v
    }()
    
    lazy var imageView2: UIImageView = {
        let v = UIImageView()
        v.image = image2
        return v
    }()
    
    lazy var label: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 18)
        l.text = ""
        return l
    }()
    
    lazy var label2: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 18)
        l.text = ""
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        let width = view.frame.width / 2
        
        let scale = image.size.width / image.size.height
        
        let scale2 = image2.size.width / image2.size.height
        
        imageView.frame = CGRect(x: 0, y: 100, width: width, height: width / scale)
        view.addSubview(imageView)
        
        imageView2.frame = CGRect(x: 0, y: 100 + imageView.frame.height, width: width, height: width / scale2)
        view.addSubview(imageView2)
        
        label.frame = CGRect(x: width, y: 100, width: view.frame.width, height: 50)
        view.addSubview(label)
        
        label2.frame = CGRect(x: width, y: 100 + imageView.frame.height, width: view.frame.width, height: 50)
        view.addSubview(label2)
        
        let model = try! YHImageClassifier(configuration: MLModelConfiguration())
        let input1 = try! YHImageClassifierInput(imageWith: image.cgImage!)
        let input2 = try! YHImageClassifierInput(imageWith: image2.cgImage!)
        let output1 = try! model.prediction(input: input1)
        let output2 = try! model.prediction(input: input2)
        
        label.text = output1.classLabel
        label2.text = output2.classLabel
    }
    
}
