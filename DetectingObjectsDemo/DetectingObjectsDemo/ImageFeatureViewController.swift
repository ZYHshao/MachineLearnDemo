//
//  ImageFeatureViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/27.
//

import UIKit
import Vision

class ImageFeatureViewController: UIViewController {
    
    let image1 = UIImage(named: "cat1")!
    let image2 = UIImage(named: "cat2")!
    let image3 = UIImage(named: "dog1")!
    let image4 = UIImage(named: "dog2")!
    lazy var imageView1 = UIImageView(image: image1)
    lazy var imageView2 = UIImageView(image: image2)
    lazy var imageView3 = UIImageView(image: image3)
    lazy var imageView4 = UIImageView(image: image4)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(imageView1)
        view.addSubview(imageView2)
        view.addSubview(imageView3)
        view.addSubview(imageView4)
        
        let width = (self.view.frame.width - 60) / 2
        let h1 = width / (image1.size.width / image1.size.height)
        let h2 = width / (image2.size.width / image2.size.height)
        let h3 = width / (image3.size.width / image3.size.height)
        let h4 = width / (image4.size.width / image4.size.height)
        
        imageView1.frame = CGRect(x: 20, y: 100, width: width, height: h1)
        imageView2.frame = CGRect(x: width + 40, y: 100, width: width, height: h2)
        imageView3.frame = CGRect(x: 20, y: max(h1, h2) + 120, width: width, height: h3)
        imageView4.frame = CGRect(x: width + 40, y: max(h1, h2) + 120, width: width, height: h4)
        
        sendRequest(image: image1, number: 1)
        sendRequest(image: image2, number: 2)
        sendRequest(image: image3, number: 3)
        sendRequest(image: image4, number: 4)
        
                
    }
    
    func sendRequest(image: UIImage, number: Int) {
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: .up)
        let request = VNGenerateImageFeaturePrintRequest { result, error in
            guard error == nil else {
                print(error!)
                return
            }
            let r = result as! VNGenerateImageFeaturePrintRequest
            if number == 1 {
                self.result1 = r.results?.first
            }
            if number == 2 {
                self.result2 = r.results?.first
            }
            if number == 3 {
                self.result3 = r.results?.first
            }
            if number == 4 {
                self.result4 = r.results?.first
            }
            if let result1 = self.result1, let result2 = self.result2, let result3 = self.result3, let result4 = self.result4 {
                // 进行相似性对比
                var distance12 = Float(0)
                try! result1.computeDistance(&distance12, to: result2)
                var distance13 = Float(0)
                try! result1.computeDistance(&distance13, to: result3)
                var distance34 = Float(0)
                try! result3.computeDistance(&distance34, to: result4)
                print("图1与图2相似差距:", distance12)
                print("图1与图3相似差距:", distance13)
                print("图3与图4相似差距:", distance34)
                DispatchQueue.main.async {
                    let l = UILabel()
                    l.text = "图1与图2相似差距:\(distance12)\n图1与图3相似差距:\(distance13)\n图3与图4相似差距:\(distance34)"
                    l.font = .boldSystemFont(ofSize: 22)
                    self.view.addSubview(l)
                    l.frame = CGRect(x: 0, y: max(self.imageView3.frame.height, self.imageView4.frame.height) + self.imageView3.frame.origin.y, width: self.view.frame.width, height: 100)
                    l.numberOfLines = 0
                }
            }
        }
        try? handler.perform([request])
    }
    
    var result1: VNFeaturePrintObservation?
    var result2: VNFeaturePrintObservation?
    var result3: VNFeaturePrintObservation?
    var result4: VNFeaturePrintObservation?

}
