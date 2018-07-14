//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit

public class RoundedRectButton: UIButton {
    
    // corner radius background rect
    public var roundRectCornerRadius: CGFloat = 15 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
   // color of background rect
    public var roundRectColor: UIColor = wallBlue { // all buttons use subclass blue
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutRoundRectLayer()
    }
    
    private var roundRectLayer: CAShapeLayer?
    
    private func layoutRoundRectLayer() {
        if let exisitingLayer = roundRectLayer {
            exisitingLayer.removeFromSuperlayer()
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).cgPath
        shapeLayer.fillColor = roundRectColor.cgColor
        self.layer.insertSublayer(shapeLayer, at: 0)
        self.roundRectLayer = shapeLayer
    }
    
}
