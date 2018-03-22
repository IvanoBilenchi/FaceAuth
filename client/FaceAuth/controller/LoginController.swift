//
//  Created by Ivano Bilenchi on 21/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import UIKit

class LoginController: UIViewController, LoginViewDelegate {
    
    // MARK: Private properties
    
    private let loginView: LoginView
    
    // MARK: Lifecycle
    
    init(loginView: LoginView) {
        self.loginView = loginView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginView.becomeFirstResponder()
    }
    
    // MARK: LoginViewDelegate
    
    func loginView(_ view: LoginView, didPressLoginButtonWithUserName userName: String, password: String) {
        print("Login: \(userName) - \(password)")
    }
    
    func loginView(_ view: LoginView, didPressRegisterButtonWithUserName userName: String, password: String) {
        print("Register: \(userName) - \(password)")
    }
}
