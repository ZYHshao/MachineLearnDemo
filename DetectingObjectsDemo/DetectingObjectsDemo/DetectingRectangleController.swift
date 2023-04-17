//
//  ViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/13.
//

import UIKit
import Vision

class DetectingRectangleController: UIViewController {
    
    let image = UIImage(named: "image")!
    lazy var imageView = UIImageView(image: image)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let scale = image.size.width / image.size.height
       
        let width = self.view.frame.size.width
        imageView.frame = CGRect(x: 0, y: 100, width: width, height: width / scale)
        view.addSubview(imageView)
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.imageRequestHandler.perform([self.rectangleDetectionRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }

    var boxViews: [UIView] = []

    lazy var imageRequestHandler = VNImageRequestHandler(cgImage: image.cgImage!,
                                                    orientation: .up,
                                                    options: [:])
    
    private lazy var rectangleDetectionRequest: VNDetectRectanglesRequest = {
        let rectDetectRequest = VNDetectRectanglesRequest { request, error in
            DispatchQueue.main.async {
                self.drawTask(request: request as! VNDetectRectanglesRequest)
            }
        }
        // 自定义一些配置项
        rectDetectRequest.maximumObservations = 0
        rectDetectRequest.minimumConfidence = 0
        rectDetectRequest.minimumAspectRatio = 0.1
        return rectDetectRequest
    }()
    
    private func drawTask(request: VNDetectRectanglesRequest) {
        boxViews.forEach { v in
            v.removeFromSuperview()
        }
        for result in request.results ?? [] {
            var box = result.boundingBox
            // 坐标系转换
            box.origin.y = 1 - box.origin.y - box.size.height
            print("box:", result.boundingBox)
            let v = UIView()
            v.backgroundColor = .clear
            v.layer.borderColor = UIColor.black.cgColor
            v.layer.borderWidth = 1
            
            imageView.addSubview(v)
            let size = imageView.frame.size
            v.frame = CGRect(x: box.origin.x * size.width, y: box.origin.y * size.height, width: box.size.width * size.width, height: box.size.height * size.height)
        }

    }
}

