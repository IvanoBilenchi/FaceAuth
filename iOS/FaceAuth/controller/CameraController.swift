//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import UIKit

class CameraController: UIViewController, FaceDetectorDelegate, CameraViewDelegate {
    
    // MARK: Private properties
    
    private let detector: FaceDetector
    private var cameraView: CameraView { return view as! CameraView }
    private lazy var photoView: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 200.0, height: 200.0)))
    
    // MARK: Lifecycle
    
    init(detector: FaceDetector) {
        self.detector = detector
        super.init(nibName: nil, bundle: nil)
        cameraView.delegate = self
        detector.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        self.view = CameraView(session: detector.session)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        detector.startDetecting()
    }
    
    // MARK: FaceDetectorDelegate
    
    func faceDetector(_ faceDetector: FaceDetector, didDetectFace faceObservation: FaceObservation) {
        cameraView.setFaceBoundingBox(faceObservation.boundingBox)
        cameraView.setFaceLandmarks(faceObservation.landmarks)
        cameraView.setCameraButtonEnabled(true)
    }
    
    func faceDetectorStoppedDetectingFace(_ faceDetector: FaceDetector) {
        cameraView.removeFaceBoundingBox()
        cameraView.setCameraButtonEnabled(false)
    }
    
    // MARK: CameraViewDelegate
    
    func cameraViewDidPressCaptureButton(_ cameraView: CameraView) {
        if photoView.superview == nil { view.addSubview(photoView) }
        photoView.image = detector.lastObservation?.image
    }
}
