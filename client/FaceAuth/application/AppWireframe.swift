//
//  Created by Ivano Bilenchi on 22/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import Foundation

class AppWireframe: LoginWireframe {
    
    // MARK: Private properties
    
    private let f: AppFactory
    
    // MARK: Lifecycle
    
    init(appFactory: AppFactory) {
        self.f = appFactory
    }
    
    // MARK: LoginWireframe
    
    func showCameraController(withMode mode: CameraController.Mode) {
        f.cameraController.mode = mode
        f.navigationController.pushViewController(f.cameraController, animated: true)
    }
}
