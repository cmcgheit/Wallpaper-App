//  FeedViewController
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import Foundation
import UIKit
import Firebase
import SwiftyJSON
import GlidingCollection
import GoogleMobileAds
import SwiftEntryKit
import Instructions

class FeedViewController: UIViewController {
    
    @IBOutlet var glidingView: GlidingCollection!
    fileprivate var collectionView: UICollectionView!
    
    @IBOutlet private var bannerView: GADBannerView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var glidingIntView: CustomCardView!
    @IBOutlet weak var customNaviTitleView: CustomCardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var themeSwitch: CustomSwitch!
    
    // Menu
    var uploadBtnCenter: CGPoint!
    var signOutBtnCenter: CGPoint!
    
    var handle: AuthStateDidChangeListenerHandle?

    private var isStatusBarHidden: Bool = false
    
    let transition = TransitionClone()
    var collectionIndex: IndexPath?
    var imageFrame = CGRect.zero
    
    let instructionsController = CoachMarksController()
    private weak var blurView: UIView?
    public var userTappedCloseButtonClosure: (() -> Void)?
    
    var wallpaperCategories = [WallpaperCategories]() //all
    var wallpaperSections = ["Art", "Music", "Sports"]
    var sportsCategory = [WallpaperCategory]()
    var musicCategory = [WallpaperCategory]()
    var artCategory = [WallpaperCategory]()
    
    // Placeholders - eventually have separate images for each category?
    let artPlaceholder = UIImage(named: "placeholder-image")
    let musicPlaceholder = UIImage(named: "placeholder-image")
    let sportsPlaceholder = UIImage(named: "placeholder-image")
    
    // MARK: - Attributes Wrapper
    private var attributesWrapper: EntryAttributeWrapper {
        var attributes = EKAttributes.topFloat
        attributes.entryBackground = .color(color: UIColor.white)
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
    
    // Top Banner Message
    private func showBannerNotificationMessage(attributes: EKAttributes, text: String, desc: String, textColor: UIColor) {
        let text = EKProperty.LabelContent(text: text, style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: .darkGray))
        let desc = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.gillsRegFont(ofSize: 15), color: .darkGray))
        let simpleMessage = EKSimpleMessage(title: text, description: desc)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    // MARK: - Individual Alerts
    func signOutSuccessAlert() {
        let signOutText = "Signed Out Successfully"
        let signOutDescText = "You have signed out of Wall Variety successfully"
        showBannerNotificationMessage(attributes: attributesWrapper.attributes, text: signOutText, desc: signOutDescText, textColor: .darkGray)
    }
    
    func problemSignOutAlert() {
        let signOutAlertText = "Problem Signing Out"
        let signOutAlertDescText = "There is an error signing you out, please try again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: signOutAlertText, desc: signOutAlertDescText, textColor: .darkGray)
    }
    
    func noNetworkConnectionAlert() {
        let noNetworkTitleText = "No Network Connection"
        let noNetworkDescText = "Check your network/internet settings, then close and restart the app"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: noNetworkTitleText, desc: noNetworkDescText, textColor: .darkGray)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadBtn.center = menuBtn.center
        signOutBtn.center = menuBtn.center
        
        uploadBtnCenter = uploadBtn.center
        signOutBtnCenter = signOutBtn.center
        
        roundBottomCorners()
        makeShadowView()
        
        // Reachability
        if Reachability.isConnectedToNetwork() {
            setup()
            setupThemeSwitch()
            DispatchQueue.main.async {
                self.glidingView.reloadData()
            }
            
            catQueue.async {
                self.makeCategories()
            }
            applyTheme()
            notificationObservers()
            
        } else {
            noNetworkConnectionAlert()
            FIRService.removeFIRObservers()
        }
        
        // Theme - checks for theme setting
        if Defaults.object(forKey: "lightTheme") != nil {
            Defaults.set(true, forKey: "lightTheme")
        } else {
            Defaults.set(true, forKey: "darkTheme")
        }
        
        // Instructions
        instructionsController.dataSource = self
        instructionsController.overlay.color = UIColor(red: 0.9765, green: 0.9765, blue: 0.9765, alpha: 1.0) // background color when instructions show #f9f9f9
        instructionsController.overlay.allowTap = true
        // instructionsController.displayOverCutoutPath = true // helper for larger devices
        
        // MARK: - Check User First Time Viewing VC (Instructions)
        let launchedBefore = Defaults.bool(forKey: "alreadylaunched")
        if launchedBefore {
            Defaults.setInstructions(value: false)
        } else {
            Defaults.setInstructions(value: true)
            self.instructionsController.start(on: self)
            Defaults.set(true, forKey: "alreadylaunched")
        }
        
        // MARK: - Double Tap Gesture to close PopUpView
        let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedViewController.backgroundTapped))
        closeTapGesture.numberOfTapsRequired = 2
        
        //  MARK: - Admob Banner Properties
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // wont accept constant
        bannerView.rootViewController = self
        let request = GADRequest()
        bannerView.load(request)
        request.testDevices = ["ca-app-pub-3940256099942544/2934735716"]
        view.addSubview(bannerView)
        
    }
    
    // MARK: - Make Views Bottom Rounded Corners
    func roundBottomCorners() {
        customNaviTitleView.clipsToBounds = true
        customNaviTitleView.layer.cornerRadius = 15
        if #available(iOS 11.0, *) {
            customNaviTitleView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            let rectShape = CAShapeLayer()
            rectShape.bounds = view.frame
            rectShape.position = view.center
            rectShape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
            customNaviTitleView.layer.backgroundColor = UIColor.black.cgColor
            customNaviTitleView.layer.mask = rectShape
        }
    }
    
    func makeShadowView() {
        glidingIntView.layer.cornerRadius = 15
        glidingIntView.layer.shadowOpacity = 0.2
        glidingIntView.layer.shadowColor = UIColor.black.cgColor
        glidingIntView.layer.shadowRadius = 2 // HALF of blur
        glidingIntView.layer.shadowOffset = CGSize(width: 0, height: 2) // Spread x, y
        glidingIntView.layer.masksToBounds =  false
    }
    
    // MARK: - Custom Switch
    func setupThemeSwitch() {
        themeSwitch.onTintColor = wallGold
        themeSwitch.offTintColor = wallBlue
        themeSwitch.cornerRadius = 0.5
        themeSwitch.thumbCornerRadius = 0.5
        themeSwitch.thumbSize = CGSize(width: 25, height: 25)
        themeSwitch.thumbTintColor = UIColor.white
        themeSwitch.padding = 2
        themeSwitch.animationDuration = 0.6
        themeSwitch.thumbShaddowOppacity = 0
    }
    
    //MARK:  - Status Bar
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: - Show/Hide Status Bar
        isStatusBarHidden = false
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        // MARK: - Check Auth User Signed-In Listener/Handler
        handle = authRef.addStateDidChangeListener { ( auth, user) in
            if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
                // User signed-In
                Defaults.setIsLoggedIn(value: true)
            } else {
                Defaults.setIsLoggedIn(value: false)
                let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
                self.present(signUpVC, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {

        if Theme.themeChanged {
            DispatchQueue.main.async {
                self.collectionView.reloadData() //reload collection for theme change
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        authRef.removeStateDidChangeListener(handle!)
        
        self.instructionsController.stop(immediately: true)
        
        removeNotifications()
    }
    
    // MARK: - Categories Function
    let catQueue = DispatchQueue(label: "categories-data-queue")
    func makeCategories() {
        FIRService.getArtCategory(completion: { (artCategory) in
            self.artCategory = artCategory
            
            FIRService.getMusicCategory(completion: { (musicCategory) in
                self.musicCategory = musicCategory
                
                FIRService.getSportsCategory(completion: { (sportsCategory) in
                    self.sportsCategory = sportsCategory
                    
                    self.wallpaperCategories = [
                        WallpaperCategories(catName: "Art", wallpaperData: self.artCategory),
                        WallpaperCategories(catName: "Music", wallpaperData: self.musicCategory),
                        WallpaperCategories(catName: "Sports", wallpaperData: self.sportsCategory)]
                    
                    DispatchQueue.main.async {
                        self.handleRefresh() // refresh before updating collection
                        self.glidingView.collectionView.reloadData()
                    }
                })
            })
        })
    }
    
    func notificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: .updateFeedNotificationName, object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(handleUpdateFeed())
    }
    
    // MARK: - Refresh Wallpaper Feed
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    func handleRefresh() {
        wallpaperCategories.removeAll() //clear wallpaper feed to refresh
        fetchFeed()
    }
    
    // MARK: - Fetch Wallpaper Feed For Specific User, allow user have specific wallpapers feed
    func fetchFeed() {
        //        guard let uid = authRef.currentUser?.uid else { return }
        //        if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
        //            FIRService.fetchUserForUID(uid: uid) { (user) in
        //                // Load all wallpapers from db?
        //                //        let indexPath = IndexPath(row: 0, section: 0)
        //                //        self.collectionView.insertItems(at: [indexPath]) // insert in glidingCollection?
        //                DispatchQueue.main.async {
        //                    self.collectionView.reloadData()
        //                    self.glidingView.reloadData()
        //                }
        //            }
        //        } else {
        //        }
    }
    
    // MARK: - PopUp Background Touch to Dismiss
    @objc func backgroundTapped(recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Gliding Collection
    // MARK: - Setup Gliding Collection/Wallpaper Feed
    func setup() {
        DispatchQueue.main.async {
            self.setupGlidingCollectionView()
        }
    }
    
    private func setupGlidingCollectionView() {
        collectionView = glidingView.collectionView
        let nib = UINib(nibName: String(describing: WallpaperRoundedCardCell.self), bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "wallpaperCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = glidingView.backgroundColor
        
        glidingView.dataSource = self
        
    }
    
    // MARK: - Theme
    @IBAction func themeChanged(_ sender: CustomSwitch) {
        Theme.current = sender.isOn ? LightTheme() : DarkTheme()
        Theme.themeChanged = true
        applyTheme()
        
        Defaults.set(true, forKey: "lightTheme")
    }
    
    fileprivate func applyTheme() {
        DispatchQueue.main.async {
            self.view.backgroundColor = Theme.current.mainBackgroundColor
            self.customNaviTitleView.backgroundColor = Theme.current.cardView
            self.glidingIntView.backgroundColor = Theme.current.cardView
            self.titleLabel.textColor = Theme.current.textColor
        }
    }
    
    // MARK: - Custom Transition
    func animateCell(cellFrame: CGRect) -> CATransform3D {
        let angleFromX = Double((-cellFrame.origin.x) / 10)
        let angle = CGFloat((angleFromX * Double.pi) / 180.0)
        var transform = CATransform3DIdentity
        transform.m34 = -1.0/1000
        let rotation = CATransform3DRotate(transform, angle, 0, 1, 0)
        
        var scaleFromX = (1000 - (cellFrame.origin.x - 200)) / 1000
        let scaleMax: CGFloat = 1.0
        let scaleMin: CGFloat = 0.6
        if scaleFromX > scaleMax  {
            scaleFromX = scaleMax
        }
        if scaleFromX < scaleMin {
            scaleFromX = scaleMin
        }
        
        let scale = CATransform3DScale(CATransform3DIdentity, scaleFromX, scaleFromX, 1)
        
        return CATransform3DConcat(rotation, scale)
    }
    
    // MARK: - Menu Buttons/Toggle Function
    func toggleMenuBtns(button: UIButton, onImage: UIImage, offImage: UIImage) {
        if button.currentImage == offImage {
            button.setImage(onImage, for: .normal)
        } else {
            button.setImage(offImage, for: .normal)
        }
    }
    
    // MARK: - Menu Button
    @IBAction func menuBtnPressed(_ sender: UIButton) {
        if menuBtn.currentImage ==  #imageLiteral(resourceName: "menu_button_fade") {
            UIView.animate(withDuration: 0.3, animations: {
                self.uploadBtn.alpha = 1
                self.signOutBtn.alpha = 1
                
                self.uploadBtn.center = self.uploadBtnCenter
                self.signOutBtn.center = self.signOutBtnCenter
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.uploadBtn.alpha = 0
                self.signOutBtn.alpha = 0
                
                self.uploadBtn.center = self.menuBtn.center
                self.signOutBtn.center = self.menuBtn.center
            })
        }
        toggleMenuBtns(button: sender, onImage: #imageLiteral(resourceName: "menu_button_fade"), offImage: #imageLiteral(resourceName: "menu_button_fade_off"))
    }
    
    
    // MARK: - Upload Button
    @IBAction func uploadBtnPressed(_ sender: UIButton) {
        toggleMenuBtns(button: sender, onImage: #imageLiteral(resourceName: "upload_button_fade"), offImage: #imageLiteral(resourceName: "upload_button_fade_off"))
        let uploadVC = storyboard?.instantiateViewController(withIdentifier: "UploadViewController") as! UploadViewController
        uploadVC.providesPresentationContextTransitionStyle = true
        uploadVC.definesPresentationContext = true
        uploadVC.modalPresentationStyle = .overCurrentContext
        uploadVC.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
        present(uploadVC, animated: true)
    }
    
    
    // MARK: - Sign Out Button Action
    @IBAction func signOutBtnPressed(_ sender: UIButton) {
        toggleMenuBtns(button: sender, onImage: #imageLiteral(resourceName: "signout_button_fade"), offImage: #imageLiteral(resourceName: "signout_button_fade_off"))
        // Signed In User
        if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
            AuthService.instance.logOutUser()
            FIRService.removeFIRObservers()
            Defaults.setIsLoggedIn(value: false)
            // MARK: Floating Signout Indicator (Success)
            DispatchQueue.main.async {
                self.signOutSuccessAlert()
            }
            let backToLoginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            present(backToLoginVC, animated: true)
        } else {
            // MARK: - Floating Signout Indicator (Error)
            problemSignOutAlert()
        }
    }
    
    // MARK: - Category Section Functions (put wallpaper images in each category section)
    func numberOfWallpapersAt(section: Int) -> Int {
        switch section {
        case 0: return artCategory.count
        case 1: return musicCategory.count
        case 2: return sportsCategory.count
        default: return 0
        }
    }
    
    func wallpapersAt(section: Int, atIndex index: Int) -> (WallpaperCategory) {
        if section == 0 {
            return (artCategory[index])
        } else if section == 1 {
            return (musicCategory[index])
        } else {
            return (sportsCategory[index])
        }
    }
    
    func allWallpapersAt(section: Int) -> [WallpaperCategory] {
        if section == 0 {
            return artCategory
        } else if section == 1 {
            return musicCategory
        } else {
            return sportsCategory
        }
    }
    
    // Set image as placeholder, best when can place individual placeholder images for each category
    func placeholderFor(section: Int) -> UIImage {
        if section == 0 {
            return artPlaceholder!
        } else if section == 1 {
            return musicPlaceholder!
        } else {
            return sportsPlaceholder! 
        }
    }
    
    func wallpaperFor(section: Int, atIndex index: Int) -> (wallpaper: WallpaperCategory, placeholder: UIImage) {
        if section == 0 {
            return (artCategory[index], placeholder: artPlaceholder!)
        } else if section == 1 {
            return (musicCategory[index], placeholder: musicPlaceholder!)
        } else {
            return (sportsCategory[index], placeholder: sportsPlaceholder!)
        }
    }
}


// MARK: - CollectionView Main Functions
extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfWallpapersAt(section: glidingView.expandedItemIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaperCell", for: indexPath) as? WallpaperRoundedCardCell else { return UICollectionViewCell() }
        
        let wallpapers = wallpaperFor(section: glidingView.expandedItemIndex, atIndex: indexPath.row)
        cell.setUpCell(wallpaper: wallpapers.wallpaper, placeholder: wallpapers.placeholder)
        
        // popup transition
        transition.destinationFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: cell.imageView.frame.height * view.frame.width / cell.imageView.frame.width)
        
        imageFrame = cell.imageView.frame
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - Custom DidSelect Transition Function
        let section = glidingView.expandedItemIndex
        collectionIndex = indexPath
        
        if let cell = collectionView.cellForItem(at: indexPath) as? WallpaperRoundedCardCell {
            let a = collectionView.convert(cell.frame, to: collectionView.superview)
            
            transition.startingFrame = CGRect(x: a.minX+15, y: a.minY+15, width: 375 / 414 * view.frame.width - 30, height: 408 / 736 * view.frame.height - 30)
            
            let popUpVC = PopUpViewController()
            
            popUpVC.selectedIndex = indexPath
            popUpVC.wallpaper = allWallpapersAt(section: section)
            popUpVC.placeholder = placeholderFor(section: section)
            popUpVC.wallpaperImageURL = cell.wallpaper.wallpaperURL
            popUpVC.wallpaperDescText = cell.wallpaper.wallpaperDesc
            
            popUpVC.transitioningDelegate = self
            popUpVC.modalPresentationStyle = .custom
            
            self.present(popUpVC, animated: true, completion: nil)
        }
    }
    
    // PopUp Transition
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 375 / 414 * view.frame.width, height: 408 / 736 * view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.3) {
            cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.3) {
            cell?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}
// MARK: - Gliding Collection Extension Functions
extension FeedViewController: GlidingCollectionDatasource {
    
    func numberOfItems(in collection: GlidingCollection) -> Int {
        return wallpaperSections.count
    }
    
    func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
        return "📂 " + wallpaperSections[index]
    }
}

// MARK: - Custom Transition Functions
extension FeedViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        
        return transition
    }
    
    // Transition
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        
        return transition
    }
}

// MARK: - Instructions Extension Functions
extension FeedViewController: CoachMarksControllerDelegate, CoachMarksControllerDataSource {
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let instructionsView = instructionsController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: .top)
        
        switch (index) {
        case 0:
            instructionsView.bodyView.hintLabel.text = "Scroll through Wallpaper Categories here"
            instructionsView.bodyView.nextLabel.text = "Got it!"
        case 1:
            instructionsView.bodyView.hintLabel.text = "Click here to open and close the Menu: Upload Wallpapers/Sign Out"
            instructionsView.bodyView.nextLabel.text = "Got it!"
        case 2:
            instructionsView.bodyView.hintLabel.text = "Change theme to Dark Mode/Light Mode here"
            instructionsView.bodyView.nextLabel.text = "Got it!"
        default: break
        }
        return (bodyView: instructionsView.bodyView, arrowView: instructionsView.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        // Set Instruction markers around UI Elements
        switch (index) {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: glidingIntView)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: menuBtn)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: themeSwitch)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
}
