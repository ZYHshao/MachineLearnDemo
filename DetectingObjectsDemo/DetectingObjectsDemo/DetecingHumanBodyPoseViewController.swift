//
//  DetecingHumanBodyPoseViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/22.
//

import UIKit
import Vision

class DetecingHumanBodyPoseViewController: UIViewController {

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
                try self.imageRequestHandler.perform([self.bodyDetectionRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }


    
    private lazy var bodyDetectionRequest: VNDetectHumanBodyPoseRequest = {
        let bodyDetectionRequest = VNDetectHumanBodyPoseRequest { request, error in
            DispatchQueue.main.async {
                self.drawTask(request: request as! VNDetectHumanBodyPoseRequest)
            }
        }
        return bodyDetectionRequest
    }()
    
    private func drawTask(request: VNDetectHumanBodyPoseRequest) {
        boxViews.forEach { v in
            v.removeFromSuperview()
        }
        for result in request.results ?? [] {
            for point in result.availableJointNames {
                if let p = try? result.recognizedPoint(point) {
                    let v = UIView(frame: CGRect(x: p.x * imageView.bounds.width - 2, y: (1 - p.y) * imageView.bounds.height - 2.0, width: 4, height: 4))
                    imageView.addSubview(v)
                    v.backgroundColor = .red
                }
            }
        }
    }

}
