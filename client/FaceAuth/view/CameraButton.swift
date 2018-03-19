//
//  Created by Ivano Bilenchi on 12/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

import UIKit

class CameraButton: UIButton {
    
    // MARK: Private properties
    
    private var circleLayer: CAShapeLayer { return layer as! CAShapeLayer }
    private let buttonLayer: CAShapeLayer = CAShapeLayer()
    private let outerCircleLineWidth: CGFloat = 2.0
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchDown), for: .touchDragEnter)
        addTarget(self, action: #selector(handleTouchUp), for: .touchUpInside)
        addTarget(self, action: #selector(handleTouchUp), for: .touchUpOutside)
        addTarget(self, action: #selector(handleTouchUp), for: .touchCancel)
        addTarget(self, action: #selector(handleTouchUp), for: .touchDragExit)
        
        setupLayers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayers() {
        circleLayer.lineWidth = outerCircleLineWidth
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        
        buttonLayer.fillColor = UIColor.white.cgColor
        circleLayer.addSublayer(buttonLayer)
    }
    
    // MARK: UIView
    
    override class var layerClass: AnyClass { return CAShapeLayer.self }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Draw outer ring
        var inset = outerCircleLineWidth / 2.0
        var path = UIBezierPath(ovalIn: bounds.insetBy(dx: inset, dy: inset))
        circleLayer.path = path.cgPath
        
        // Draw button
        inset = outerCircleLineWidth + 4.0
        path = UIBezierPath(ovalIn: bounds.insetBy(dx: inset, dy: inset))
        buttonLayer.path = path.cgPath
    }
    
    // MARK: Private methods
    
    @objc private func handleTouchDown() {
        buttonLayer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
    }
    
    @objc private func handleTouchUp() {
        buttonLayer.fillColor = UIColor.white.cgColor
    }
}
