//
//  RecognizeAnimalsViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/24.
//

import UIKit
import Vision

class RecognizeAnimalsViewController: UIViewController {

    // 要分析的图片资源
    let image = UIImage(named: "image9")!
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
                try self.imageRequestHandler.perform([self.animalsRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }


    
    private lazy var animalsRequest: VNRecognizeAnimalsRequest = {
        let recognizeAnimalsRequest = VNRecognizeAnimalsRequest { request, error in
            DispatchQueue.main.async {
                self.drawTask(request: request as! VNRecognizeAnimalsRequest)
            }
        }
        print(try? recognizeAnimalsRequest.supportedIdentifiers())
        return recognizeAnimalsRequest
    }()
    
    private func drawTask(request: VNRecognizeAnimalsRequest) {
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
            v.layer.borderColor = UIColor.red.cgColor
            v.layer.borderWidth = 1
            
            imageView.addSubview(v)
            let size = imageView.frame.size
            v.frame = CGRect(x: box.origin.x * size.width, y: box.origin.y * size.height, width: box.size.width * size.width, height: box.size.height * size.height)
            
            
            // 解析出文本
            for item in result.labels {
                let label = UILabel()
                label.font = .boldSystemFont(ofSize: 28)
                label.text = item.identifier
                label.textColor = .blue
                imageView.addSubview(label)
                label.frame = CGRect(x: v.frame.origin.x, y: v.frame.origin.y, width: 200, height: 30)
            }
        }
    }

}
