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
        layer.borderColor = UIColor.red.cgColor
        layer.cornerRadius = 5.0
        layer.borderWidth = 4.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass { return CAShapeLayer.self }
    
    // MARK: Public methods
    
    func drawLandmark(_ points: [CGPoint]) {
        guard let firstPoint = points.first else { return }
        
        let newLayer = CAShapeLayer()
        newLayer.strokeColor = UIColor.yellow.cgColor
        newLayer.lineWidth = 2.0
        
        let path = UIBezierPath()
        path.move(to: firstPoint)
        
        for point in points {
            path.addLine(to: point)
            path.move(to: point)
        }
        
        path.addLine(to: firstPoint)
        
        newLayer.path = path.cgPath
        shapeLayer.addSublayer(newLayer)
    }
    
    func removeAllLandmarks() {
        shapeLayer.sublayers?.removeAll()
    }
}
