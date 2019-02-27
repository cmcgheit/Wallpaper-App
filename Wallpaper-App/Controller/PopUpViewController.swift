// PopUpViewController.swift, coded with love by C McGhee

import UIKit
import Kingfisher
import UIKit.UIGestureRecognizerSubclass
import SwiftEntryKit

class PopUpViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cardContentView: CardContentView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var wallScrollView: UIScrollView!
    
    @IBOutlet weak var wallpaperPopImage: UIImageView!
    @IBOutlet weak var wallpaperDescLbl: PaddedLabel!
    @IBOutlet weak var savePhotoBtn: UIButton!
    
    @IBOutlet weak var dismissBtn: UIButton!
    
    // Transition
    @IBOutlet weak var cardBottomToRootBottomConstraint: NSLayoutConstraint!
    
    var wallpaper = [WallpaperCategory]()
    var wallpapers: Wallpaper!
    var selectedIndex: IndexPath!
    var placeholder: UIImage?
    var image: UIImage?
    var wallpaperImageURL = ""
    var wallpaperDescText = ""
    
    private var isStatusBarHidden: Bool = false
    
    // Transition
    var isFontStateHighlighted: Bool = true {
        didSet {
            cardContentView.setFontState(isHighlighted: isFontStateHighlighted)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeSaveButton()
        
        wallpaperPopImage.image = image
        let url = URL(string: wallpaperImageURL)
        wallpaperPopImage.kf.setImage(with: url, placeholder: placeholder)
        wallpaperDescLbl.text = wallpaperDescText
        
        // setupScrollView()
        
        // Create a gesture recognizer and add to a UIView
        let recognizer = InstantPanGestureRecognizer(target: self, action: #selector(panRecognizer))
        dismissBtn.addGestureRecognizer(recognizer)
        
        modalPresentationCapturesStatusBarAppearance = true // allows for statusbar to hide
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isStatusBarHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
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
        
    // MARK: - Individual Alerts
    func uploadToPhotosSuccess() {
        let titleText = "Saved Wallpaper to Photos"
        let descText = "saved wallpaper to Photos successfully"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: titleText, desc: descText, textColor: .darkGray)
    }
    
    func makeSaveButton() {
        savePhotoBtn.setTitle("Save Wallpaper To Photos", for: .normal)
        savePhotoBtn.setTitleColor(wallBlue, for: .normal)
        savePhotoBtn.titleLabel?.font = UIFont.gillsRegFont(ofSize: 16)
    }
    
//    // MARK: - Photo ScrollView
//    func setupScrollView() {
//        wallScrollView.contentSize.width = self.wallScrollView.frame.width * CGFloat(wallpaperImageURL.count + 1)
//
//        for (i, image) in wallpaper.enumerated() {
//            let frame = CGRect(x: self.wallScrollView.frame.width * CGFloat(i + 1), y:0, width: self.wallScrollView.frame.width, height: self.wallScrollView.frame.height)
//
//             guard let wallpaperView = Bundle.main.loadNibNamed("WallpaperRoundedCardCell", owner: self, options: nil)?.first as? WallpaperRoundedCardCell else { return }
//
//            wallpaperView.frame = frame
//            wallpaperView.imageView.image = UIImage(named: image.wallpaperURL)
//
//            wallScrollView.addSubview(wallpaperView)
//
//        }
//    }
    
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




