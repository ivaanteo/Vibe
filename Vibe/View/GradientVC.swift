//
//  GradientVC.swift
//  Vibe
//
//  Created by Ivan Teo on 25/6/21.
//

import UIKit

extension UIViewController{
    func configureGradientBackground() {
        // Ensure the background matches the device appearance.
        self.view.backgroundColor = .none
        let gradientLayer = Colors().gl
        gradientLayer?.frame = view.frame
        view.layer.insertSublayer(gradientLayer!, at: 0)
    }
}
