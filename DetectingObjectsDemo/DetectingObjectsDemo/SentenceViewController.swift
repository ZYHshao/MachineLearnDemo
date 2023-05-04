//
//  SentenceViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/4.
//

import UIKit
import NaturalLanguage

class SentenceViewController: UIViewController {

    lazy var contentLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 18)
        l.text = string
        l.textColor = .gray
        return l
    }()
    
    lazy var resultLabel:UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 18)
        return l
    }()
    
    let string =
"""
最近，随着Chat-GPT4的发布，人工智能相关的资讯和话题再次火热了起来😄。
有了人工智能的加持，对人们的生活以及各行各业的工作都将带来效率的极大提升。目前，各种大模型的发布层出不穷。这些大模型虽然功能非常强大（如文本理解，绘图等），但对于个人来说，要跑起这样一个模型来对外提供服务还是比较困难的，其需要有非常强大的算力支持。
"""
    
    let tokenizer = NLTokenizer(unit: .sentence)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(contentLabel)
        view.addSubview(resultLabel)
        contentLabel.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 200)
        resultLabel.frame = CGRect(x: 0, y: 300, width: view.frame.width, height: 500)

        tokenizer.string = string
        
        tokenizer.enumerateTokens(in: string.startIndex ..< string.endIndex) { range, attribute in
            let word = string[range]
            self.showWord(string: String(word))
            return true
        }
        
    }
    
    func showWord(string: String) {
        resultLabel.text = (resultLabel.text ?? "").appending("【\(string)】\n\n")
    }

}
