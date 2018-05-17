//
//  Created by Ivano Bilenchi on 24/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import Foundation

class LoginCoordinator {
    
    // MARK: Private properties
    
    private let api: AuthServerAPI
    private let alertController: AlertController
    private let faceController: FaceController
    private let loginController: LoginController
    
    private var credentialsBuilder: CredentialsBuilder?
    
    // MARK: Lifecycle
    
    init(api: AuthServerAPI,
         alertController: AlertController,
         faceController: FaceController,
         loginController: LoginController) {
        self.api = api
        self.alertController = alertController
        self.faceController = faceController
        self.loginController = loginController
    }
    
    // MARK: Navigation
    
    private func showFaceController(withMode mode: FaceController.Mode) {
        faceController.mode = mode
        loginController.navigationController?.pushViewController(faceController, animated: true)
    }
}

extension LoginCoordinator: AuthServerAPIDelegate {
    
    func api(_ api: AuthServerAPI, didReceiveLoginResponse response: LoginResponse) {
        loginController.setWaitingForResponse(false)
        
        switch response {
        case .loggedIn(let userName, let name, let description):
            if let loginCredentials = credentialsBuilder?.buildLoginCredentials() {
                alertController.showLoggedInMenu(userName: userName, name: name, description: description, deleteHandler: {
                    self.loginController.setWaitingForResponse(true)
                    api.delete(withCredentials: loginCredentials, completionHandler: { print($0) })
                })
            }
            
        case .unrecognizedFace:
            alertController.showAlert(withTitle: "👁️ You're lying",
                                      message: "Who are you?",
                                      buttonTitle: "You got me")
            
        case .wrongUserPass:
            alertController.showAlert(withTitle: "⛔ Access denied",
                                      message: "Invalid username/password combination.",
                                      buttonTitle: "Ok")
            
        case .error(let message):
            alertController.showErrorAlert(withMessage: message)
        }
    }
    
    func api(_ api: AuthServerAPI, didReceiveRegistrationResponse response: RegistrationResponse) {
        loginController.setWaitingForResponse(false)
        
        switch response {
        case .registered:
            if let loginCredentials = credentialsBuilder?.buildLoginCredentials() {
                alertController.showUserDetailsEntryUI({ (name, description) in
                    self.loginController.setWaitingForResponse(true)
                    api.updateDetails(withCredentials: loginCredentials,
                                      name: name,
                                      description: description,
                                      completionHandler: { print($0) })
                })
            }
            
        case .alreadyRegistered:
            alertController.showAlert(withTitle: "❌ Username in use",
                                      message: "This username is already taken. Please choose a new username.",
                                      buttonTitle: "I'm so lucky")
            
        case .error(let message):
            alertController.showErrorAlert(withMessage: message)
        }
    }
    
    func api(_ api: AuthServerAPI, didReceiveUpdateResponse response: GenericResponse) {
        loginController.setWaitingForResponse(false)
        
        switch response {
        case .ok:
            alertController.showAlert(withTitle: "✅ Update successful",
                                      message: "You may now login.",
                                      buttonTitle: "Ok")
            
        case .error(let message):
            alertController.showErrorAlert(withMessage: message)
        }
    }
    
    func api(_ api: AuthServerAPI, didReceiveDeleteResponse response: GenericResponse) {
        loginController.setWaitingForResponse(false)
        
        switch response {
        case .ok:
            alertController.showAlert(withTitle: "👋🏻 Delete successful",
                                      message: "See you!",
                                      buttonTitle: "Bye")
            
        case .error(let message):
            alertController.showErrorAlert(withMessage: message)
        }
    }
}

extension LoginCoordinator: LoginViewDelegate {
    
    func loginView(_ view: LoginView, didPressLoginButtonWithUserName userName: String, password: String) {
        credentialsBuilder = CredentialsBuilder(userName: userName, password: password)
        showFaceController(withMode: .recognize)
    }
    
    func loginView(_ view: LoginView, didPressRegisterButtonWithUserName userName: String, password: String) {
        credentialsBuilder = CredentialsBuilder(userName: userName, password: password)
        showFaceController(withMode: .enroll)
    }
}

extension LoginCoordinator: FaceControllerDelegate {
    
    func faceController(_ faceController: FaceController, didTrainModel modelPath: String, lastCapturedFace: UIImage) {
        guard let credentialsBuilder = credentialsBuilder,
            let credentials = credentialsBuilder.set(modelPath: modelPath).buildRegistrationCredentials() else {
                return
        }
        credentialsBuilder.set(image: lastCapturedFace)
        
        loginController.setWaitingForResponse(true)
        api.register(withCredentials: credentials, completionHandler: { print($0) })
        faceController.navigationController?.popViewController(animated: true)
    }
    
    func faceController(_ faceController: FaceController, didCaptureFace faceImage: UIImage) {
        guard let credentialsBuilder = credentialsBuilder,
            let credentials = credentialsBuilder.set(image: faceImage).buildLoginCredentials() else {
                return
        }
        
        loginController.setWaitingForResponse(true)
        api.login(withCredentials: credentials, completionHandler: { print($0) })
        faceController.navigationController?.popViewController(animated: true)
    }
}
