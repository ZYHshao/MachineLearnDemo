//
//  DeppModelViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/25.
//

import UIKit
import CoreML

class DeppModelViewController: UIViewController {
    
    let image = UIImage(named: "deep2")!
    lazy var imageView: UIImageView = {
        let v = UIImageView()
        v.image = image
        return v
    }()
    
    lazy var imageView2: UIImageView = {
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
        
        imageView2.frame = CGRect(x: 0, y: 100 + imageView.frame.height, width: view.frame.width, height: view.frame.width / scale)
        view.addSubview(imageView2)
        
        let model = try! FCRN(configuration: MLModelConfiguration())
        let input = try! FCRNInput(imageWith: image.cgImage!)
        let output = try! model.prediction(input: input)
        handleOutPut(outPut: output)
    }
    

    func handleOutPut(outPut: FCRNOutput) {
        let width = imageView2.frame.width / 160
        let height = imageView2.frame.height / 128
        for line in 0 ..< 128 {
            for column in 0 ..< 160 {
                let black = outPut.depthmap[[NSNumber(integerLiteral: 0), NSNumber(integerLiteral: line), NSNumber(integerLiteral: column)]].doubleValue
                let v = UIView()
                v.frame = CGRect(x: CGFloat(column) * width, y: CGFloat(line) * height, width: width, height: height)
                v.backgroundColor = UIColor(red: black / 2, green: black / 2, blue: black / 2, alpha: 1)
                imageView2.addSubview(v)
            }
        }
    }
}
