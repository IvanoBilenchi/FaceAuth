//
//  Created by Ivano Bilenchi on 11/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import UIKit

class FaceView: UIView {
    
    // MARK: Private properties
    
    private var shapeLayer: CAShapeLayer { return layer as! CAShapeLayer }
    
    // MARK: UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        let layer = shapeLayer
        layer.borderColor = UIColor.red.withAlphaComponent(0.7).cgColor
        layer.strokeColor = UIColor.yellow.withAlphaComponent(0.7).cgColor
        layer.lineWidth = 2.0
        layer.cornerRadius = 10.0
        layer.borderWidth = 4.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass { return CAShapeLayer.self }
    
    // MARK: Public methods
    
    func drawLandmarks(leftEye: CGPoint, rightEye: CGPoint) {
        let mutablePath = CGMutablePath()
        
        for eye in [leftEye, rightEye] {
            let rect = CGRect(center: eye, size: CGSize(width: 5.0, height: 5.0))
            let path = UIBezierPath(ovalIn: rect)
            mutablePath.addPath(path.cgPath)
        }
        
        shapeLayer.path = mutablePath
    }
    
    func removeAllLandmarks() {
        shapeLayer.path = nil
    }
}

private extension CGRect {
    init(center: CGPoint, size: CGSize) {
        var origin = center
        origin.x -= size.width / 2.0
        origin.y -= size.height / 2.0
        self.init(origin: origin, size: size)
    }
}
