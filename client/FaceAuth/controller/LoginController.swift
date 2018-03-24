//
//  Created by Ivano Bilenchi on 21/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import UIKit

protocol LoginWireframe: class {
    func showFaceLoginUI()
    func showFaceEnrollmentUI()
}

class LoginController: UIViewController, LoginViewDelegate, FaceControllerDelegate {
    
    // MARK: Private properties
    
    private let api: AuthServerAPI
    private let loginView: LoginView
    private weak var wireframe: LoginWireframe?
    
    private var credentialsBuilder: CredentialsBuilder?
    
    // MARK: Lifecycle
    
    init(api: AuthServerAPI, loginView: LoginView, wireframe: LoginWireframe) {
        self.api = api
        self.loginView = loginView
        self.wireframe = wireframe
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        view = loginView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: LoginViewDelegate
    
    func loginView(_ view: LoginView, didPressLoginButtonWithUserName userName: String, password: String) {
        credentialsBuilder = CredentialsBuilder(userName: userName, password: password)
        wireframe?.showFaceLoginUI()
    }
    
    func loginView(_ view: LoginView, didPressRegisterButtonWithUserName userName: String, password: String) {
        credentialsBuilder = CredentialsBuilder(userName: userName, password: password)
            .set(name: "Ivano Bilenchi") // TODO: remove
            .set(description: "Software engineer") // TODO: remove
        wireframe?.showFaceEnrollmentUI()
    }
    
    // MARK: FaceControllerDelegate
    
    func faceController(_ faceController: FaceController, didTrainModel modelPath: String) {
        guard let credentialsBuilder = credentialsBuilder,
            let credentials = credentialsBuilder.set(modelPath: modelPath).buildRegistrationCredentials() else {
                return
        }
        
        setWaitingForResponse(true)
        
        api.register(withCredentials: credentials) { response in
            self.setWaitingForResponse(false)
            print(response)
        }
    }
    
    func faceController(_ faceController: FaceController, didCaptureFace faceImage: UIImage) {
        guard let credentialsBuilder = credentialsBuilder,
            let credentials = credentialsBuilder.set(image: faceImage).buildLoginCredentials() else {
                return
        }
        
        setWaitingForResponse(true)
        
        api.login(withCredentials: credentials) { response in
            self.setWaitingForResponse(false)
            print(response)
        }
    }
    
    // MARK: Private func
    
    func setWaitingForResponse(_ waiting: Bool) {
        loginView.isEnabled = !waiting
        UIApplication.shared.isNetworkActivityIndicatorVisible = waiting
    }
}
