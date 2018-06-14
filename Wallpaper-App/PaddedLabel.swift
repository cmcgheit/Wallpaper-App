//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit

class PaddedLabel: UILabel {
    var topInset: CGFloat = 5.0
    var bottomInset: CGFloat = 5.0
    var leftInset: CGFloat = 5.0
    var rightInset: CGFloat = 5.0
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += topInset + bottomInset
        contentSize.width += leftInset + rightInset
        return contentSize
    }
    
    func setPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat){
        self.topInset = top
        self.bottomInset = bottom
        self.leftInset = left
        self.rightInset = right
        let insets: UIEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        super.drawText(in: UIEdgeInsetsInsetRect(self.frame, insets))
    }
}
