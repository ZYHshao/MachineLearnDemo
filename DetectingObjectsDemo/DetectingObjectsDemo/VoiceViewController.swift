//
//  VoiceViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/7.
//

import UIKit
import SoundAnalysis

class VoiceViewController: UIViewController, SNResultsObserving {
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else  { return }
        guard let classification = result.classifications.first else { return }


        let percent = classification.confidence * 100.0
        let percentString = String(format: "%.2f%%", percent)

        
        label.text = "分析出的音效分类：\(classification.identifier)。可信度： \(percentString)。\n"
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("error:", error)
    }
    
    func requestDidComplete(_ request: SNRequest) {
        
    }
  
    let analyzer = try! SNAudioFileAnalyzer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "12168", ofType: ".wav")!))
    
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        let request = try! SNClassifySoundRequest(classifierIdentifier: .version1)
        
        try! analyzer.add(request, withObserver: self)
        analyzer.analyze()
        
        label.numberOfLines = 0
        label.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 100)
        view.addSubview(label)
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
