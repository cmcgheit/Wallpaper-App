//
//  RevealPasswordTextField.swift
//  RevealPasswordTextField
//
//  Created by Mark Moeykens on 5/31/18.
//  Copyright © 2018 Mark Moeykens. All rights reserved.
//

import UIKit

@IBDesignable
class RevealPasswordTextField: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        isSecureTextEntry = true
        font = UIFont(name: FontName.light, size: 17)
        
        addRevealButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func addRevealButton() {
        rightViewMode = UITextField.ViewMode.always
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 22))
        button.setImage(#imageLiteral(resourceName: "eye"), for: .normal)
        button.addTarget(self, action: #selector(self.toggleReveal), for: .touchUpInside)
        
        rightView = button
    }

    @objc func toggleReveal(_ sender: UIButton) {
        if sender.imageView?.image == #imageLiteral(resourceName: "eye") {
            sender.setImage(#imageLiteral(resourceName: "eye-off"), for: .normal)
            isSecureTextEntry = false
            
            if text != "" {
                font = UIFont(name: FontName.regular, size: 16)
            }
        } else {
            sender.setImage(#imageLiteral(resourceName: "eye"), for: .normal)
            isSecureTextEntry = true
            font = UIFont(name: FontName.italic, size: 17)
        }
    }
}
