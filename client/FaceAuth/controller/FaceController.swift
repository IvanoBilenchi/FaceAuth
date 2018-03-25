//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import UIKit

protocol FaceControllerDelegate: class {
    func faceController(_ faceController: FaceController, didCaptureFace faceImage: UIImage)
    func faceController(_ faceController: FaceController, didTrainModel modelPath: String, lastCapturedFace: UIImage)
}

class FaceController: UIViewController, FaceDetectorDelegate, CameraViewDelegate {
    
    enum Mode {
        case enroll
        case recognize
    }
    
    // MARK: Public properties
    
    weak var delegate: FaceControllerDelegate?
    
    var mode: Mode = .recognize {
        didSet {
            cameraView.setPreview(nil)
            
            if mode == .enroll {
                recognizer = FaceRecognizer()
                navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done,
                                                                         target: self,
                                                                         action: #selector(handleDoneButton))
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    // MARK: Private properties
    
    private let detector: FaceDetector
    private var recognizer: FaceRecognizer?
    private let cameraView: CameraView
    
    // MARK: Lifecycle
    
    init(detector: FaceDetector, cameraView: CameraView) {
        self.detector = detector
        self.cameraView = cameraView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    
    override func loadView() { view = cameraView }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detector.startDetecting()
        refreshDoneButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        detector.stopDetecting()
    }
    
    // MARK: FaceDetectorDelegate
    
    func faceDetector(_ faceDetector: FaceDetector, didDetectFace faceObservation: FaceObservation) {
        cameraView.setFaceBoundingBox(faceObservation.boundingBox)
        cameraView.setEyes(left: faceObservation.leftEye, right: faceObservation.rightEye)
        cameraView.setCameraButtonEnabled(true)
    }
    
    func faceDetectorStoppedDetectingFace(_ faceDetector: FaceDetector) {
        cameraView.removeFaceBoundingBox()
        cameraView.setCameraButtonEnabled(false)
    }
    
    // MARK: CameraViewDelegate
    
    func cameraViewDidPressCaptureButton(_ cameraView: CameraView) {
        guard let observation = detector.lastObservation else { return }
        
        if mode == .enroll {
            if let recognizer = recognizer {
                recognizer.add(observation)
                cameraView.setPreview(recognizer.lastTrainingImage)
                refreshDoneButton()
            }
        } else {
            delegate?.faceController(self, didCaptureFace: FaceRecognizer.processedImage(from: observation))
        }
    }
    
    func cameraViewDidPressDiscardButton(_ cameraView: CameraView) {
        guard let recognizer = recognizer else { return }
        recognizer.discardLastFaceObservation()
        cameraView.setPreview(recognizer.lastTrainingImage)
        refreshDoneButton()
    }
    
    // MARK: Handlers
    
    @objc private func handleDoneButton() {
        guard let recognizer = recognizer else { return }
        let modelPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.path + "/model.yml"
        
        recognizer.train()
        recognizer.serializeModelToFile(atPath: modelPath)
        delegate?.faceController(self, didTrainModel: modelPath, lastCapturedFace: recognizer.lastTrainingImage!)
    }
    
    private func refreshDoneButton() {
        navigationItem.rightBarButtonItem?.isEnabled = (recognizer?.numberOfTrainingSamples ?? 0) >= 10
    }
}
