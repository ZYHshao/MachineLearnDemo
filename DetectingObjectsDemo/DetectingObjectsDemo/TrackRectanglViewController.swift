//
//  TrackRectanglViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/26.
//

import UIKit
import Vision
import AVFoundation

class TrackRectanglViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let width = self.view.frame.size.width
        let scale = image.size.width / image.size.height
        imageView.frame = CGRect(x: 0, y: 100, width: width, height: width / scale)
        view.addSubview(imageView)
        imageView.addSubview(boxView)
        readVideo()
    }
    
    var images:[UIImage] = []
    
    
    lazy var boxView: UIView = {
        let v = UIView()
        v.backgroundColor = .red.withAlphaComponent(0.5)
        return v
    }()

    
    lazy var handler = VNSequenceRequestHandler()
    let image = UIImage(named: "image10")!
    lazy var imageView = UIImageView(image: image)
    var observation = VNRectangleObservation(boundingBox: CGRect(x: 0.3728713095188141, y: 0.833836019039154, width: 0.16493645310401917, height: 0.07572066783905029))

    lazy var request: VNTrackRectangleRequest = {
        // 预测量完成的矩形区域
        
        let req = VNTrackRectangleRequest(rectangleObservation: observation) { result, error in
            // 处理结果
            if let error {
//                print(error)
                
            }
            self.handleResult(request: result as! VNTrackRectangleRequest)
        }
        req.trackingLevel = .fast
        
        return req
    }()
    
    func handleResult(request: VNTrackRectangleRequest) {
        print(request.results)
        for r in request.results ?? [] {
            guard let result = r as? VNRectangleObservation else {
                return
            }
            observation = result
            var box = result.boundingBox
            // 坐标系转换
            box.origin.y = 1 - box.origin.y - box.size.height
            print("box:", result.boundingBox)
            DispatchQueue.main.async {
                let size = self.imageView.frame.size
                self.boxView.frame = CGRect(x: box.origin.x * size.width, y: box.origin.y * size.height, width: box.size.width * size.width, height: box.size.height * size.height)
            }
        }
    }
    
    func readVideo() {
        let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "video1", ofType: ".mp4")!)
        let videoAsset = AVURLAsset(url: videoURL)
        
        let videoProcessor = AVAssetImageGenerator(asset: videoAsset)
        videoProcessor.requestedTimeToleranceBefore = CMTime.zero
        videoProcessor.requestedTimeToleranceAfter = CMTime.zero
        

        let durationSeconds: Float64 = CMTimeGetSeconds(videoAsset.duration)
        var times = [NSValue]()
        let totalFrames: Float64 = durationSeconds * 60
        //定义 CMTime 即请求缩略图的时间间隔
        for i in 0...Int(totalFrames) {
           let timeFrame = CMTimeMake(value: Int64(i), timescale: 60)
           let timeValue = NSValue(time: timeFrame)

           times.append(timeValue)
        }
        videoProcessor.generateCGImagesAsynchronously(forTimes: times) { time, cgImage, actualTime, resultCode, error  in
            
            if let cgImage = cgImage {
                let image = UIImage(cgImage: cgImage)
                self.images.append(image)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        start()
    }
    
    func start() {
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { t in
            if count < self.images.count {
                self.imageView.image = self.images[count]
                self.request.inputObservation = self.observation
                try? self.handler.perform([self.request], on: self.images[count].cgImage!, orientation: .up)
                count += 1
            } else {
                self.request.isLastFrame = true
                t.invalidate()
                print("end")
            }
            
        }
        print(images.count)
    }
}
