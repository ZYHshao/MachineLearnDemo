//
//  DetectingContoursViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/21.
//

import UIKit
import Vision

class DetectingContoursViewController: UIViewController {

    // 要分析的图片资源
    let image = UIImage(named: "image5")!
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
                try self.imageRequestHandler.perform([self.contoursDetectionRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }


    
    private lazy var contoursDetectionRequest: VNDetectContoursRequest = {
        let contoursDetectRequest = VNDetectContoursRequest { request, error in
            DispatchQueue.main.async {
                self.drawTask(request: request as! VNDetectContoursRequest)
            }
        }
        return contoursDetectRequest
    }()
    
    private func drawTask(request: VNDetectContoursRequest) {
        boxViews.forEach { v in
            v.removeFromSuperview()
        }
        for result in request.results ?? [] {
//            let oriPath = result.normalizedPath
//            var transform = CGAffineTransform.identity.scaledBy(x: imageView.frame.width, y: -imageView.frame.height).translatedBy(x: 0, y: -1)
//            let layer = CAShapeLayer()
//            let path = oriPath.copy(using: &transform)
//            layer.bounds = self.imageView.bounds
//            layer.anchorPoint = CGPoint(x: 0, y: 0)
//            imageView.layer.addSublayer(layer)
//            layer.path = path
//            layer.strokeColor = UIColor.blue.cgColor
//            layer.backgroundColor = UIColor.white.cgColor
//            layer.fillColor = UIColor.gray.cgColor
//            layer.lineWidth = 1

            for i in 0 ..< result.contourCount {
                let contour = try! result.contour(at: i)
                var transform = CGAffineTransform.identity.scaledBy(x: imageView.frame.width, y: -imageView.frame.height).translatedBy(x: 0, y: -1)
                let layer = CAShapeLayer()
                let path = contour.normalizedPath.copy(using: &transform)
                layer.bounds = self.imageView.bounds
                layer.anchorPoint = CGPoint(x: 0, y: 0)
                imageView.layer.addSublayer(layer)
                layer.path = path
                layer.strokeColor = UIColor.blue.cgColor
                layer.backgroundColor = UIColor.clear.cgColor
                layer.fillColor = UIColor.clear.cgColor
                layer.lineWidth = 1
            }
        }
    }
    
}
