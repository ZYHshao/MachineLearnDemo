//
//  MNISTViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/9.
//

import UIKit
import CoreML

class MNISTViewController: UIViewController {
    
    let image = UIImage(named: "3")!
    
    lazy var imageView: UIImageView = {
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
        
        let model = try? MNISTClassifier(configuration: MLModelConfiguration())
        let input = try! MNISTClassifierInput(imageWith: image.cgImage!)
        
        let outPut = try? model?.prediction(input: input)
        
        let label = UILabel(frame: CGRect(x: 0, y: imageView.frame.origin.y + imageView.frame.height, width: view.frame.width, height: 400))
        label.numberOfLines = 0
        view.addSubview(label)
        
        label.text = "最优结果：\(outPut?.classLabel)\n其他可能：\n"
        for item in outPut?.labelProbabilities ?? [:] {
            label.text = label.text?.appendingFormat("%d:%.2f\n", item.key, item.value)
        }
    }

}
