//
//  RecognizeTextViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/24.
//

import UIKit
import Vision

class RecognizeTextViewController: UIViewController {

    // 要分析的图片资源
    let image = UIImage(named: "image")!
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
                try self.imageRequestHandler.perform([self.recognizeTextRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }


    
    private lazy var recognizeTextRequest: VNRecognizeTextRequest = {
        let textDetectionRequest = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                self.drawTask(request: request as! VNRecognizeTextRequest)
            }
        }
        // 设置语言
        textDetectionRequest.recognitionLanguages = ["zh-Hans"]
        // 设置识别级别 accurate为最精准 fast为最快速
        textDetectionRequest.recognitionLevel = .accurate
        // 设置是否使用语言矫正
        textDetectionRequest.usesLanguageCorrection = true
        // 获取所支持的语言
        let set = try? textDetectionRequest.supportedRecognitionLanguages()
        print(set)
        return textDetectionRequest
    }()
    
    private func drawTask(request: VNRecognizeTextRequest) {
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
            for textObj in result.topCandidates(10) {
                textView.text = textView.text.appending(textObj.string + "\n")
                print(textObj.confidence)
            }
            textView.text = textView.text.appending("---------\n")
        }
    }
}
