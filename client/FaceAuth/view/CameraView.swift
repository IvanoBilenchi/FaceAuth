//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import UIKit

protocol CameraViewDelegate: class {
    func cameraViewDidPressCaptureButton(_ cameraView: CameraView)
    func cameraViewDidPressDiscardButton(_ cameraView: CameraView)
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
    
    private lazy var bottomBar: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        addSubview(view)
        view.contentView.addSubview(cameraButton)
        view.contentView.addSubview(photoPreview)
        view.contentView.addSubview(discardButton)
        return view
    }()
    
    private lazy var faceView: FaceView = {
        let view = FaceView(frame: .zero)
        view.alpha = 0.0
        addSubview(view)
        return view
    }()
    
    private lazy var cameraButton: CameraButton = {
        let button = CameraButton(frame: .zero)
        button.addTarget(self, action: #selector(handleCameraButtonPress), for: .touchUpInside)
        return button
    }()
    
    private lazy var discardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Discard", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        button.addTarget(self, action: #selector(handleDiscardButtonPress), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoPreview: UIImageView = {
        let imgView = UIImageView(frame: .zero)
        imgView.backgroundColor = .black
        imgView.layer.borderWidth = 3.0
        imgView.layer.borderColor = UIColor.white.cgColor
        return imgView
    }()
    
    // MARK: Lifecycle
    
    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        cameraLayer.session = session
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        let barSize: CGFloat = 100.0
        let buttonSize: CGFloat = 80.0
        
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                       constant: -barSize).isActive = true
        bottomBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottomBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        photoPreview.translatesAutoresizingMaskIntoConstraints = false
        photoPreview.widthAnchor.constraint(equalToConstant: barSize).isActive = true
        photoPreview.heightAnchor.constraint(equalToConstant: barSize).isActive = true
        photoPreview.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        photoPreview.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        
        discardButton.translatesAutoresizingMaskIntoConstraints = false
        discardButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                             constant: -30.0).isActive = true
        discardButton.centerYAnchor.constraint(equalTo: photoPreview.centerYAnchor).isActive = true
        
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        cameraButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                             constant: (buttonSize - barSize) / 2.0).isActive = true
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
    
    func setPreview(_ image: UIImage?) {
        photoPreview.image = image
        photoPreview.isHidden = image == nil
        discardButton.isHidden = image == nil
    }
    
    // MARK: Handlers
    
    @objc private func handleCameraButtonPress() {
        delegate?.cameraViewDidPressCaptureButton(self)
    }
    
    @objc private func handleDiscardButtonPress() {
        delegate?.cameraViewDidPressDiscardButton(self)
    }
}
