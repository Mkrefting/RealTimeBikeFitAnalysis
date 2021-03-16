//
//  PoseDetectionViewController.swift
//  RealTimeBikeFitAnalysis
//
//  Created by Krefting, Max (PGW) on 16/03/2021.
//

import SwiftUI
import UIKit
import CoreMedia
import Vision

final class PoseViewController: UIViewController {
    
    // MARK: - AV Property
    var videoCapture: VideoCapture!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup camera
        setUpCamera()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }

    // MARK: - SetUp Video
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .vga640x480, cameraPosition: .front) { success in
            
            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture.previewLayer {
                    previewLayer.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    self.view.layer.addSublayer(previewLayer)
                }
                
                // start video preview when setup is done
                self.videoCapture.start()
            }
        }
    }
    
}

// MARK: - VideoCaptureDelegate
extension PoseViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer, timestamp: CMTime) {
        // the captured image from camera is contained on pixelBuffer
        //predictUsingVision(pixelBuffer: pixelBuffer)
    }
}

extension PoseViewController {
    /*
    // MARK: - Inferencing
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        guard let request = request else { fatalError() }
        // vision framework configures the input size of image following our model's input configuration automatically
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
    
    // MARK: - Postprocessing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let heatmaps = observations.first?.featureValue.multiArrayValue else { return }
        
        /* =================================================================== */
        /* ========================= post-processing ========================= */
        
        /* ------------------ convert heatmap to point array ----------------- */
        var predictedPoints = postProcessor.convertToPredictedPoints(from: heatmaps, isFlipped: true)
        
        /* --------------------- moving average filter ----------------------- */
        if predictedPoints.count != mvfilters.count {
            mvfilters = predictedPoints.map { _ in MovingAverageFilter(limit: 3) }
        }
        for (predictedPoint, filter) in zip(predictedPoints, mvfilters) {
            filter.add(element: predictedPoint)
        }
        predictedPoints = mvfilters.map { $0.averagedValue() }
        /* =================================================================== */
        
        let matchingRatios = capturedPointsArray
            .map { $0?.matchVector(with: predictedPoints) }
            .compactMap { $0 }
        
        
        
        /* =================================================================== */
        /* ======================= display the results ======================= */
        DispatchQueue.main.sync { [weak self] in
            guard let self = self else { return }
            // draw line
            self.jointView.bodyPoints = predictedPoints
            
            var topCapturedJointBGView: UIView?
            var maxMatchingRatio: CGFloat = 0
            for (matchingRatio, (capturedJointBGView, capturedJointConfidenceLabel)) in zip(matchingRatios, zip(self.capturedJointBGViews, self.capturedJointConfidenceLabels)) {
                let text = String(format: "%.2f%", matchingRatio*100)
                capturedJointConfidenceLabel.text = text
                capturedJointBGView.backgroundColor = .clear
                if matchingRatio > 0.80 && maxMatchingRatio < matchingRatio {
                    maxMatchingRatio = matchingRatio
                    topCapturedJointBGView = capturedJointBGView
                }
            }
            topCapturedJointBGView?.backgroundColor = UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 0.4)
//            print(matchingRatios)
        }
        /* =================================================================== */
    }*/
}

struct PoseView: UIViewControllerRepresentable {

    public typealias UIViewControllerType = PoseViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PoseView>) -> PoseViewController {
        return PoseViewController()
    }
    
    func updateUIViewController(_ poseViewController: PoseViewController, context: UIViewControllerRepresentableContext<PoseView>) {

    }
}
