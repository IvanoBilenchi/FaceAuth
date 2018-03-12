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
    var detectLandmarks = false
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
        
        let request: VNRequest
        
        if detectLandmarks {
            request = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceRequestCompletion)
        } else {
            request = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaceRequestCompletion)
        }
        
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
        
        guard box.intersection(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)).equalTo(box) else {
            DispatchQueue.main.async { self.delegate?.faceDetectorStoppedDetectingFace(self) }
            return
        }
        
        // Get landmarks
        var landmarkGroups: [[CGPoint]]
        
        if detectLandmarks, let landmarks = observation.landmarks {
            let groups = [landmarks.faceContour,
                          landmarks.innerLips,
                          landmarks.leftEye,
                          landmarks.leftEyebrow,
                          landmarks.medianLine,
                          landmarks.nose,
                          landmarks.noseCrest,
                          landmarks.outerLips,
                          landmarks.rightEye,
                          landmarks.rightEyebrow].flatMap({ $0?.normalizedPoints })

            landmarkGroups = groups.map({ $0.map({ CGPoint(x: (1.0 - $0.y) * box.size.height, y: $0.x * box.size.width) }) })
        } else {
            landmarkGroups = []
        }
        
        let faceObservation = FaceObservation(buffer: lastBuffer, boundingBox: box, landmarks: landmarkGroups)
        lastObservation = faceObservation
        
        DispatchQueue.main.async {
            self.delegate?.faceDetector(self, didDetectFace: faceObservation)
        }
    }
}
