//
//  SpeechViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/7.
//

import UIKit
import Speech

class SpeechViewController: UIViewController {
    
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-Hants"))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let path = Bundle.main.path(forResource: "12168", ofType: ".wav")
        let url = URL(fileURLWithPath: path!)
        let request = SFSpeechURLRecognitionRequest(url: url)
        if #available(iOS 16, *) {
            request.addsPunctuation = true
        } else {
            // Fallback on earlier versions
        }
        
        let label = UILabel(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 400))
        label.numberOfLines = 0
        view.addSubview(label)
        
        recognizer?.recognitionTask(with: request, resultHandler: { result, error in
            print(result?.bestTranscription.formattedString, error)
            label.text = result?.bestTranscription.formattedString
        })
        
       
       
    }
    


}
