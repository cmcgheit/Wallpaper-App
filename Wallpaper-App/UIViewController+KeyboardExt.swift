//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit
import ObjectiveC

struct AssociatedKeys {
    static var activeTextField: UInt8 = 0
    static var keyboardHeight: UInt8 = 1
}

extension UIViewController : UITextFieldDelegate {
    
    private(set) var keyboardHeight: CGFloat {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.keyboardHeight) as? CGFloat else {
                return 0.0
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.keyboardHeight, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private(set) var activeTextField: UITextField? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.activeTextField) as? UITextField
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.activeTextField, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func disableUnoccludedTextField() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func enableUnoccludedTextField() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        self.keyboardHeight = keyboardFrame.height
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        checkForOcculsion()
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if self.view.frame.origin.y != 0.0 {
            self.view.frame.origin.y = 0.0
        }
        self.keyboardHeight = 0.0
    }
    
    func checkForOcculsion(){
        let bottomOfTextField = self.view.convert(CGPoint(x: 0, y: self.activeTextField!.frame.height), from: self.activeTextField!).y
        let topOfKeyboard = self.view.frame.height - self.keyboardHeight
        
        if (bottomOfTextField > topOfKeyboard ) {
            var offset = bottomOfTextField - topOfKeyboard
            if self.view.frame.origin.y < 0 {
                offset += 20.0
            }
            self.view.frame.origin.y = -1 * offset
        } else {
            self.view.frame.origin.y = 0
        }
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if self.activeTextField != nil && self.activeTextField !== textField {
            self.activeTextField = textField
            checkForOcculsion()
        }else{
            self.activeTextField = textField
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        self.activeTextField = nil
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}
