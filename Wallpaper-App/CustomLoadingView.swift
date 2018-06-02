//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit
import NVActivityIndicatorView

open class CustomLoadingView: UIView {
    
    var containerView = UIView()
    var progressView = UIView()
    var activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60), type: NVActivityIndicatorType.ballBeat)
    
    open class var shared: CustomLoadingView {
        struct Static {
            static let instance: CustomLoadingView = CustomLoadingView()
        }
        return Static.instance
    }
    
    open func startLoading(_ view: UIView) {
        
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = tealColor
        
        progressView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        progressView.center = view.center
        progressView.backgroundColor = tealColor
        progressView.clipsToBounds = true
        progressView.layer.shadowColor = UIColor.black.cgColor
        progressView.layer.shadowOffset = CGSize.zero
        progressView.layer.shadowOpacity = 1
        progressView.layer.shadowRadius = 10
        progressView.layer.cornerRadius = 10
        
        activityIndicator.center = CGPoint(x: progressView.bounds.width / 2, y: progressView.bounds.height / 2)
        activityIndicator.color = goldColor
        
        let animationLabel = UILabel(frame: frame)
        
        animationLabel.text = "Loading..."
        animationLabel.sizeToFit()
        animationLabel.backgroundColor = tealColor
        animationLabel.textColor = goldColor
        animationLabel.frame.origin.x += 152
        animationLabel.frame.origin.y += 350
        
        progressView.addSubview(activityIndicator)
        view.addSubview(animationLabel)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
    }
    
    open func stopLoading() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}
