//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import Vision

protocol FaceDetectorDelegate: class {
    func faceDetector(_ faceDetector: FaceDetector, didDetectFaceWithNormalizedBoundingBox boundingBox: CGRect, landmarks: [[CGPoint]])
    func faceDetectorStoppedDetectingFace(_ faceDetector: FaceDetector)
}

class FaceDetector: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: Public properties
    
    let session: AVCaptureSession
    weak var delegate: FaceDetectorDelegate?
    
    // MARK: Private properties
    
    private let sampleQueue = DispatchQueue(label: "com.ivanobilenchi.FaceAuth.sampleQueue")
    private let requestHandler = VNSequenceRequestHandler()
    
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
        let request = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceRequestCompletion)
        try? requestHandler.perform([request], on: cvBuffer, orientation: .right)
    }
    
    // MARK: Private methods
    
    private func handleFaceRequestCompletion(request: VNRequest?, error: Error?) {
        guard let observation = request?.results?.first as? VNFaceObservation else {
            DispatchQueue.main.async { self.delegate?.faceDetectorStoppedDetectingFace(self) }
            return
        }
        
        // Get bounding box
        var rect = observation.boundingBox
        swap(&(rect.size.width), &(rect.size.height))
        swap(&(rect.origin.x), &(rect.origin.y))
        rect.origin.x = 1.0 - rect.origin.x - rect.size.width
        rect.origin.y = 1.0 - rect.origin.y - rect.size.height
        
        // Get landmarks
        var landmarkGroups: [[CGPoint]]
        
        if let landmarks = observation.landmarks {
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
            
            landmarkGroups = groups.map({ $0.map({ CGPoint(x: (1.0 - $0.y) * rect.size.width, y: (1.0 - $0.x) * rect.size.height) }) })
        } else {
            landmarkGroups = []
        }
        
        DispatchQueue.main.async {
            self.delegate?.faceDetector(self, didDetectFaceWithNormalizedBoundingBox: rect, landmarks: landmarkGroups)
        }
    }
}
