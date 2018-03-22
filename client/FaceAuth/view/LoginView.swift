//
//  Created by Ivano Bilenchi on 21/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import UIKit

protocol LoginViewDelegate: class {
    func loginView(_ view: LoginView, didPressLoginButtonWithUserName userName: String, password: String)
    func loginView(_ view: LoginView, didPressRegisterButtonWithUserName userName: String, password: String)
}

class LoginView: UIView, UITextFieldDelegate {
    
    // MARK: Public properties
    
    weak var delegate: LoginViewDelegate?
    
    // MARK: Private properties
    
    private lazy var form: UIView = {
        let form = UIView()
        form.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        form.layer.cornerRadius = 10.0
        
        form.addSubview(userNameField)
        form.addSubview(passwordField)
        form.addSubview(loginButton)
        form.addSubview(registerButton)
        
        addSubview(form)
        
        return form
    }()
    
    private lazy var userNameField: UITextField = {
        let field = UITextField.defaultField(forLoginView: self)
        field.placeholder = "Username"
        return field
    }()
    
    private lazy var passwordField: UITextField = {
        let field = UITextField.defaultField(forLoginView: self)
        field.isSecureTextEntry = true
        field.placeholder = "Password"
        return field
    }()
    
    private lazy var loginButton: UIButton = {
        let btn = UIButton.defaultButton(forLoginView: self)
        btn.setTitle("Login", for: .normal)
        return btn
    }()
    
    private lazy var registerButton: UIButton = {
        let btn = UIButton.defaultButton(forLoginView: self)
        btn.setTitle("Register", for: .normal)
        return btn
    }()
    
    private let minUserNameLength: UInt
    private let minPasswordLength: UInt
    
    // MARK: Lifecycle
    
    init(minUserNameLength: UInt, minPasswordLength: UInt) {
        self.minUserNameLength = minUserNameLength
        self.minPasswordLength = minPasswordLength
        super.init(frame: .zero)
        setupAppearance()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAppearance() {
        backgroundColor = UIColor(red: 252.0/255.0, green: 104.0/255.0, blue: 91.0/255.0, alpha: 1.0)
        layer.cornerRadius = 10.0
    }
    
    private func setupConstraints() {
        
        form.translatesAutoresizingMaskIntoConstraints = false
        form.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        form.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20.0).isActive = true
        form.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        
        userNameField.translatesAutoresizingMaskIntoConstraints = false
        userNameField.topAnchor.constraint(equalTo: form.topAnchor, constant: 20.0).isActive = true
        userNameField.widthAnchor.constraint(equalTo: form.widthAnchor, constant: -40.0).isActive = true
        userNameField.centerXAnchor.constraint(equalTo: form.centerXAnchor).isActive = true
        
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.topAnchor.constraint(equalTo: userNameField.bottomAnchor, constant: 20.0).isActive = true
        passwordField.widthAnchor.constraint(equalTo: userNameField.widthAnchor).isActive = true
        passwordField.centerXAnchor.constraint(equalTo: userNameField.centerXAnchor).isActive = true
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20.0).isActive = true
        loginButton.widthAnchor.constraint(equalTo: userNameField.widthAnchor).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: userNameField.centerXAnchor).isActive = true
        
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 5.0).isActive = true
        registerButton.widthAnchor.constraint(equalTo: userNameField.widthAnchor).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: userNameField.centerXAnchor).isActive = true
        registerButton.bottomAnchor.constraint(equalTo: form.bottomAnchor, constant: -15.0).isActive = true
    }
    
    // MARK: UIView
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        return userNameField.becomeFirstResponder()
    }
    
    // MARK: Handlers
    
    @objc fileprivate func handleButtonPress(_ button: UIButton) {
        if button == loginButton {
            delegate?.loginView(self, didPressLoginButtonWithUserName: userNameField.text!,
                                password: passwordField.text!)
        } else {
            delegate?.loginView(self, didPressRegisterButtonWithUserName: userNameField.text!,
                                password: passwordField.text!)
        }
    }
    
    @objc fileprivate func handleFieldsChange() {
        if userNameField.text?.count ?? 0 < minUserNameLength ||
            passwordField.text?.count ?? 0 < minPasswordLength {
            loginButton.isEnabled = false
            registerButton.isEnabled = false
        } else {
            loginButton.isEnabled = true
            registerButton.isEnabled = true
        }
    }
    
    @objc fileprivate func switchFieldFocus(_ field: UITextField) {
        if field == userNameField {
            passwordField.becomeFirstResponder()
        } else {
            userNameField.becomeFirstResponder()
        }
    }
}

// MARK: Private extensions

private extension UITextField {
    static func defaultField(forLoginView loginView: LoginView) -> UITextField {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.textContentType = UITextContentType("")
        field.addTarget(loginView, action: #selector(LoginView.handleFieldsChange), for: .editingChanged)
        field.addTarget(loginView, action: #selector(LoginView.switchFieldFocus(_:)), for: .editingDidEndOnExit)
        return field
    }
}

private extension UIButton {
    static func defaultButton(forLoginView loginView: LoginView) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.red, for: .normal)
        btn.setTitleColor(.gray, for: .disabled)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        btn.isEnabled = false
        btn.addTarget(loginView, action: #selector(LoginView.handleButtonPress(_:)), for: .touchUpInside)
        return btn
    }
}
