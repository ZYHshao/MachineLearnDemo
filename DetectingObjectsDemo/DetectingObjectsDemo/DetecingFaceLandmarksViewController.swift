//
//  DetecingFaceLandmarksViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/22.
//

import UIKit
import Vision
import AVFoundation

class DetecingFaceLandmarksViewController: UIViewController {


    // 要分析的图片资源
    let image = UIImage(named: "image5")!
    lazy var imageView = UIImageView(image: image)
    
    // 绘制的矩形区域
    var boxViews: [UIView] = []
    
    // 图像分析请求
    lazy var imageRequestHandler = VNImageRequestHandler(cgImage: image.cgImage!,
                                                    orientation: .up,
                                                    options: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let scale = image.size.width / image.size.height
       
        let width = self.view.frame.size.width
        imageView.frame = CGRect(x: 0, y: 100, width: width, height: width / scale)
        view.addSubview(imageView)
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.imageRequestHandler.perform([self.faceDetectionRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }


    
    private lazy var faceDetectionRequest: VNDetectFaceLandmarksRequest = {
        let faceDetectRequest = VNDetectFaceLandmarksRequest { request, error in
            DispatchQueue.main.async {
                self.drawTask(request: request as! VNDetectFaceLandmarksRequest)
            }
        }
        return faceDetectRequest
    }()
    
    private func drawTask(request: VNDetectFaceLandmarksRequest) {
        boxViews.forEach { v in
            v.removeFromSuperview()
        }
        for result in request.results ?? [] {
            
            var box = result.boundingBox
            // 坐标系转换
            box.origin.y = 1 - box.origin.y - box.size.height
            let v = UIView()
            v.backgroundColor = .clear
            v.layer.borderColor = UIColor.red.cgColor
            v.layer.borderWidth = 2
            imageView.addSubview(v)
            let size = imageView.frame.size
            v.frame = CGRect(x: box.origin.x * size.width, y: box.origin.y * size.height, width: box.size.width * size.width, height: box.size.height * size.height)
            
            // 进行特征绘制
            let landmarks = result.landmarks
            // 拿到所有特征点
            let allPoints = landmarks?.allPoints?.normalizedPoints
            
            let faceRect = result.boundingBox
            // 进行绘制
            for point in allPoints ?? [] {
                //faceRect的宽高是个比例，我们对应转换成View上的人脸区域宽高
                let rectWidth = imageView.frame.width * faceRect.width
                let rectHeight = imageView.frame.height * faceRect.height
                // 进行坐标转换
                // 特征点的x坐标为人脸区域的比例，
                // 1. point.x * rectWidth 得到在人脸区域内的x位置
                // 2. + faceRect.minX * imageView.frame.width 得到在View上的x坐标
                // 3. point.y * rectHeight + faceRect.minY * imageView.frame.height获得Y坐标
                // 4. imageView.frame.height -  的作用是y坐标进行翻转
                let tempPoint = CGPoint(x: point.x * rectWidth + faceRect.minX * imageView.frame.width, y: imageView.frame.height - (point.y * rectHeight + faceRect.minY * imageView.frame.height))
                let subV = UIView()
                subV.backgroundColor = .red
                subV.frame = CGRect(x: tempPoint.x - 2, y: tempPoint.y - 2, width: 4, height: 4)
                imageView.addSubview(subV)
            }
        }
    }
    
    func drawOnImage(source: UIImage,
                                 boundingRect: CGRect,
                                 faceLandmarkRegions: [VNFaceLandmarkRegion2D]) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: source.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.colorBurn)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        let rectWidth = source.size.width * boundingRect.size.width
        let rectHeight = source.size.height * boundingRect.size.height
        
        //draw image
        let rect = CGRect(x: 0, y:0, width: source.size.width, height: source.size.height)
        context.draw(source.cgImage!, in: rect)
        
        
        //draw bound rect
        var fillColor = UIColor.green
        fillColor.setFill()
        context.addRect(CGRect(x: boundingRect.origin.x * source.size.width, y:boundingRect.origin.y * source.size.height, width: rectWidth, height: rectHeight))
        context.drawPath(using: CGPathDrawingMode.stroke)
        
        //draw overlay
        fillColor = UIColor.red
        fillColor.setStroke()
        context.setLineWidth(2.0)
        for faceLandmarkRegion in faceLandmarkRegions {
            var points: [CGPoint] = []
            for i in 0..<faceLandmarkRegion.pointCount {
                let point = faceLandmarkRegion.normalizedPoints[i]
                let p = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
                points.append(p)
            }
            let mappedPoints = points.map { CGPoint(x: boundingRect.origin.x * source.size.width + $0.x * rectWidth, y: boundingRect.origin.y * source.size.height + $0.y * rectHeight) }
            context.addLines(between: mappedPoints)
            context.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return coloredImg
    }
    
}
