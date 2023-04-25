//
//  ClassifyImageViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/25.
//

import UIKit
import Vision

class ClassifyImageViewController: UIViewController {

    // 要分析的图片资源
    let image = UIImage(named: "image9")!
    lazy var imageView = UIImageView(image: image)
    lazy var textView:UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 14)
        return v
    }()
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
        textView.frame = CGRect(x: 0, y: 100 + width / scale, width: width, height: 500)
        view.addSubview(textView)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.imageRequestHandler.perform([self.classifyRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }


    
    private lazy var classifyRequest: VNClassifyImageRequest = {
        let request = VNClassifyImageRequest { r, error in
            DispatchQueue.main.async {
                self.drawTask(request: r as! VNClassifyImageRequest)
            }
        }
        print(try? request.supportedIdentifiers())
        return request
    }()
    
    private func drawTask(request: VNClassifyImageRequest) {
        boxViews.forEach { v in
            v.removeFromSuperview()
        }
        for result in request.results ?? []  where result.confidence > 0.8 {
           
            // 解析出文本
            textView.text = textView.text.appending(result.identifier + "\n")
        
        }
    }

}
