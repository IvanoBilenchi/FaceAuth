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
    
    struct API {
        struct Server {
            static let name = "MacBook-Pro-di-Ivano.local"
            static let port: UInt = 5000
            static let useHTTPS = false
        }
        
        struct Path {
            static let login = "/login"
            static let registration = "/register"
        }
        
        struct Request {
            static let keyUserName = "user"
            static let keyPassword = "pass"
            static let keyName = "name"
            static let keyDescription = "desc"
            
            struct Face {
                static let key = "face"
                static let mime = "image/png"
                static let fileName = "face.png"
            }
            
            struct Model {
                static let key = "model"
                static let mime = "application/x-yaml"
                static let fileName = "model.yml"
            }
        }
        
        struct Response {
            static let keyUserName = Request.keyUserName
            static let keyName = Request.keyName
            static let keyDescription = Request.keyDescription
            static let keyInfo = "info"
            
            static let valSuccess = "ok"
            static let valInvalidRequest = "invalid_request"
            
            static let valAlreadyRegistered = "already_registered"
            static let valCouldNotAddUser = "could_not_add_user"
            
            static let valInvalidUserPass = "invalid_user_pass"
            static let valUnrecognizedFace = "unrecognized_face"
        }
    }
}
