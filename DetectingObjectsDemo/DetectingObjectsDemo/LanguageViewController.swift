//
//  LanguageViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/4.
//

import UIKit
import NaturalLanguage

class LanguageViewController: UIViewController {
    
    let recognizer = NLLanguageRecognizer()
    
    let string1 = "世界，你好！"
    let string2 = "Hello World!"
    let string3 = "こんにちは中国"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label1 = UILabel(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 100))
        recognizer.processString(string1)
        label1.text = string1 + "：\(recognizer.dominantLanguage!.rawValue)"
        
        let label2 = UILabel(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 100))
        recognizer.processString(string2)
        label2.text = string2 + "：\(recognizer.dominantLanguage!.rawValue)"
        
        let label3 = UILabel(frame: CGRect(x: 0, y: 300, width: view.frame.width, height: 100))
        recognizer.processString(string3)
        let res = recognizer.languageHypotheses(withMaximum: 6)
        let resString = res.reduce("") { partialResult, map in
            return partialResult + String(format: "【%@:%.1f】", map.key.rawValue, map.value)
        }
        label3.text = string3 + "：\(resString)"
        label3.numberOfLines = 0
        
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
        
        print(res)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
