//
//  Created by Ivano Bilenchi on 23/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import Foundation

class AlertController: AuthServerAPIDelegate {
    
    // MARK: Private properties
    
    weak var rootViewController: UIViewController?
    
    // MARK: AuthServerAPIDelegate
    
    func api(_ api: AuthServerAPI, didReceiveLoginResponse response: LoginResponse) {
        guard let rootViewController = rootViewController else { return }
        
        let title: String
        let message: String
        let actions: [UIAlertAction]
        
        switch response {
        case .loggedIn(let userName, let name, let description):
            title = "👤 Hello, " + name
            message = "\nUser name: \(userName)\n\nDescription: \(description)"
            actions = [UIAlertAction(title: "Bye", style: .default, handler: nil)]
            
        case .unrecognizedFace:
            title = "👁️ You're lying"
            message = "\nWho are you?"
            actions = [UIAlertAction(title: "You got me", style: .default, handler: nil)]
            
        case .wrongUserPass:
            title = "⛔ Access denied"
            message = "\nInvalid username/password combination."
            actions = [UIAlertAction(title: "Ok", style: .default, handler: nil)]
            
        case .error(let msg):
            title = "🤔 Whoops"
            message = "\n" + msg
            actions = [UIAlertAction(title: "Oh come on", style: .default, handler: nil)]
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach({ alert.addAction($0) })
        rootViewController.present(alert, animated: true, completion: nil)
    }
    
    func api(_ api: AuthServerAPI, didReceiveRegistrationResponse response: RegistrationResponse) {
        guard let rootViewController = rootViewController else { return }
        
        let title: String
        let message: String
        let actions: [UIAlertAction]
        
        switch response {
        case .registered:
            title = "✅ Registration successful"
            message = "\nYou may now login."
            actions = [UIAlertAction(title: "Ok", style: .default, handler: nil)]
            
        case .alreadyRegistered:
            title = "❌ Username in use"
            message = "\nThis username is already taken. Please choose a new username."
            actions = [UIAlertAction(title: "I'm so lucky", style: .default, handler: nil)]
            
        case .error(let msg):
            title = "🤔 Whoops"
            message = "\n" + msg
            actions = [UIAlertAction(title: "Oh come on", style: .default, handler: nil)]
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach({ alert.addAction($0) })
        rootViewController.present(alert, animated: true, completion: nil)
    }
}
