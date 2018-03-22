//
//  Created by Ivano Bilenchi on 22/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import Foundation

class AuthServerAPI {
    
    // MARK: Public properties
    
    let serverName: String
    let port: UInt
    let useHTTPS: Bool
    
    var server: String {
        return "\(useHTTPS ? "https" : "http")://\(serverName):\(port)"
    }
    
    // MARK: Lifecycle
    
    init(serverName: String = "localhost", port: UInt = 80, useHTTPS: Bool = false) {
        self.serverName = serverName
        self.port = port
        self.useHTTPS = useHTTPS
    }
    
    // MARK: Public methods
    
    func login(withCredentials credentials: LoginCredentials) {

        let request = URLRequest.multipart(
            url: URL(string: server + "/login")!,
            parts: [
                .parameter(key: "user", value: credentials.userName),
                .parameter(key: "pass", value: credentials.password)
            ]
        )
        URLSession.debug(request)
    }
    
    func register(withCredentials credentials: RegistrationCredentials) {
        let request = URLRequest.multipart(
            url: URL(string: server + "/register")!,
            parts: [
                .parameter(key: "user", value: credentials.userName),
                .parameter(key: "pass", value: credentials.password)
            ]
        )
        URLSession.debug(request)
    }
}

// MARK: Private

private extension URLSession {
    
    static func debug(_ request: URLRequest) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
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
