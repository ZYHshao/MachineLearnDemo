//
//  TableViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/13.
//

import UIKit

class TableViewController: UITableViewController {
    
    let dataArray = ["图像内矩形识别",
                     "文本区域识别",
                     "条形码区域识别",
                     "轮廓区域识别",
                     "文档区域识别",
                     "人脸区域识别",
                     "面部特征识别",
                     "人脸捕获质量",
                     "水平面识别",
                     "人体姿势识别",
                     "手势识别",
                     "身体区域识别",
                     "图片中文本识别",
                     "动物识别",
                     "图片物体识别",
                     "矩形物体追踪",
                     "物体追踪",
                     "轨迹分析",
                     "图片特征分析",
                     "图片关注区分析",
                     "图片物体区分析",
                     "生成人物无光图",
                     "单词拆解",
                     "句子拆解",
                     "段落拆解",
                     "语言识别",
                     "文本分析",
                     "词句相似性分析",
                     "语音识别",
                     "音效识别",
                     "MNIST示例",
                     "可更新的模型示例",
                     "模型识别图片",
                     "模型识别物体",
                     "模型识别姿势",
                     "模型图片分割",
                     "模型景物深度分析",
                     "内容理解",
                     "自定义CoreML模型"]
    let controllers = [DetectingRectangleController(), DetectingTextViewController(), DetectingBarcodesViewController(), DetectingContoursViewController(), DetecingDocumentViewController(), DetecingFaceViewController(), DetecingFaceLandmarksViewController(), DetecingFaceCaptureQualityViewController(), DetecingHorizonViewController(), DetecingHumanBodyPoseViewController(), DetecingHumanHandPoseViewController(), DetecingHumanViewController(), RecognizeTextViewController(), RecognizeAnimalsViewController(), ClassifyImageViewController(), TrackRectanglViewController(), TrackObjectViewController(), DetectTrajectoriesViewController(), ImageFeatureViewController(), BasedSaliencyViewController(), ObjectnessBasedSaliencyViewController(), GeneratePersonSegmentationViewController(), TokenizationViewController(), SentenceViewController(), ParagraphViewController(), LanguageViewController(), IdentifyingViewController(), EmbeddingViewController(), SpeechViewController(), VoiceViewController(), MNISTViewController(), UpdateableModelViewController(), ClassifyModelViewController(), RecognizeModelViewController(), PoseModelViewController(), SegModelViewController(), DeppModelViewController(), TextModelViewController(), CustomModelViewController()]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)

        cell.textLabel?.text = dataArray[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        navigationController?.pushViewController(controllers[indexPath.row], animated: true)
    }

}
