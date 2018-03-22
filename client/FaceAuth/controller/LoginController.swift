//
//  Created by Ivano Bilenchi on 21/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import UIKit

protocol LoginWireframe {
    func showCameraController(withMode mode: CameraController.Mode)
}

class LoginController: UIViewController, LoginViewDelegate {
    
    // MARK: Private properties
    
    private let loginView: LoginView
    private let wireframe: LoginWireframe
    
    // MARK: Lifecycle
    
    init(loginView: LoginView, wireframe: LoginWireframe) {
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
        print("Login: \(userName) - \(password)")
        wireframe.showCameraController(withMode: .recognize)
    }
    
    func loginView(_ view: LoginView, didPressRegisterButtonWithUserName userName: String, password: String) {
        print("Register: \(userName) - \(password)")
        wireframe.showCameraController(withMode: .enroll)
    }
}
