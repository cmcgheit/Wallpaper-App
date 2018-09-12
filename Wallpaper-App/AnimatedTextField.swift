//AnimatedTextField.swift, coded with love by C McGhee

import UIKit

class AnimatedTextField: UITextField {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        if text.count < 5 {
            // Animation jumps back to field if at least 5 characters not entered
            let jump = CASpringAnimation(keyPath: "position.y")
            jump.fromValue = textField.layer.position.y + 1.0
            jump.toValue = textField.layer.position.y
            jump.duration = jump.settlingDuration
            jump.initialVelocity = 100.0
            jump.mass = 10.0
            jump.stiffness = 1500.0
            jump.damping = 50.0
            textField.layer.add(jump, forKey: nil)
        }
    }
}
