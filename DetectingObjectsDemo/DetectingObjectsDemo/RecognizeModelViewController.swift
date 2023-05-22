//
//  RecognizeModelViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/22.
//

import UIKit
import CoreML
import Vision

class RecognizeModelViewController: UIViewController {

    let url = URL(fileURLWithPath: Bundle.main.path(forResource: "YOLOv3Tiny", ofType: "mlmodelc")!)
    lazy var visionModel = try! VNCoreMLModel(for: MLModel(contentsOf: url))
    
    let image = UIImage(named: "m1")!
    
    // 图像分析请求处理类
    lazy var imageRequestHandler = VNImageRequestHandler(cgImage: image.cgImage!,
                                                    orientation: .up,
                                                    options: [:])
    
    lazy var imageView: UIImageView = {
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
        
        let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
            DispatchQueue.main.async(execute: {
                // perform all the UI updates on the main queue
                if let results = request.results {
                    self.handleOutPut(outPut: results as! [VNRecognizedObjectObservation])
                }
            })
        })
        
        try? imageRequestHandler.perform([objectRecognition])
        
    }
    
    func handleOutPut(outPut: [VNRecognizedObjectObservation]) {
        for objectObservation in outPut {
            let topLabelObservation = objectObservation.labels[0]
            var box = objectObservation.boundingBox
            box.origin.y = 1 - box.origin.y - box.size.height
            let size = imageView.frame.size
            let v = UIView()
            v.frame = CGRect(x: box.origin.x * size.width, y: box.origin.y * size.height, width: box.size.width * size.width, height: box.size.height * size.height)
            v.backgroundColor = .clear
            v.layer.borderColor = UIColor.red.cgColor
            v.layer.borderWidth = 2
            imageView.addSubview(v)
            
            let label = UILabel()
            label.font = .boldSystemFont(ofSize: 18)
            label.text = "\(topLabelObservation.identifier):" + String(format: "%0.2f", topLabelObservation.confidence)
            label.frame = CGRect(x: v.frame.origin.x, y: v.frame.origin.y - 18, width: 200, height: 18)
            label.textColor = .red
            imageView.addSubview(label)
        }
    }
    
}
