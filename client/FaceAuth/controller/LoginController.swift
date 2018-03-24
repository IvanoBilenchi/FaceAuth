//
//  Created by Ivano Bilenchi on 21/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
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
    
    // MARK: Public methods
    
    func setWaitingForResponse(_ waiting: Bool) {
        loginView.isEnabled = !waiting
        UIApplication.shared.isNetworkActivityIndicatorVisible = waiting
    }
}
