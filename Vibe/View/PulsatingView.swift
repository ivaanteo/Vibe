//
//  PulsatingView.swift
//  Vibe
//
//  Created by Ivan Teo on 18/6/21.
//

import UIKit

class PulsatingView: UIView {
//    let rippleLayer = RippleLayer()
    
    let pulseLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.strokeColor = UIColor.clear.cgColor
        shape.lineWidth = 10
        shape.fillColor = UIColor.white.withAlphaComponent(0.3).cgColor
        shape.lineCap = .round
        return shape
    }()
    
    let backgroundLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShapes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupShapes()
    }
    
    fileprivate func setupShapes() {
        setNeedsLayout()
        layoutIfNeeded()
        
        
        
        let circularPath = UIBezierPath(arcCenter: self.center, radius: bounds.size.height/2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        pulseLayer.frame = bounds
        pulseLayer.path = circularPath.cgPath
        pulseLayer.position = self.center
        self.layer.addSublayer(pulseLayer)
        
        backgroundLayer.frame = bounds
        backgroundLayer.position = self.center  
        
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.lineWidth = 10
        backgroundLayer.fillColor = #colorLiteral(red: 0.8873168826, green: 0.477771461, blue: 1, alpha: 1)
        backgroundLayer.lineCap = .round
        self.layer.addSublayer(backgroundLayer)
//        self.layer.addSublayer(rippleLayer)
//        rippleLayer.position = CGPoint(x: self.layer.bounds.midX, y: self.layer.bounds.midY);
    }
    
    func pulse() {
        // no long touch
        let animation = CABasicAnimation(keyPath: "transform.scale")
        //    animation.toValue = 1.2
        animation.toValue = 3
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        pulseLayer.add(animation, forKey: "pulsing")
//        rippleLayer.stopAnimation()
    }
    func stopPulse(){
        // long touch
        pulseLayer.removeAnimation(forKey: "pulsing")
//        rippleLayer.startAnimation()
    }
}
