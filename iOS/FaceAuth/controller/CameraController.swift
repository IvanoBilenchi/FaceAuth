//
//  Created by Ivano Bilenchi on 08/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import UIKit

class CameraController: UIViewController, FaceDetectorDelegate, CameraViewDelegate {
    
    // MARK: Private properties
    
    private let detector: FaceDetector
    private let recognizer: FaceRecognizer
    private var cameraView: CameraView { return view as! CameraView }
    private lazy var photoView: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 200.0, height: 200.0)))
    
    private lazy var trainingSwitch: UISwitch = {
        let mySwitch = UISwitch(frame: .zero)
        mySwitch.isOn = true
        mySwitch.addTarget(self, action: #selector(handleSwitch(_:)), for: .valueChanged)
        return mySwitch
    }()
    private lazy var outputLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .boldSystemFont(ofSize: 20.0)
        return label
    }()
    
    // MARK: Lifecycle
    
    init(detector: FaceDetector, recognizer: FaceRecognizer) {
        self.detector = detector
        self.recognizer = recognizer
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
        view.addSubview(trainingSwitch)
        view.addSubview(outputLabel)
    }
    
    private func setupConstraints() {
        trainingSwitch.translatesAutoresizingMaskIntoConstraints = false
        trainingSwitch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.0).isActive = true
        trainingSwitch.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10.0).isActive = true
        
        outputLabel.translatesAutoresizingMaskIntoConstraints = false
        outputLabel.topAnchor.constraint(equalTo: trainingSwitch.bottomAnchor, constant: 10.0).isActive = true
        outputLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10.0).isActive = true
    }
    
    // MARK: UIViewController
    
    override func loadView() {
        view = CameraView(session: detector.session)
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
        guard let image = detector.lastObservation?.image else { return }
        if photoView.superview == nil { view.addSubview(photoView) }
        
        if trainingSwitch.isOn {
            recognizer.add(image)
            photoView.image = recognizer.lastTrainingImage()
        } else {
            refreshLabel(recognizer.predict(image))
            photoView.image = recognizer.lastPredictedImage()
        }
    }
    
    // MARK: Private methods
    
    private func refreshLabel(_ correct: Bool) {
        if correct {
            outputLabel.text = "It's you!"
            outputLabel.textColor = .green
        } else {
            outputLabel.text = "Who are you?"
            outputLabel.textColor = .red
        }
        outputLabel.sizeToFit()
    }
    
    @objc private func handleSwitch(_ uiSwitch: UISwitch) {
        if !trainingSwitch.isOn { recognizer.train() }
    }
}
