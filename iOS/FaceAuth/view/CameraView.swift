//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import UIKit

protocol CameraViewDelegate: class {
    func cameraViewDidPressCaptureButton(_ cameraView: CameraView)
}

class CameraView: UIView {
    
    // MARK: Public properties
    
    weak var delegate: CameraViewDelegate?
    
    // MARK: Private properties
    
    private var cameraLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    private var session: AVCaptureSession {
        return cameraLayer.session!
    }
    
    private lazy var faceView: FaceView = FaceView(frame: .zero)
    
    private lazy var cameraButton: CameraButton = CameraButton(frame: .zero)
    
    // MARK: Lifecycle
    
    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        cameraLayer.session = session
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        // faceView
        faceView.alpha = 0.0
        addSubview(faceView)
        
        // photoCaptureButton
        cameraButton.addTarget(self, action: #selector(handleCameraButtonPress), for: .touchUpInside)
        addSubview(cameraButton)
    }
    
    private func setupConstraints() {
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        cameraButton.heightAnchor.constraint(equalTo: cameraButton.widthAnchor).isActive = true
        cameraButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10.0).isActive = true
        cameraButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    // MARK: UIView
    
    override class var layerClass: AnyClass { return AVCaptureVideoPreviewLayer.self }
    
    // MARK: Public methods
    
    func setFaceBoundingBox(_ boundingBox: CGRect) {
        let previewSize = cameraLayer.frame.size
        let rect = CGRect(x: boundingBox.origin.x * previewSize.width,
                          y: boundingBox.origin.y * previewSize.height,
                          width: boundingBox.size.width * previewSize.width,
                          height: boundingBox.size.height * previewSize.height)
        
        if faceView.alpha == 0.0 {
            faceView.frame = rect
            
            UIView.animate(withDuration: 0.2, animations: {
                self.faceView.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.05, animations: {
                self.faceView.frame = rect
            })
        }
    }
    
    func removeFaceBoundingBox() {
        UIView.animate(withDuration: 0.2) {
            self.faceView.alpha = 0.0
        }
    }
    
    func setEyes(left: CGPoint, right: CGPoint) {
        faceView.drawLandmarks(leftEye: cameraLayer.layerPointConverted(fromCaptureDevicePoint: left),
                               rightEye: cameraLayer.layerPointConverted(fromCaptureDevicePoint: right))
    }
    
    func setCameraButtonEnabled(_ enabled: Bool) {
        cameraButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.2) {
            self.cameraButton.alpha = enabled ? 1.0 : 0.5
        }
    }
    
    // MARK: Private methods
    
    @objc private func handleCameraButtonPress() {
        delegate?.cameraViewDidPressCaptureButton(self)
    }
}
