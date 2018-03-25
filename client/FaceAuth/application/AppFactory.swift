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
    
    lazy var cameraView: CameraView = CameraView(session: cameraSession)
    
    lazy var loginView: LoginView = LoginView(minUserNameLength: Config.Security.minUserNameLength,
                                              minPasswordLength: Config.Security.minPasswordLength)
    
    // MARK: Controller
    
    lazy var rootViewController: UIViewController = {
        let controller = navigationController
        
        // Configure app
        authServerAPI.delegate = loginCoordinator
        faceDetector.delegate = faceController
        cameraView.delegate = faceController
        loginView.delegate = loginCoordinator
        faceController.delegate = loginCoordinator
        alertController.rootViewController = loginController
        
        // Stylize app
        UIButton.appearance().setTitleColor(.red, for: .normal)
        UIButton.appearance().setTitleColor(.gray, for: .disabled)
        UIBarButtonItem.appearance().tintColor = .red
        UINavigationBar.appearance().barStyle = .black
        
        return controller
    }()
    
    lazy var navigationController: UINavigationController = UINavigationController(rootViewController: loginController)
    lazy var faceController: FaceController = FaceController(detector: faceDetector, cameraView: cameraView)
    lazy var loginController: LoginController = LoginController(loginView: loginView)
    lazy var alertController: AlertController = AlertController()
    
    // MARK: Coordinator
    
    lazy var loginCoordinator: LoginCoordinator = LoginCoordinator(api: authServerAPI,
                                                                   alertController: alertController,
                                                                   faceController: faceController,
                                                                   loginController: loginController)
}
