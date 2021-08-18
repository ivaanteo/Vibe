//
//  GradientLayer.swift
//  Vibe
//
//  Created by Ivan Teo on 23/6/21.
//

import UIKit

class Colors {
    var gl:CAGradientLayer!
    init() {
        self.gl = CAGradientLayer()
        self.gl.colors = [UIColor(named: Constants.Colours.orange)!.cgColor, UIColor(named: Constants.Colours.purple)!.cgColor]
        self.gl.locations = [0.0, 1.0]
        self.gl.startPoint = CGPoint(x: 1, y: 0)
        self.gl.endPoint = CGPoint(x: 0, y: 1)
    }
}
