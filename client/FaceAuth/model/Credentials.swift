//
//  Created by Ivano Bilenchi on 22/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import Foundation

struct LoginCredentials {
    let userName: String
    let password: String
    var image: UIImage?
}

struct RegistrationCredentials {
    let userName: String
    let password: String
    let name: String
    let description: String?
    let modelUrl: URL
}
