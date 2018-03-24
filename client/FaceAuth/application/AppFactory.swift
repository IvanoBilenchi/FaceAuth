//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import UIKit

class AppFactory {
    
    // MARK: Model
    
    lazy var authServerAPI: AuthServerAPI = AuthServerAPI(serverName: Config.API.Server.name,
                                                          port: Config.API.Server.port,
                                                          useHTTPS: Config.API.Server.useHTTPS)
    
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
    
    // MARK: View
    
    lazy var loginView: LoginView = LoginView(minUserNameLength: Config.Security.minUserNameLength,
                                              minPasswordLength: Config.Security.minPasswordLength)
    
    // MARK: Controller
    
    lazy var rootViewController: UIViewController = navigationController
    
    lazy var navigationController: UINavigationController = UINavigationController(rootViewController: loginController)
    
    lazy var faceController: FaceController = {
        let controller = FaceController(detector: faceDetector, recognizer: faceRecognizer, wireframe: wireframe)
        controller.delegate = loginController
        return controller
    }()
    
    lazy var loginController: LoginController = {
        let controller = LoginController(api: authServerAPI, loginView: loginView, wireframe: wireframe)
        loginView.delegate = controller
        alertController.rootViewController = controller
        return controller
    }()
    
    lazy var alertController: AlertController = {
        let controller = AlertController()
        authServerAPI.delegate = controller
        return controller
    }()
    
    // MARK: Wireframe
    
    lazy var wireframe: AppWireframe = AppWireframe(appFactory: self)
}
