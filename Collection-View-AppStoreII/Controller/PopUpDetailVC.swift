// Created with ♥️ by: Carey M

import UIKit

class PopUpDetailVC: StatusBarAnimatableViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var cardView: CardContentView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var cardBottomToRootBottomConstraint: NSLayoutConstraint!
    
    var cardViewModel: WallpaperItem! {
        didSet {
            if self.cardView != nil {
                self.cardView.viewModel = cardViewModel
            }
        }
    }
    
    var unhighlightedCardViewModel: WallpaperItem!
    
    var isFontStateHighlighted: Bool = true {
        didSet {
            cardView.setFontState(isHighlighted: isFontStateHighlighted)
        }
    }
    
    var draggingDownToDismiss = false
    
    final class DismissalPanGesture: UIPanGestureRecognizer {}
    final class DismissalScreenEdgePanGesture: UIScreenEdgePanGestureRecognizer {}
    
    private lazy var dismissalPanGesture: DismissalPanGesture = {
        let pan = DismissalPanGesture()
        pan.maximumNumberOfTouches = 1
        return pan
    }()
    
    private lazy var dismissalScreenEdgePanGesture: DismissalScreenEdgePanGesture = {
        let pan = DismissalScreenEdgePanGesture()
        pan.edges = .left
        return pan
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Constants.isEnabledDebugAnimatingViews {
            scrollView.layer.borderWidth = 3
            scrollView.layer.borderColor = UIColor.green.cgColor
            
            scrollView.subviews.first!.layer.borderWidth = 3
            scrollView.subviews.first!.layer.borderColor = UIColor.purple.cgColor
        }
        
        scrollView.delegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        cardView.viewModel = cardViewModel
        cardView.setFontState(isHighlighted: isFontStateHighlighted)
        
        dismissalPanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        dismissalPanGesture.delegate = self
        
        dismissalScreenEdgePanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        dismissalScreenEdgePanGesture.delegate = self
        
        // Make drag down/scroll pan gesture waits til screen edge pan to fail first to begin
        dismissalPanGesture.require(toFail: dismissalScreenEdgePanGesture)
        scrollView.panGestureRecognizer.require(toFail: dismissalScreenEdgePanGesture)
        
        loadViewIfNeeded()
        view.addGestureRecognizer(dismissalPanGesture)
        view.addGestureRecognizer(dismissalScreenEdgePanGesture)
    }
    
    func didSuccessfullyDragDownToDismiss() {
        cardViewModel = unhighlightedCardViewModel
        dismiss(animated: true)
    }
    
    func userWillCancelDissmissalByDraggingToTop(velocityY: CGFloat) {}
    
    func didCancelDismissalTransition() {
        // Clean up
        interactiveStartingPoint = nil
        dismissalAnimator = nil
        draggingDownToDismiss = false
    }
    
    var interactiveStartingPoint: CGPoint?
    var dismissalAnimator: UIViewPropertyAnimator?
    
    // This handles both screen edge and dragdown pan. As screen edge pan is a subclass of pan gesture, this input param works.
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        
        let isScreenEdgePan = gesture.isKind(of: DismissalScreenEdgePanGesture.self)
        let canStartDragDownToDismissPan = !isScreenEdgePan && !draggingDownToDismiss
        
        // Don't do anything when it's not in the drag down mode
        if canStartDragDownToDismissPan { return }
        
        let targetAnimatedView = gesture.view!
        let startingPoint: CGPoint
        
        if let p = interactiveStartingPoint {
            startingPoint = p
        } else {
            // Initial location
            startingPoint = gesture.location(in: nil)
            interactiveStartingPoint = startingPoint
        }
        
        let currentLocation = gesture.location(in: nil)
        let progress = isScreenEdgePan ? (gesture.translation(in: targetAnimatedView).x / 100) : (currentLocation.y - startingPoint.y) / 100
        let targetShrinkScale: CGFloat = 0.86
        let targetCornerRadius: CGFloat = Constants.cardCornerRadius
        
        func createInteractiveDismissalAnimatorIfNeeded() -> UIViewPropertyAnimator {
            if let animator = dismissalAnimator {
                return animator
            } else {
                let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: {
                    targetAnimatedView.transform = .init(scaleX: targetShrinkScale, y: targetShrinkScale)
                    targetAnimatedView.layer.cornerRadius = targetCornerRadius
                })
                animator.isReversed = false
                animator.pauseAnimation()
                animator.fractionComplete = progress
                return animator
            }
        }
        
        switch gesture.state {
        case .began:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()
            
        case .changed:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()
            
            let actualProgress = progress
            let isDismissalSuccess = actualProgress >= 1.0
            
            dismissalAnimator!.fractionComplete = actualProgress
            
            if isDismissalSuccess {
                dismissalAnimator!.stopAnimation(false)
                dismissalAnimator!.addCompletion { [unowned self] (pos) in
                    switch pos {
                    case .current:
                        self.didSuccessfullyDragDownToDismiss()
                    default:
                        fatalError("Can't finish dismissal!")
                    }
                }
                dismissalAnimator!.finishAnimation(at: .current)
            }
            
        case .ended, .cancelled:
            if dismissalAnimator == nil {
                // Gesture's too quick that it doesn't have dismissalAnimator!
                print("No dismissal Animator!")
                didCancelDismissalTransition()
                return
            }
            // NOTE:
            // If user lift fingers -> ended
            // If gesture.isEnabled -> cancelled
            // Ended, Animate back to start
            dismissalAnimator!.pauseAnimation()
            dismissalAnimator!.isReversed = true
            
            // Disable gesture until reverse closing animation finishes.
            gesture.isEnabled = false
            dismissalAnimator!.addCompletion { [unowned self] (pos) in
                self.didCancelDismissalTransition()
                gesture.isEnabled = true
            }
            dismissalAnimator!.startAnimation()
        default:
            fatalError("Gesture state? \(gesture.state.rawValue)")
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.scrollIndicatorInsets = .init(top: cardView.bounds.height, left: 0, bottom: 0, right: 0)
        if Constants.isEnabledTopSafeAreaInsetsFixOnCardDetailViewController {
            if #available(iOS 11.0, *) {
                self.additionalSafeAreaInsets = .init(top: max(-view.safeAreaInsets.top,0), left: 0, bottom: 0, right: 0)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if draggingDownToDismiss || (scrollView.isTracking && scrollView.contentOffset.y < 0) {
            draggingDownToDismiss = true
            scrollView.contentOffset = .zero
        }
        
        scrollView.showsVerticalScrollIndicator = !draggingDownToDismiss
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Without this, when user drag down and lift the finger fast at the top, there'll be some scrolling going on.
        // This check prevents that.
        if velocity.y > 0 && scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
        }
    }
    
    override var statusBarAnimatableConfig: StatusBarAnimatableConfig {
        return StatusBarAnimatableConfig(prefersHidden: true,
                                         animation: .slide)
    }
}

extension PopUpDetailVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


