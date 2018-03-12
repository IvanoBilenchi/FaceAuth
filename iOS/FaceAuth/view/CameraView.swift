//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import UIKit

class CameraView: UIView {
    
    // MARK: Private properties
    
    private var cameraLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    private var session: AVCaptureSession {
        return cameraLayer.session!
    }
    
    private lazy var faceView: FaceView = FaceView(frame: .zero)
    
    // MARK: Lifecycle
    
    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        cameraLayer.session = session
        faceView.alpha = 0.0
        addSubview(faceView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func setFaceLandmarks(_ landmarks: [[CGPoint]]) {
        let normalizedLandmarks = landmarks.map({ $0.map({ cameraLayer.layerPointConverted(fromCaptureDevicePoint: $0) }) })
        faceView.drawLandmarks(normalizedLandmarks)
    }
}
