//
//  Created by Ivano Bilenchi on 12/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import AVFoundation
import CoreImage
import UIKit

class FaceObservation {
    
    // Public properties
    
    let boundingBox: CGRect
    let landmarks: [[CGPoint]]
    
    lazy var image: UIImage = {
        let ciImage = CIImage(cvPixelBuffer: buffer).cropped(to: denormalizedBoundingBox)
        return UIImage(cgImage: FaceObservation.ciContext.createCGImage(ciImage, from: ciImage.extent)!,
                       scale: 1.0,
                       orientation: UIImageOrientation.up).normalizedForFaceRecognition()
    }()
    
    // Private properties
    
    static let ciContext = CIContext()
    private let buffer: CVPixelBuffer
    private let bufferWidth: CGFloat
    private let bufferHeight: CGFloat
    
    private var denormalizedBoundingBox: CGRect {
        var box = CGRect(x: boundingBox.origin.x * bufferWidth,
                         y: (1 - boundingBox.origin.y - boundingBox.size.height) * bufferHeight,
                         width: boundingBox.size.width * bufferWidth,
                         height: boundingBox.size.height * bufferHeight)
        
        // Make the box square
        if box.size.width > box.size.height {
            box = box.insetBy(dx: 0.0, dy: (box.size.height - box.size.width) / 2.0)
        } else {
            box = box.insetBy(dx: (box.size.width - box.size.height) / 2.0, dy: 0.0)
        }
        
        return box
    }
    
    // Lifecycle
    
    init(buffer: CVPixelBuffer, boundingBox: CGRect, landmarks: [[CGPoint]]) {
        self.buffer = buffer
        self.boundingBox = boundingBox
        self.landmarks = landmarks
        self.bufferWidth = CGFloat(CVPixelBufferGetWidth(buffer))
        self.bufferHeight = CGFloat(CVPixelBufferGetHeight(buffer))
    }
}
