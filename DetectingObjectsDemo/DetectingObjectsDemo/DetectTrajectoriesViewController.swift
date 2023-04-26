//
//  DetectTrajectoriesViewController.swift
//  DetectingObjectsDemo
//
//  Created by 珲少 on 2023/4/26.
//

import UIKit
import Vision

class DetectTrajectoriesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    lazy var request: VNDetectTrajectoriesRequest = {
        let req = VNDetectTrajectoriesRequest(frameAnalysisSpacing: CMTime(value: 1, timescale: 1), trajectoryLength: 10) { result, error in
            
        }
        return req
    }()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
