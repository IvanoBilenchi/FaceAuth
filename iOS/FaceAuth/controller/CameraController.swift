//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import UIKit

class CameraController: UIViewController, FaceDetectorDelegate {
    
    // MARK: Private properties
    
    private let detector: FaceDetector
    private var cameraView: CameraView { return view as! CameraView }
    
    // MARK: Lifecycle
    
    init(detector: FaceDetector) {
        self.detector = detector
        super.init(nibName: nil, bundle: nil)
        detector.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    func setupConstraints() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        self.view = CameraView(session: detector.session)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        detector.startDetecting()
    }
    
    // MARK: FaceDetectorDelegate
    
    func faceDetector(_ faceDetector: FaceDetector, didDetectFace faceObservation: FaceObservation) {
        cameraView.setFaceBoundingBox(faceObservation.boundingBox)
        cameraView.setFaceLandmarks(faceObservation.landmarks)
    }
    
    func faceDetector(_ faceDetector: FaceDetector, didDetectFaceWithNormalizedBoundingBox boundingBox: CGRect, landmarks: [[CGPoint]]) {
        cameraView.setFaceBoundingBox(boundingBox)
        cameraView.setFaceLandmarks(landmarks)
    }
    
    func faceDetectorStoppedDetectingFace(_ faceDetector: FaceDetector) {
        cameraView.removeFaceBoundingBox()
    }
}
