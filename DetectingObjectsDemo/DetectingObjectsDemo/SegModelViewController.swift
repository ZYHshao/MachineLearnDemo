//
//  SegModelViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/24.
//

import UIKit
import CoreML

class SegModelViewController: UIViewController {


    let image = UIImage(named: "seg.jpeg")!
    lazy var imageView: UIImageView = {
        let v = UIImageView()
        v.image = image
        return v
    }()
    
    lazy var imageView2: UIImageView = {
        let v = UIImageView()
        v.image = image
        return v
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
       
        let scale = image.size.width / image.size.height
        
        imageView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.width / scale)
        view.addSubview(imageView)
        
        imageView2.frame = CGRect(x: 0, y: 100 + imageView.frame.height, width: view.frame.width, height: view.frame.width / scale)
        view.addSubview(imageView2)
        
        let model = try! DeepLabV3(configuration: MLModelConfiguration())
        let input = try! DeepLabV3Input(imageWith: image.cgImage!)
        let output = try! model.prediction(input: input)
        handleOutPut(outPut: output)
    }
    
    func handleOutPut(outPut: DeepLabV3Output) {
        let width = imageView2.frame.width / 513
        let height = imageView2.frame.height / 513
        let shape = CAShapeLayer()
        shape.frame = CGRect(x: 0, y: 0, width: imageView2.frame.width, height: imageView2.frame.height)
        shape.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        imageView2.layer.addSublayer(shape)
        var path = CGMutablePath()
        for line in 0 ..< 513 {
            for column in 0 ..< 513 {
                let black = outPut.semanticPredictions[[NSNumber(integerLiteral: line), NSNumber(integerLiteral: column)]]
                if black == 0 {
                    path.addRect(CGRect(x: CGFloat(column) * width, y: CGFloat(line) * height, width: width, height: height))
                }
            }
        }
        shape.fillColor = UIColor.black.cgColor
        shape.path = path
    }

}
