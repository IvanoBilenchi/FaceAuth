//
//  Created by Ivano Bilenchi on 22/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import Foundation

class AppWireframe: LoginWireframe, FaceWireframe {
    
    // MARK: Private properties
    
    private let f: AppFactory
    
    // MARK: Lifecycle
    
    init(appFactory: AppFactory) {
        self.f = appFactory
    }
    
    // MARK: LoginWireframe
    
    func showFaceController(withMode mode: FaceController.Mode) {
        f.faceController.mode = mode
        f.navigationController.pushViewController(f.faceController, animated: true)
    }
    
    // MARK: FaceWireframe
    
    func showLoginController() {
        f.navigationController.popViewController(animated: true)
    }
}
