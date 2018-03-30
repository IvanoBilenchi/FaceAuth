//
//  Created by Ivano Bilenchi on 22/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import Foundation

protocol AuthServerAPIDelegate: class {
    func api(_ api: AuthServerAPI, didReceiveLoginResponse response: LoginResponse)
    func api(_ api: AuthServerAPI, didReceiveRegistrationResponse response: RegistrationResponse)
    func api(_ api: AuthServerAPI, didReceiveUpdateResponse response: GenericResponse)
    func api(_ api: AuthServerAPI, didReceiveDeleteResponse response: GenericResponse)
}

class AuthServerAPI: NSObject, URLSessionDelegate {
    
    private typealias API = Config.API
    
    // MARK: Public properties
    
    let hostName: String
    let port: UInt
    let useHTTPS: Bool
    
    weak var delegate: AuthServerAPIDelegate?
    
    var server: String {
        return "\(useHTTPS ? "https" : "http")://\(hostName):\(port)"
    }
    
    // MARK: Lifecycle
    
    init(hostName: String = "localhost", port: UInt = 80, useHTTPS: Bool = false) {
        self.hostName = hostName
        self.port = port
        self.useHTTPS = useHTTPS
    }
    
    // MARK: Public methods
    
    func login(withCredentials credentials: LoginCredentials,
               completionHandler: ((LoginResponse) -> Void)? = nil) {
        
        let request = loginRequest(withUrl: URL(string: server + API.Path.login)!,
                                   credentials: credentials)
        
        session().dataTask(with: request) { data, response, error in
            let loginResponse: LoginResponse
            
            if let response = response as? HTTPURLResponse, error == nil {
                loginResponse = LoginResponse.from(response: response, data: data)
            } else {
                loginResponse = .error(message: error?.localizedDescription ?? "")
            }
            
            DispatchQueue.main.async {
                completionHandler?(loginResponse)
                self.delegate?.api(self, didReceiveLoginResponse: loginResponse)
            }
        }.resume()
    }
    
    func register(withCredentials credentials: RegistrationCredentials,
                  completionHandler: ((RegistrationResponse) -> Void)? = nil) {
        
        let request = URLRequest.multipart(
            url: URL(string: server + API.Path.registration)!,
            parts: [
                .parameter(key: API.Request.keyUserName, value: credentials.userName),
                .parameter(key: API.Request.keyPassword, value: credentials.password),
                .file(key: API.Request.Model.key,
                      data: (try? Data(contentsOf: URL(fileURLWithPath: credentials.modelPath))) ?? Data(),
                      mime: API.Request.Model.mime,
                      fileName: API.Request.Model.fileName)
            ]
        )
        
        session().dataTask(with: request) { data, response, error in
            let registrationResponse: RegistrationResponse
            
            if let response = response as? HTTPURLResponse, error == nil {
                registrationResponse = RegistrationResponse.from(response: response, data: data)
            } else {
                registrationResponse = .error(message: error?.localizedDescription ?? "")
            }
            
            DispatchQueue.main.async {
                completionHandler?(registrationResponse)
                self.delegate?.api(self, didReceiveRegistrationResponse: registrationResponse)
            }
        }.resume()
    }
    
    func updateDetails(withCredentials credentials: LoginCredentials,
                       name: String,
                       description: String,
                       completionHandler: ((GenericResponse) -> Void)? = nil) {
        
        let request = loginRequest(withUrl: URL(string: server + API.Path.update)!,
                                   credentials: credentials,
                                   additionalParameters: [
                                    .parameter(key: API.Request.keyName, value: name),
                                    .parameter(key: API.Request.keyDescription, value: description)
            ])
        
        session().dataTask(with: request) { data, response, error in
            let updateResponse: GenericResponse
            
            if let response = response as? HTTPURLResponse, error == nil {
                updateResponse = GenericResponse.from(response: response, data: data)
            } else {
                updateResponse = .error(message: error?.localizedDescription ?? "")
            }
            
            DispatchQueue.main.async {
                completionHandler?(updateResponse)
                self.delegate?.api(self, didReceiveUpdateResponse: updateResponse)
            }
        }.resume()
    }
    
    func delete(withCredentials credentials: LoginCredentials,
                completionHandler: ((GenericResponse) -> Void)? = nil) {
        
        let request = loginRequest(withUrl: URL(string: server + API.Path.delete)!,
                                   credentials: credentials)
        
        session().dataTask(with: request) { data, response, error in
            let deleteResponse: GenericResponse
            
            if let response = response as? HTTPURLResponse, error == nil {
                deleteResponse = GenericResponse.from(response: response, data: data)
            } else {
                deleteResponse = .error(message: error?.localizedDescription ?? "")
            }
            
            DispatchQueue.main.async {
                completionHandler?(deleteResponse)
                self.delegate?.api(self, didReceiveDeleteResponse: deleteResponse)
            }
        }.resume()
    }
    
    // MARK: URLSessionDelegate
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        // Check via self-signed cert
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust),
            let trust = challenge.protectionSpace.serverTrust,
            let data = NSData(contentsOfFile: Config.API.Server.httpsCert),
            let cert = SecCertificateCreateWithData(nil, data) {
            SecTrustSetAnchorCertificates(trust, [cert] as CFArray)
            completionHandler(.useCredential, URLCredential(trust: trust))
            return
        }
        
        // Fail
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
    
    // MARK: Private methods
    
    private func session() -> URLSession {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    private func loginRequest(withUrl url: URL,
                              credentials: LoginCredentials,
                              additionalParameters: [URLRequest.MultipartContent]? = nil) -> URLRequest {
        var parts: [URLRequest.MultipartContent] = [
            .parameter(key: API.Request.keyUserName, value: credentials.userName),
            .parameter(key: API.Request.keyPassword, value: credentials.password)
        ]
        
        if let additionalParameters = additionalParameters {
            parts.append(contentsOf: additionalParameters)
        }
        
        parts.append(.file(key: API.Request.Face.key,
                           data: UIImagePNGRepresentation(credentials.image)!,
                           mime: API.Request.Face.mime,
                           fileName: API.Request.Face.fileName))
        
        return URLRequest.multipart(url: url, parts: parts)
    }
}

// MARK: Private

private extension URLSession {
    
    static func debug(_ request: URLRequest) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error = \(error!)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("statusCode = \(response.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }.resume()
    }
}

private extension URLRequest {
    
    enum MultipartContent {
        case parameter(key: String, value: String)
        case file(key: String, data: Data, mime: String, fileName: String)
    }
    
    static func multipart(url: URL, parts: [MultipartContent]) -> URLRequest {
        
        // Header
        let boundary = "Boundary-\(UUID().uuidString)"
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Body
        var body = Data()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for part in parts {
            switch part {
                
            case .parameter(let key, let value):
                body.append(boundaryPrefix)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
                
            case .file(let key, let data, let mime, let fileName):
                body.append(boundaryPrefix)
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n")
                body.append("Content-Type: \(mime)\r\n\r\n")
                body.append(data)
                body.append("\r\n")
            }
        }
        
        body.append("--".appending(boundary.appending("--")))
        req.httpBody = body
        
        return req
    }
}

private extension Data {
    mutating func append(_ string: String) {
        append(string.data(using: .utf8, allowLossyConversion: false)!)
    }
}
