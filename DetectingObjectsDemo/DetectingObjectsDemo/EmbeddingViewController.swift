//
//  EmbeddingViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/6.
//

import UIKit
import NaturalLanguage

class EmbeddingViewController: UIViewController {
    
    let embedding = NLEmbedding.wordEmbedding(for: .english)!
    let embedding2 = NLEmbedding.sentenceEmbedding(for: .english)!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 500))
        label.numberOfLines = 0
        label.text = ""
        view.addSubview(label)
        let word = "dog"
        let word2 = "cat"
        let word3 = "teacher"
        
        let distance = embedding.distance(between: word, and: word2)
        let distance2 = embedding.distance(between: word, and: word3)
        label.text = label.text!.appending("单词1：\(word)\n单词2：\(word2)\n单词3：\(word3)")
        label.text = label.text!.appending("\n\n单词1与单词2间的距离：\(distance)\n单词1与单词3间的距离：\(distance2)")

        
        embedding.enumerateNeighbors(for: word3, maximumCount: 5, using: { item, distance in
            label.text = label.text!.appending("\n与单词3相近的词：\(item) - \(distance)")
            return true
        })
        
        let sen = "Hello, Xiao."
        let sen2 = "Hi, Xiao."
        let sen3 = "My name is Xiao."
        let distance3 =  embedding2.distance(between: sen, and: sen2)
        let distance4 =  embedding2.distance(between: sen, and: sen3)
        label.text = label.text!.appending("\n\n\n句子1：\(sen)\n句子2：\(sen2)\n句子3：\(sen3)")
        label.text = label.text!.appending("\n\n句子1与句子2间的距离：\(distance3)\n句子1与句子3间的距离：\(distance4)")
        
    }

}
