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
            if mode == .enroll {
                recognizer = FaceRecognizer()
                photoView.image = nil
                photoView.isHidden = false
                navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done,
                                                                         target: self,
                                                                         action: #selector(handleDoneButton))
            } else {
                photoView.isHidden = true
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    // MARK: Private properties
    
    private let detector: FaceDetector
    private var recognizer: FaceRecognizer?
    
    private var cameraView: CameraView { return view as! CameraView }
    
    private lazy var photoView: UIImageView = {
        let imgView = UIImageView(frame: .zero)
        imgView.backgroundColor = .black
        imgView.layer.borderWidth = 3.0
        imgView.layer.borderColor = UIColor.white.cgColor
        return imgView
    }()
    
    // MARK: Lifecycle
    
    init(detector: FaceDetector) {
        self.detector = detector
        super.init(nibName: nil, bundle: nil)
        cameraView.delegate = self
        detector.delegate = self
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        view.addSubview(photoView)
    }
    
    private func setupConstraints() {
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        photoView.heightAnchor.constraint(equalTo: photoView.widthAnchor).isActive = true
        photoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        photoView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        view = CameraView(session: detector.session)
    }
    
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
                photoView.image = recognizer.lastTrainingImage
                refreshDoneButton()
            }
        } else {
            delegate?.faceController(self, didCaptureFace: FaceRecognizer.processedImage(from: observation))
        }
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
