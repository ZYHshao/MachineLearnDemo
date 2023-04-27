//
//  DetectTrajectoriesViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/26.
//

import UIKit
import Vision
import AVFoundation

class DetectTrajectoriesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let playView = AVPlayerLayer(player: player)
        playView.bounds = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        playView.anchorPoint = CGPoint(x: 0, y: 0)
        view.layer.addSublayer(playView)
        DispatchQueue.global().async {
            self.detectTrajectories()
        }
    }
    
    let image = UIImage(named: "image11")!
    let player = AVPlayer(playerItem: AVPlayerItem(asset: AVAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: "video2", ofType: ".mov")!))))

    lazy var request: VNDetectTrajectoriesRequest = {
        let req = VNDetectTrajectoriesRequest(frameAnalysisSpacing:.zero, trajectoryLength: 10) { result, error in
            if let error {
                print(error)
            }
            
            self.handleResult(request: result as! VNDetectTrajectoriesRequest)
        }
        return req
    }()
    
    func handleResult(request: VNDetectTrajectoriesRequest) {
        for res in request.results ?? [] {
            let points = res.projectedPoints
            for p in points {
                DispatchQueue.main.async {
                    let v = UIView()
                    let scale = self.image.size.width / self.image.size.height
                    let width = self.view.frame.width
                    let height = width / scale
                    let size = CGSize(width: width, height:height)
                    v.backgroundColor = .red
                    let offsetY = self.view.frame.height / 2 - height / 2
                    v.frame = CGRect(x: p.x * size.width, y: (1 - p.y) * size.height + offsetY, width: 4, height: 4)
                    self.view.addSubview(v)
                }
            }
        }
    }
    
    func detectTrajectories() {
        let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "video2", ofType: ".mov")!)
        let asset =  AVAsset(url: videoURL)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else { return }

        let frameRate = videoTrack.nominalFrameRate
        let frameDuration = CMTime(seconds: 1 / Double(frameRate), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let assetReaderOutputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]

        let assetReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: assetReaderOutputSettings)
        

        let assetReader = try! AVAssetReader(asset: asset)
        assetReader.add(assetReaderOutput)
        
        if assetReader.startReading() {
            while let sampleBuffer = assetReaderOutput.copyNextSampleBuffer() {
                autoreleasepool {
                    if CMSampleBufferDataIsReady(sampleBuffer) {
                        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        processFrame(sampleBuffer, atTime: timestamp, withDuration:frameDuration)
                    }
                }
            }
        }
    }

    func processFrame(_ sampleBuffer: CMSampleBuffer, atTime time : CMTime, withDuration duration : CMTime) {
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up)
        try? handler.perform([request])
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.play()
    }
}
