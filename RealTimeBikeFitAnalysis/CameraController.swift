//
//  CameraViewController.swift
//  RealTimeBikeFitAnalysis
//
//  Created by Max Krefting on 04/03/2021.
//

/*
import SwiftUI
import UIKit
import AVFoundation
import Vision

@available(iOS 14.0, *)
final class CameraController: UIViewController {
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check video authorization status - video access is required
        switch AVCaptureDevice.authorizationStatus(for: .video){
            case .authorized:
                // user has previously granted access to camera
                break
            case .notDetermined:
                // user has not yet been presented with the option to grant video access. Suspend the session queue to delay session setup until the access request has completed
                sessionQueue.suspend()
                AVCaptureDevice.requestAccess(for: .video, completionHandler: {granted in
                    if granted{
                        self.sessionQueue.resume()
                    }
                })
            default:
                // user has previously denied access (or cannot use camera due to restrictions)
                return
        }
        
        // Setup the capture session
        // We do not perform these tasks on the main queue because AVCaptureSession.startRunning() is a blocking call, which can take a long time. Dispatch session setup to the sessionQueue, so the main queue is not blocked, which keeps the UI responsive.
        sessionQueue.async{
            self.configureSession()
        }
        
        setupLayers()
        setupVision()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async{
            self.session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async{
            self.session.stopRunning()
        }
        super.viewWillDisappear(animated)
    }
    
    override var shouldAutorotate: Bool { false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {return .landscapeRight}

    
    // MARK: Session Management
    
    // Start Capture Session
    private var session = AVCaptureSession()
    
    // Communicate with the session and other session objects on this queue
    private let sessionQueue = DispatchQueue(label: "session queue")
    // Seperate queue for video processing
    private let videoQueue = DispatchQueue(label: "video queue")

    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session:self.session)
        preview.videoGravity = .resizeAspect    // experiment with .resizeAspectFill
        preview.connection?.videoOrientation = .landscapeRight
        return preview
    }()
    
    private let videoOutput = AVCaptureVideoDataOutput()
    
    var bufferSize: CGSize = .zero // size of video buffer
    
    // MARK: ConfigureSession
    // To be called on the session queue
    private func configureSession(){
        session.beginConfiguration()
        // To do: Set session preset (video quality) - lower is better for ml model efficiency
        
        // Add video device input
        // For testing - changed position to front - so can see how the camera is analysing poses
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInTrueDepthCamera,.builtInDualCamera,.builtInWideAngleCamera], mediaType:.video, position:.front)
        guard let videoDevice = discoverySession.devices.first else {return}
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {return}
        if (self.session.canAddInput(videoInput)){
            self.session.addInput(videoInput)
        } else {return}
        
        // Add preview layer to be shown in UI
        previewLayer.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.view.layer.addSublayer(previewLayer)
        
        // Add video output
        if self.session.canAddOutput(self.videoOutput){
            self.session.addOutput(self.videoOutput)
            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any] // check docs, it has a different line here
            self.videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        } else {return}
        
        let captureConnection = videoOutput.connection(with:.video)
        captureConnection?.isEnabled = true
        do{
            try videoDevice.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions(videoDevice.activeFormat.formatDescription)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice.unlockForConfiguration()
        } catch{
            print(error.localizedDescription)
        }
        
        session.commitConfiguration()
    }
    
    // MARK: Video Recording
    func startRecording(){
        // TO DO
        print("Start Recording")
    }
    
    // MARK: Pose Analysis
    private var poseOverlay: CALayer! = nil
    private var requests = [VNRequest]() // array of vision requests to process
    private let bodyPoseDetectionMinConfidence: VNConfidence = 0.6
    private let bodyPoseRecognisedPointMidConfidence: VNConfidence = 0.1
    
    func setupLayers(){
        poseOverlay = CALayer()
        poseOverlay.bounds = CGRect(x:0.0,
                                    y:0.0,
                                    width: bufferSize.width,
                                    height: bufferSize.height) // set the layer to cover the whole video buffer size
        view.layer.insertSublayer(poseOverlay,above:previewLayer) // insert pose overlay on top of camera preview layer
    }
    
    func setupVision(){
        // declare request with callback when it is done
        let poseRequest = VNDetectHumanBodyPoseRequest{(request,error) in
            guard error == nil else{
                print(error!.localizedDescription)
                return
            }
            DispatchQueue.main.async{ // update UI on main thread
                if let results = request.results{
                    self.handleVisionResults(results)
                }
            }
        }
        self.requests = [poseRequest]
        
    }
    
    func handleVisionResults(_ results: [Any]){
        print(results)
        // add observation to poseOverlay
        return
    }

}

// MARK: Process Image Frames
extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do{
            try requestHandler.perform(self.requests)
        }
        catch{
            print("Unable to perform the request: \(error)")
            print(error.localizedDescription)
        }
        // process image here
    }
}

struct CameraControllerView: UIViewControllerRepresentable {

    // TO DO - get camerview to talk to cameracontroller via cameracontrollerview
    
    
    @Binding var startRecording: Bool
    public typealias UIViewControllerType = CameraController
/*
    func makeCoordinator() -> CameraControllerView.Coordinator{
        Coordinator(self)
    }
*/
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraControllerView>) -> CameraController {
        return CameraController()
    }
    
    func updateUIViewController(_ cameraController: CameraController, context: UIViewControllerRepresentableContext<CameraControllerView>) {
        /*if startRecording{
            cameraController.startRecording()
            startRecording = false
        }
    }
    
    class Coordinator: NSObject{
        var parent: CameraControllerView
        init(_ parent: CameraControllerView){
            self.parent = parent
        }
    }*/
    }
}
*/
