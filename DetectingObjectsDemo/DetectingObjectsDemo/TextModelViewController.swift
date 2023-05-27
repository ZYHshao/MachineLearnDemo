//
//  TextModelViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/5/27.
//

import UIKit
import CoreML
import NaturalLanguage

class TextModelViewController: UIViewController {
    
    let content = "The quick brown fox jumps over the lethargic dog."
    
    let question = "Who jumped over the dog?"
    
    var tokensDic = Dictionary<Substring, Int>()

    let startToken = 101
    let separatorToken = 102
    let padToken = 0
    
    var inputTokens:[Int] = []
    
    func readDictionary() {
        let fileName = "bert-base-uncased-vocab"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt") else {
            fatalError("Vocabulary file is missing")
        }
        guard let rawVocabulary = try? String(contentsOf: url) else {
            fatalError("Vocabulary file has no contents.")
        }
        
        let words = rawVocabulary.split(separator: "\n")
        let values = 0..<words.count
        
        tokensDic = Dictionary(uniqueKeysWithValues: zip(words, values))
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        var wordTokens = [Substring]()
        let tagger = NLTagger(tagSchemes: [.tokenType])
        tagger.string = content.lowercased()
        tagger.enumerateTags(in: tagger.string!.startIndex ..< tagger.string!.endIndex,
                             unit: .word,
                             scheme: .tokenType,
                             options: [.omitWhitespace]) { (_, range) -> Bool in
            wordTokens.append(tagger.string![range])
            return true
        }
        
        var questionTokens = [Substring]()
        tagger.string = question.lowercased()
        tagger.enumerateTags(in: tagger.string!.startIndex ..< tagger.string!.endIndex,
                             unit: .word,
                             scheme: .tokenType,
                             options: [.omitWhitespace]) { (_, range) -> Bool in
            questionTokens.append(tagger.string![range])
            return true
        }
        
        readDictionary()
        
        
        let questionTokenIds = questionTokens.compactMap { token in
            tokensDic[token]
        }
        
        let contentTokenIds = wordTokens.compactMap { token in
            tokensDic[token]
        }
        
        
       
        inputTokens.append(startToken)
        inputTokens.append(contentsOf: questionTokenIds)
        inputTokens.append(separatorToken)
        inputTokens.append(contentsOf: contentTokenIds)
        inputTokens.append(separatorToken)
        while inputTokens.count < 384 {
            inputTokens.append(padToken)
        }
        
        print(inputTokens)
        
        var inputTokenTypes:[Int] = []
        inputTokenTypes.append(0)
        inputTokenTypes.append(contentsOf: Array(repeating: 1, count: questionTokenIds.count))
        inputTokenTypes.append(0)
        inputTokenTypes.append(contentsOf:  Array(repeating: 1, count: contentTokenIds.count))
        inputTokenTypes.append(0)
        while inputTokenTypes.count < 384 {
            inputTokenTypes.append(0)
        }
        
        
        
        var tokenMultiArray = try! MLMultiArray(shape: [1, 384], dataType: .int32)
        for (index, inputToken) in inputTokens.enumerated() {
            tokenMultiArray[[0, NSNumber(integerLiteral: index)]] = NSNumber(integerLiteral: inputToken)
        }

        var typesMultiArray = try! MLMultiArray(shape: [1, 384], dataType: .int32)
        for (index, inputToken) in inputTokenTypes.enumerated() {
            typesMultiArray[[0, NSNumber(integerLiteral: index)]] = NSNumber(integerLiteral: inputToken)
        }
        

        let model = try! BERTSQUADFP16(configuration: MLModelConfiguration())
        let input = BERTSQUADFP16Input(wordIDs: tokenMultiArray, wordTypes: typesMultiArray)
        let output = try! model.prediction(input: input)
        handleOutput(output: output)
        
        
        let label = UILabel(frame: CGRect(x: 20, y: 100, width: view.frame.width - 40, height:200))
        label.numberOfLines = 0
        label.text = "【content:】\n\(content)\n\n\n【question:】\n\(question)"
        view.addSubview(label)
    }
    
    
    func handleOutput(output: BERTSQUADFP16Output) {
        var startIndex = 0
        for p in startIndex ..< output.startLogits.doubleArray().count {
            if output.startLogits.doubleArray()[p] > output.startLogits.doubleArray()[startIndex] {
                startIndex = p
            }
        }
        var endIndex = startIndex
        for p in endIndex ..< startIndex + 5 {
            if output.endLogits.doubleArray()[p] > output.endLogits.doubleArray()[startIndex] {
                endIndex = p
            }
        }
        let subs = inputTokens[startIndex ..< endIndex]
        let label = UILabel(frame: CGRect(x: 20, y: 300, width: view.frame.width - 40, height:200))
        view.addSubview(label)
        var string = ""
        for i in subs {
            for item in tokensDic where item.value == i {
                string.append(String(item.key) + " ")
            }
        }
        label.text = "【answer:】\(string)"
    }

}

extension MLMultiArray {
    func doubleArray() -> [Double] {
        // Bind the underlying `dataPointer` memory to make a native swift `Array<Double>`
        let unsafeMutablePointer = dataPointer.bindMemory(to: Double.self, capacity: count)
        let unsafeBufferPointer = UnsafeBufferPointer(start: unsafeMutablePointer, count: count)
        return [Double](unsafeBufferPointer)
    }
}
