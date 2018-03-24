//
//  Created by Ivano Bilenchi on 22/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import Foundation

struct LoginCredentials {
    let userName: String
    let password: String
    var image: UIImage
}

struct RegistrationCredentials {
    let userName: String
    let password: String
    let modelPath: String
}

class CredentialsBuilder {
    
    private let userName: String
    private let password: String
    private var image: UIImage?
    private var modelPath: String?
    
    init(userName: String, password: String) {
        self.userName = userName
        self.password = password
    }
    
    @discardableResult func set(image: UIImage) -> CredentialsBuilder { self.image = image; return self }
    @discardableResult func set(modelPath: String) -> CredentialsBuilder { self.modelPath = modelPath; return self }
    
    func buildLoginCredentials() -> LoginCredentials? {
        guard let image = image else { return nil }
        return LoginCredentials(userName: userName, password: password, image: image)
    }
    
    func buildRegistrationCredentials() -> RegistrationCredentials? {
        guard let modelPath = modelPath else { return nil }
        return RegistrationCredentials(userName: userName, password: password, modelPath: modelPath)
    }
}
