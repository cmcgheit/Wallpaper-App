//PopUpViewController.swift, coded with love by C McGhee

import UIKit
import EasyTransitions
import Kingfisher
import UIKit.UIGestureRecognizerSubclass

class PopUpViewController: UIViewController {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var wallpaperPopImage: UIImageView!
    @IBOutlet weak var wallpaperDescLbl: PaddedLabel!
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    var wallpaper = [WallpaperCategory]()
    var selectedIndex: IndexPath!
    var placeholder: UIImage?
    var image: UIImage?
    
    var wallpaperDescText = ""
    var wallpaperPhotoURL = ""
    
    // Init VC as nib (easytransitions)
    init() {
        super.init(nibName: String(describing: PopUpViewController.self),
                   bundle: Bundle(for: PopUpViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.delegate = self
        backView.set(shadowStyle: .todayCard)
        layout(presenting: false)
        if #available(iOS 11, *) {
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        wallpaperPopImage.image = image
        
        // Create a gesture recognizer and add to a UIView
        let recognizer = InstantPanGestureRecognizer(target: self, action: #selector(panRecognizer))
        dismissBtn.addGestureRecognizer(recognizer)
    }
    
    func layout(presenting: Bool) {
        let cardLayout: CardView.Layout = presenting ? .expanded : .collapsed
        contentView.layer.cornerRadius = cardLayout.cornerRadius
        backView.layer.cornerRadius = cardLayout.cornerRadius
        cardView.set(layout: cardLayout)
    }
    
    // Custom Popup Recognizer state
    var animationProgress: CGFloat = 0.0
    @objc func panRecognizer(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: dismissBtn)
        switch recognizer.state{
        case .began:
            shrinkAnimation()
            animationProgress = animator.fractionComplete
            // Pause after Start enable User to interact with the animation
            animator.pauseAnimation()
        case .changed:
            // translation.y = the distance finger drag on screen
            let fraction = translation.y / 100
            // fractionComplete the percentage of animation progress
            animator.fractionComplete = fraction + animationProgress
            // when animation progress > 99%, stop and start the dismiss transition
            if animator.fractionComplete > 0.99{
                animator.stopAnimation(true)
                dismiss(animated: true, completion: nil)
            }
        case .ended:
            // when tap  on the screen animator.fractionComplete = 0
            if animator.fractionComplete == 0{
                animator.stopAnimation(true)
                dismiss(animated: true, completion: nil)
            }
                // when animator.fractionComplete < 99 % and release finger, automative rebounce to the initial state
            else{
                // rebounce effect
                animator.isReversed = true
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        default:
            break
        }
    }
    
    // The main animation
    var animator = UIViewPropertyAnimator()
    func shrinkAnimation(){
        animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            self.view.layer.cornerRadius = 15
        })
        animator.startAnimation()
    }
}

extension PopUpViewController: CardViewDelegate {
    func closeCardView() {
        dismiss(animated: true, completion: nil)
    }
}


