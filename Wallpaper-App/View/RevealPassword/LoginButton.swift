//
//  LoginButton.swift
//  RevealPasswordTextField
//
//  Created by Mark Moeykens on 7/5/18.
//  Copyright © 2018 Mark Moeykens. All rights reserved.
//

import UIKit

class LoginButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let newLayer = CAGradientLayer()
        newLayer.colors = [wallBlue, wallDarkBlue]
        newLayer.frame = bounds
        layer.insertSublayer(newLayer, at: 0)
        
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        setTitleColor(UIColor.darkGray, for: .normal)
    }
}
