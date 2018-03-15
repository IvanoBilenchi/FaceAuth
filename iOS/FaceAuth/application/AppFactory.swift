//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import UIKit

class AppFactory {
    
    lazy var rootViewController: UIViewController = cameraController
    
    lazy var cameraController: CameraController = CameraController(detector: faceDetector,
                                                                   recognizer: faceRecognizer)
    
    lazy var faceDetector: FaceDetector = FaceDetector(session: cameraSession)
    
    lazy var faceRecognizer: FaceRecognizer = FaceRecognizer()
    
    lazy var cameraSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: camera) {
            session.addInput(input)
            
            try? camera.lockForConfiguration()
            camera.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 15)
            camera.unlockForConfiguration()
        }
        
        let output = AVCaptureVideoDataOutput()
        session.addOutput(output)
        
        if let connection = output.connection(with: .video) {
            connection.videoOrientation = .portrait
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }
        
        return session
    }()
}
