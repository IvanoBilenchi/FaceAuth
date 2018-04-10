## FaceAuth

![Login video](login.gif)

### Description

Enhancing weak client-server user authentication with facial recognition. iOS client (Swift + Objective-C++) &harr; Python server.
Face and landmarks detection courtesy of [Vision.framework](https://developer.apple.com/documentation/vision), recognition via [OpenCV](https://opencv.org). Pictures are heavily preprocessed in order to reduce noise, remove the background and align them based on the detected position of the pupils. The computed face model is AES256 encrypted via the user's password, and it is decrypted only upon login. Passwords are hashed and salted, of course.

Project for the *Data Security* exam. It is just a POC of the technique hacked up in relatively little time, so don't expect it to be secure or up to any standard.

### Usage

- Edit [AppConfig.swift](client/FaceAuth/application/AppConfig.swift) and [cert_gen.sh](server/cert_gen.sh) with your local server name and cert info.
- Install OpenCV locally: `brew install opencv`
- Install required Python packages via `requirements.txt`. If you're using virtualenv, you may need [additional configuration](https://stackoverflow.com/a/12043136) to make OpenCV work.
- Get or compile [opencv2.framework](https://opencv.org) for iOS (tested 3.4.1). It must come with the `contrib` module.
- Put `opencv2.framework` in the `client/External` dir.
- Run the server via [start.sh](server/start.sh).
- Run the client on your iOS device.
- Have fun.
