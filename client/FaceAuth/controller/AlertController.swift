//
//  Created by Ivano Bilenchi on 23/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import Foundation

class AlertController {
    
    // MARK: Private properties
    
    weak var rootViewController: UIViewController?
    
    // MARK: Public methods
    
    func showUserDetailsEntryUI(_ completionHandler: @escaping (_ name: String, _ description: String) -> Void) {
        let alert = UIAlertController(title: "🖋 Registration successful", message: "\nPlease fill in your details.", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {
            $0.placeholder = "Name"
            $0.autocapitalizationType = .words
        })
        alert.addTextField(configurationHandler: {
            $0.placeholder = "Description"
            $0.autocapitalizationType = .sentences
        })
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            completionHandler(alert.textFields![0].text ?? "", alert.textFields![1].text ?? "")
        }))
        
        rootViewController?.present(alert, animated: true)
    }
    
    func showLoggedInMenu(userName: String, name: String, description: String, deleteHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "👤 Hello, \(name)", message: "\nUser name: \(userName)\n\nDescription: \(description)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Bye", style: .default))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in deleteHandler() }))
        
        rootViewController?.present(alert, animated: true)
    }
    
    func showErrorAlert(withMessage message: String) {
        showAlert(withTitle: "🤔 Whoops", message: message, buttonTitle: "Oh come on")
    }
    
    func showAlert(withTitle title: String, message: String, buttonTitle: String, handler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: "\n" + message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { _ in handler?() }))
        rootViewController?.present(alert, animated: true)
    }
}
