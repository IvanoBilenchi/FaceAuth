//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import UIKit

class AppFactory {
    
    lazy var rootViewController: UIViewController = cameraController
    
    lazy var cameraController: CameraController = CameraController(detector: faceDetector)
    
    lazy var faceDetector: FaceDetector = FaceDetector(session: cameraSession)
    
    lazy var cameraSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: camera) {
            session.addInput(input)
        }
        
        session.addOutput(AVCaptureVideoDataOutput())
        return session
    }()
}
