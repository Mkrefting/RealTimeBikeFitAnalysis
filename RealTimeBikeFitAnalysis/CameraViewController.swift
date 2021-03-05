//
//  CameraViewController.swift
//  RealTimeBikeFitAnalysis
//
//  Created by Max Krefting on 04/03/2021.
//

import SwiftUI
import UIKit
import AVFoundation

final class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var captureSession: AVCaptureSession! = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session:self.captureSession)
        preview.videoGravity = .resizeAspect    // experiment with .resizeAspectFill
        preview.connection?.videoOrientation = .landscapeRight
        return preview
    }()
    private let videoOutput = AVCaptureVideoDataOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCameraInput()
        self.addPreviewLayer()
        self.addVideoOutput()
        self.captureSession.startRunning()
    }
    
    func addCameraInput(){
        guard let videoCaptureDevice = AVCaptureDevice.default(for:.video) else {return}
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {return}
        if (self.captureSession.canAddInput(videoInput)) {
            self.captureSession.addInput(videoInput)
        } else {return}
    }

    func addPreviewLayer(){
        previewLayer.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.view.layer.addSublayer(previewLayer)
    }
    
    func addVideoOutput(){
        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        self.captureSession.addOutput(self.videoOutput)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (self.captureSession?.isRunning == false) {
            self.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.captureSession?.isRunning == true) {
            self.captureSession.stopRunning()
        }
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        // process image here
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {return .landscapeRight}
    
}

extension CameraViewController: UIViewControllerRepresentable {

    public typealias UIViewControllerType = CameraViewController

    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraViewController>) -> CameraViewController {
        
        return CameraViewController()
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CameraViewController>) {
        
    }
}
