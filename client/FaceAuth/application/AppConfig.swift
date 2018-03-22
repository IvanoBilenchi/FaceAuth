//
//  Created by Ivano Bilenchi on 22/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import Foundation

struct Config {
    struct Security {
        static let minUserNameLength: UInt = 8
        static let minPasswordLength: UInt = 8
    }
    
    struct Server {
        static let name = "MacBook-Pro-di-Ivano.local"
        static let port: UInt = 5000
        static let useHTTPS = false
    }
}
