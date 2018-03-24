//
//  Created by Ivano Bilenchi on 23/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import Foundation

// MARK: Private

private typealias API = Config.API

private struct HTTPResponseCode {
    static let ok = 200
    static let unauthorized = 401
}

// MARK: Public

enum LoginResponse {
    case loggedIn(userName: String, name: String, description: String)
    case wrongUserPass
    case unrecognizedFace
    case error(message: String)
    
    static func from(response: HTTPURLResponse, data: Data? = nil) -> LoginResponse {
        var loginResponse: LoginResponse? = nil
        
        switch response.statusCode {
        case HTTPResponseCode.ok:
            if let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: String],
                json[API.Response.keyInfo] == API.Response.valSuccess,
                let userName = json[API.Response.keyUserName],
                let name = json[API.Response.keyName],
                let description = json[API.Response.keyDescription] {
                loginResponse = .loggedIn(userName: userName, name: name, description: description)
            }
        case HTTPResponseCode.unauthorized:
            if let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: String],
                let reason = json[Config.API.Response.keyInfo] {
                
                switch reason {
                case API.Response.valInvalidUserPass: loginResponse = .wrongUserPass
                case API.Response.valUnrecognizedFace: loginResponse = .unrecognizedFace
                default: break
                }
            }
        default:
            break
        }
        
        if loginResponse == nil {
            let message = data.flatMap({ String(data: $0, encoding: .utf8) }) ?? ""
            loginResponse = .error(message: "Status code: \(response.statusCode) - Data: \(message)")
        }
        
        return loginResponse!
    }
}

enum RegistrationResponse {
    case registered
    case alreadyRegistered
    case error(message: String)
    
    static func from(response: HTTPURLResponse, data: Data? = nil) -> RegistrationResponse {
        var registrationResponse: RegistrationResponse?
        
        if response.statusCode == HTTPResponseCode.ok,
            let data = data,
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: String],
            let info = json[Config.API.Response.keyInfo] {
            
            switch info {
            case API.Response.valSuccess: registrationResponse = .registered
            case API.Response.valAlreadyRegistered: registrationResponse = .alreadyRegistered
            default: break
            }
        }
        
        if registrationResponse == nil {
            let message = data.flatMap({ String(data: $0, encoding: .utf8) }) ?? ""
            registrationResponse = .error(message: "Status code: \(response.statusCode) - Data: \(message)")
        }
        
        return registrationResponse!
    }
}

enum GenericResponse {
    case ok
    case error(message: String)
    
    static func from(response: HTTPURLResponse, data: Data? = nil) -> GenericResponse {
        var genericResponse: GenericResponse?
        
        if response.statusCode == HTTPResponseCode.ok,
            let data = data,
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: String],
            json[Config.API.Response.keyInfo] == API.Response.valSuccess {
            genericResponse = .ok
        }
        
        if genericResponse == nil {
            let message = data.flatMap({ String(data: $0, encoding: .utf8) }) ?? ""
            genericResponse = .error(message: "Status code: \(response.statusCode) - Data: \(message)")
        }
        
        return genericResponse!
    }
}
