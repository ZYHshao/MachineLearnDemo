//
//  IdentifyingViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/5.
//

import UIKit
import NaturalLanguage

class IdentifyingViewController: UIViewController {
    
    let string = "The sunshine is very good today, and my walking steps are light and agile. \nI really dislike rainy days."

    
    let tagger = NLTagger(tagSchemes: [.lexicalClass, .tokenType, .lemma, .nameType, .script, .nameTypeOrLexicalClass, .sentimentScore, .language])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
       
        let label = UILabel(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 100))
        label.text = "要分析的文本：" + string
        label.numberOfLines = 0
        view.addSubview(label)
        
        let resultLabel = UILabel(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 400))
        resultLabel.numberOfLines = 0
        view.addSubview(resultLabel)
        NLTagger.requestAssets(for: .simplifiedChinese, tagScheme: .sentimentScore) { result, error in
            print(NLTagger.availableTagSchemes(for: .sentence, language: .simplifiedChinese))
        }
       
        tagger.string = string
        tagger.enumerateTags(in: string.startIndex ..< string.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, range in
            resultLabel.text = (resultLabel.text ?? "").appending("【[\(string[range])]-[\(tag?.rawValue ?? "")]】")
            return true
        }
        
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
