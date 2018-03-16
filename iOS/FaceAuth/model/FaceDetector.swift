//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import Vision

protocol FaceDetectorDelegate: class {
    func faceDetector(_ faceDetector: FaceDetector, didDetectFace faceObservation: FaceObservation)
    func faceDetectorStoppedDetectingFace(_ faceDetector: FaceDetector)
}

class FaceDetector: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: Public properties
    
    let session: AVCaptureSession
    var lastObservation: FaceObservation?
    
    weak var delegate: FaceDetectorDelegate?
    
    // MARK: Private properties
    
    private let sampleQueue = DispatchQueue(label: "com.ivanobilenchi.FaceAuth.sampleQueue", qos: .userInteractive)
    private let requestHandler = VNSequenceRequestHandler()
    private var lastBuffer: CVPixelBuffer!
    
    // MARK: Lifecycle
    
    init(session: AVCaptureSession) {
        self.session = session
        super.init()
        (session.outputs.first as? AVCaptureVideoDataOutput)?.setSampleBufferDelegate(self, queue: sampleQueue)
    }
    
    // MARK: Public methods
    
    func startDetecting() {
        session.startRunning()
    }
    
    func stopDetecting() {
        session.stopRunning()
        delegate?.faceDetectorStoppedDetectingFace(self)
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        lastBuffer = cvBuffer
        
        let request = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceRequestCompletion)
        try? requestHandler.perform([request], on: cvBuffer, orientation: .up)
    }
    
    // MARK: Private methods
    
    private func handleFaceRequestCompletion(request: VNRequest?, error: Error?) {
        guard let observation = request?.results?.first as? VNFaceObservation else {
            DispatchQueue.main.async { self.delegate?.faceDetectorStoppedDetectingFace(self) }
            return
        }
        
        // Get bounding box
        var box = observation.boundingBox
        box.origin.y = 1.0 - box.origin.y - box.size.height
        
        // Ensure bounding box is not out of bounds
        guard box.intersection(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)).equalTo(box) else {
            DispatchQueue.main.async { self.delegate?.faceDetectorStoppedDetectingFace(self) }
            return
        }
        
        // Get position of eyes for alignment
        guard let leftEye = observation.landmarks?.leftPupil?.normalizedPoints.first,
            let rightEye = observation.landmarks?.rightPupil?.normalizedPoints.first else {
                DispatchQueue.main.async { self.delegate?.faceDetectorStoppedDetectingFace(self) }
                return
        }
        
        let eyes = (
            left: CGPoint(x: (1.0 - leftEye.y) * box.size.height, y: leftEye.x * box.size.width),
            right: CGPoint(x: (1.0 - rightEye.y) * box.size.height, y: rightEye.x * box.size.width)
        )
        
        // Notify observation
        let faceObservation = FaceObservation(buffer: lastBuffer, boundingBox: box, leftEye: eyes.left, rightEye: eyes.right)
        lastObservation = faceObservation
        
        DispatchQueue.main.async {
            self.delegate?.faceDetector(self, didDetectFace: faceObservation)
        }
    }
}
