// PopUpViewController.swift, coded with love by C McGhee

import UIKit
import EasyTransitions
import Kingfisher
import UIKit.UIGestureRecognizerSubclass
import SwiftEntryKit

class PopUpViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var wallpaperPopImage: UIImageView!
    @IBOutlet weak var wallpaperDescLbl: PaddedLabel!
    @IBOutlet weak var savePhotoBtn: RoundedRectBlueButton!
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    var wallpaper = [WallpaperCategory]()
    var wallpapers: Wallpaper!
    var selectedIndex: IndexPath!
    var placeholder: UIImage?
    var image: UIImage?
    var wallpaperImageURL = ""
    var wallpaperDescText = ""
    
    private var isStatusBarHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savePhotoBtn.layer.cornerRadius = 15
        
        wallpaperPopImage.image = image
        let url = URL(string: wallpaperImageURL)
        wallpaperPopImage.kf.setImage(with: url, placeholder: placeholder)
        wallpaperDescLbl.text = wallpaperDescText
        
        // Create a gesture recognizer and add to a UIView
        let recognizer = InstantPanGestureRecognizer(target: self, action: #selector(panRecognizer))
        dismissBtn.addGestureRecognizer(recognizer)
        
        modalPresentationCapturesStatusBarAppearance = true // allows for statusbar to hide
    }
    
    // MARK: - Status Bar Show/Hide Animation
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isStatusBarHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: - Attributes Wrapper
    private var attributesWrapper: EntryAttributeWrapper {
        var attributes = EKAttributes.topFloat
        attributes.entryBackground = .color(color: .white)
        attributes.roundCorners = .all(radius: 15)
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .darkGray, opacity: 0.5, radius: 15, offset: .init(width: 0, height: 3)))
        return EntryAttributeWrapper(with: attributes)
        
    }
    
    // MARK: - SwiftEntryKit Alerts
    // Notification Message
    private func showNotificationEKMessage(attributes: EKAttributes, title: String, desc: String, textColor: UIColor, imageName: String? = nil) {
        let title = EKProperty.LabelContent(text: title, style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: .darkGray))
        let desc = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: .darkGray))
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: desc)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributesWrapper.attributes)
        
    }
    
    // MARK: - Individual Alerts
    func uploadToPhotosSuccess() {
        let titleText = "Saved Wallpaper to Photos"
        let descText = "saved wallpaper to Photos successfully"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: titleText, desc: descText, textColor: .darkGray)
    }
    
    // MARK: - Save Wallpaper to Photos App
    func getWallpaperURLData(url: URL, completion: @escaping (Data? , URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func saveWallpaperToPhotos() {
        let wallpaperURL = wallpaperImageURL
        guard let photoURL = URL(string: wallpaperURL) else { return }
        
        getWallpaperURLData(url: photoURL) { (data, response, error) in
            guard let data = data, let imageFromData = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                UIImageWriteToSavedPhotosAlbum(imageFromData, nil, nil, nil)
                self.wallpaperPopImage.image = imageFromData
                self.uploadToPhotosSuccess()
            }
        }
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
            if animator.fractionComplete > 0.99 {
                animator.stopAnimation(true)
                dismiss(animated: true, completion: nil)
            }
        case .ended:
            // when tap  on the screen animator.fractionComplete = 0
            if animator.fractionComplete == 0 {
                animator.stopAnimation(true)
                dismiss(animated: true, completion: nil)
            }
                // when animator.fractionComplete < 99 % and release finger, automative rebounce to the initial state
            else {
                // rebounce effect
                animator.isReversed = true
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        default:
            break
        }
    }
    
    // Custom Pop Up - Main Animation
    var animator = UIViewPropertyAnimator()
    func shrinkAnimation(){
        animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            self.view.layer.cornerRadius = 15
        })
        animator.startAnimation()
    }
    
    @IBAction func dismissBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveToPhotosBtnPressed(_ sender: RoundedRectBlueButton) {
        saveWallpaperToPhotos()
    }
}




