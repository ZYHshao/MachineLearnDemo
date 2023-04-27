//
//  GeneratePersonSegmentationViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/27.
//

import UIKit
import CoreImage
import Vision

class GeneratePersonSegmentationViewController: UIViewController {

    // 要分析的图片资源
    let image = UIImage(named: "image7")!
    lazy var imageView = UIImageView(image: image)


    // 图像分析请求
    lazy var imageRequestHandler = VNImageRequestHandler(ciImage: CIImage(cgImage: image.cgImage!),
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
                try self.imageRequestHandler.perform([self.personRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }


    
    private lazy var personRequest: VNGeneratePersonSegmentationRequest = {
        let request = VNGeneratePersonSegmentationRequest { request, error in
            DispatchQueue.main.async {
                self.drawTask(request: request as! VNGeneratePersonSegmentationRequest)
            }
        }
        return request
    }()
    
    private func drawTask(request: VNGeneratePersonSegmentationRequest) {

        for result in request.results ?? [] {
            print(result.pixelBuffer)
            let ciImage = CIImage(cvPixelBuffer: result.pixelBuffer)
            
            let filter = CIFilter(name: "CIMaskToAlpha", parameters: [kCIInputImageKey: ciImage])
            
            guard let outputImage = filter?.outputImage else { return }
            let context = CIContext(options: nil)
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            let uiImage = UIImage(cgImage: cgImage!)
            
            
            let v = UIImageView(image: uiImage)
            v.frame = imageView.frame
            v.backgroundColor = .blue
            v.frame.origin.y += imageView.frame.height

            v.image = uiImage
            view.addSubview(v)
            
            
            
            let v2 = UIImageView(image: image)
            v2.frame = v.frame
            v2.frame.origin.y += v.frame.height
            
            let mask =  UIImageView(image: uiImage)
            mask.frame = CGRect(x: 0, y: 0, width: v2.frame.size.width, height: v2.frame.size.height)
            mask.backgroundColor = .clear
            
            v2.mask = mask
            view.addSubview(v2)
        }
    }


}
