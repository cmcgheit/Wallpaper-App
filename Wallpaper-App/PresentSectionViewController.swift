//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit

class PresentSectionViewController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var cellFrame: CGRect!
    var cellTransform: CATransform3D!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6 // length
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let destination = transitionContext.viewController(forKey: .to) as! PopUpViewController
        let containerView = transitionContext.containerView
        
        containerView.addSubview(destination.view)
        
        // Start Position - constraints in Wallpaper image? add another view?
        let widthConstraint = destination.wallpaperPopImage.widthAnchor.constraint(equalToConstant: 304)
        let heightConstraint = destination.wallpaperPopImage.heightAnchor.constraint(equalToConstant: 248)
        let bottomConstraint = destination.wallpaperPopImage.bottomAnchor.constraint(equalTo: destination.contentView.bottomAnchor)
        
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, bottomConstraint])
        
        let translate = CATransform3DMakeTranslation(cellFrame.origin.x, cellFrame.origin.y, 0.0)
        let transform = CATransform3DConcat(translate, cellTransform)
        
        destination.view.layer.transform = transform
        destination.view.layer.zPosition = 999
        
        containerView.layoutIfNeeded()
        
        destination.wallpaperPopImage.layer.cornerRadius = 14
        destination.wallpaperPopImage.layer.shadowOpacity = 0.25
        destination.wallpaperPopImage.layer.shadowOffset.height = 10
        destination.wallpaperPopImage.layer.shadowRadius = 20
        
        let moveUpTransform = CGAffineTransform(translationX: 0, y: -100)
        let scaleUpTransform = CGAffineTransform(scaleX: 2, y: 2)
        let removeFromViewTransform = moveUpTransform.concatenating(scaleUpTransform)
        
        // Customize views popup
        destination.backView.alpha = 0
        destination.backView.transform = removeFromViewTransform
        
//        destination.cardView.alpha = 0
//        destination.cardView.transform = removeFromViewTransform
        
        let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.7) {
            
            // End Position
            NSLayoutConstraint.deactivate([widthConstraint, heightConstraint, bottomConstraint])
            destination.view.layer.transform = CATransform3DIdentity
            containerView.layoutIfNeeded()
            
            destination.wallpaperPopImage.layer.cornerRadius = 0
            
            destination.backView.alpha = 1
            destination.backView.transform = .identity
            
//            destination.cardView.alpha = 1
//            destination.cardView.transform = .identity
            
            let scaleTitleTransform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            let moveTitleTransform = CGAffineTransform(translationX: 30, y: 10)
            
            let titleTransform = scaleTitleTransform.concatenating(moveTitleTransform)
            destination.wallpaperDescLbl.transform = titleTransform
        }
        
        animator.addCompletion {
            (finished) in
            
            // Completion
            transitionContext.completeTransition(true)
        }
        
        animator.startAnimation()
    }
}

