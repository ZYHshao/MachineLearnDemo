//
//  DetecingHorizonViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/22.
//

import UIKit
import Vision

class DetecingHorizonViewController: UIViewController {

    // 要分析的图片资源
    let image = UIImage(named: "image7")!
    lazy var imageView = UIImageView(image: image)
    
    // 绘制的矩形区域
    var boxViews: [UIView] = []
    
    // 图像分析请求
    lazy var imageRequestHandler = VNImageRequestHandler(cgImage: image.cgImage!,
                                                    orientation: .up,
                                                    options: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let scale = image.size.width / image.size.height
       
        let width = self.view.frame.size.width
        imageView.frame = CGRect(x: 0, y: 100, width: width, height: width / scale)
        view.addSubview(imageView)
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.imageRequestHandler.perform([self.horizonDetectionRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }


    
    private lazy var horizonDetectionRequest: VNDetectHorizonRequest = {
        let horizonDetectionRequest = VNDetectHorizonRequest { request, error in
            DispatchQueue.main.async {
                self.drawTask(request: request as! VNDetectHorizonRequest)
            }
        }
        return horizonDetectionRequest
    }()
    
    private func drawTask(request: VNDetectHorizonRequest) {
        boxViews.forEach { v in
            v.removeFromSuperview()
        }
        for result in request.results ?? [] {
            print("angle:", result.angle)
            let v = UIView()
            v.backgroundColor = .clear
            v.layer.borderColor = UIColor.red.cgColor
            v.layer.borderWidth = 2
            imageView.addSubview(v)
            let size = imageView.frame.size
            v.frame = CGRect(x: 0, y: 200, width: size.width, height: 3)
            v.transform = v.transform.rotated(by: result.angle)

        }
    }
}
