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
        layer.borderColor = UIColor.red.cgColor
        layer.strokeColor = UIColor.yellow.cgColor
        layer.lineWidth = 2.0
        layer.cornerRadius = 5.0
        layer.borderWidth = 4.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass { return CAShapeLayer.self }
    
    // MARK: Public methods
    
    func drawLandmarks(_ landmarks: [[CGPoint]]) {
        let mutablePath = CGMutablePath()
        
        for landmark in landmarks {
            guard let firstPoint = landmark.first else { return }
            
            let path = UIBezierPath()
            path.move(to: firstPoint)
            
            for point in landmark {
                path.addLine(to: point)
                path.move(to: point)
            }
            
            path.addLine(to: firstPoint)
            mutablePath.addPath(path.cgPath)
        }
        
        shapeLayer.path = mutablePath
    }
    
    func removeAllLandmarks() {
        shapeLayer.path = nil
    }
}
