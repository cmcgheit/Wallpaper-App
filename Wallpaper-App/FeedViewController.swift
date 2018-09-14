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
    
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var signOutBtn: RoundedRectPinkButton!
    @IBOutlet weak var glidingIntView: UIView!
    @IBOutlet weak var themeSwitch: CustomSwitch!
    
    var handle: AuthStateDidChangeListenerHandle?
    var bannerView: GADBannerView!
    
    var isStatusBarHidden = false
    
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
        attributes.roundCorners = .all(radius: 10)
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        return EntryAttributeWrapper(with: attributes)
        
    }
    
    // MARK: - SwiftEntryKit Alerts
    // Notification Message
    private func showNotificationEKMessage(attributes: EKAttributes, title: String, desc: String, textColor: UIColor, imageName: String? = nil) {
        let title = EKProperty.LabelContent(text: title, style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: UIColor.darkGray))
        let desc = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: UIColor.darkGray))
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: desc)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributesWrapper.attributes)
        
    }
    func signOutSuccessAlert() {
        let titleText = "Signed Out Successfully"
        let descText = "You have signed out of Wall Variety successfully"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: titleText, desc: descText, textColor: UIColor.darkGray)
    }
    
    func problemSignOutAlert() {
        let titleText = "Problem Signing Out"
        let descText = "There is an error signing you out, please try again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: titleText, desc: descText, textColor: UIColor.darkGray)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        customBackBtn()
        DispatchQueue.main.async {
            self.glidingView.reloadData()
        }
        
        catQueue.async {
            self.makeCategories()
        }
        
        applyTheme()
        notificationObservers()
        
        // Theme - checks for theme setting
        if UserDefaults.standard.object(forKey: "lightTheme") != nil {
            UserDefaults.standard.set(true, forKey: "lightTheme")
        } else {
            UserDefaults.standard.set(true, forKey: "darkTheme")
        }
        
        glidingIntView.layer.cornerRadius = 15
        signOutBtn.layer.cornerRadius = 15
        
        // Instructions
        self.instructionsController.dataSource = self
        self.instructionsController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
        self.instructionsController.overlay.allowTap = true
        
        // MARK: - Double Tap Gesture to close PopUpView
        let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedViewController.backgroundTapped))
        closeTapGesture.numberOfTapsRequired = 2
        
        //  MARK: - Admob Banner Properties
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        // bannerView.load(GADRequest())
        let request = GADRequest()
        request.testDevices = ["ca-app-pub-3940256099942544/2934735716"]
        view.addSubview(bannerView)
        
        func addBannerViewToView(_ bannerView: GADBannerView) {
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            if #available(iOS 11.0, *) {
                positionBannerViewFullWidthBottomOfSafeArea(bannerView)
            } else {
                positionBannerViewWidthAtBottomOfView(bannerView)
            }
        }
        @available (iOS 11, *)
        func positionBannerViewFullWidthBottomOfSafeArea(_ bannerView: UIView) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
                guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
                guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
                ])
        }
        
        func positionBannerViewWidthAtBottomOfView(_ bannerView: UIView) {
            view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .leading,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .leading,
                                                  multiplier: 1,
                                                  constant: 0))
            view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .trailing,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .trailing,
                                                  multiplier: 1,
                                                  constant: 0))
            view.addConstraint(NSLayoutConstraint(item: bannerView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: bottomLayoutGuide,
                                                  attribute: .top,
                                                  multiplier: 1,
                                                  constant: 0))
            
        }
        
        // MARK: - Custom Switch
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        // MARK: - Navi Bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.presentTransparentNavigationBar()
        
        // navigationController?.hideTransparentNavigationBar()
        
        // MARK: - Check Auth User Signed-In Listener/Handler
        handle = Auth.auth().addStateDidChangeListener { ( auth, user) in
            if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
                // User signed-In
                UserDefaults.standard.setIsLoggedIn(value: true)
            } else {
                UserDefaults.standard.setIsLoggedIn(value: false)
                // change for navi
                let signUpVC = SignUpViewController()
                self.present(signUpVC, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.backgroundColor = UIColor(patternImage: Theme.current.backgroundImage)
        
        if Theme.themeChanged {
            DispatchQueue.main.async {
                self.collectionView.reloadData() //reload collection for theme change
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(firstTimeVC(_:)), name: .firstTimeViewController, object: nil)
        
        // Transition
        NotificationCenter.default.addObserver(self, selector: #selector(tabBarShow), name: NSNotification.Name(rawValue: "tabBarShow"), object: nil)
    }
    
    func removeNotifications() {
        
        NotificationCenter.default.removeObserver(handleUpdateFeed())
        NotificationCenter.default.removeObserver(firstTimeVC(_:))
        NotificationCenter.default.removeObserver(tabBarShow())
    }
    
    // MARK: - Status Bar
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    // MARK: - Check User First Time Viewing VC (Instructions)
    @objc func firstTimeVC(_ notification: NSNotification) {
        if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
            UserDefaults.standard.setInstructions(value: false)
        } else {
            NotificationCenter.default.post(name: .firstTimeViewController, object: nil)
            UserDefaults.standard.setInstructions(value: true)
            self.instructionsController.start(on: self)
        }
    }
    
    // MARK: - Refresh Wallpaper Feed
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    func handleRefresh() {
        wallpaperCategories.removeAll() //clear wallpaper feed to refresh
        fetchFeed()
    }
    
    // MARK: - Fetch Wallpaper Feed For Specific User
    func fetchFeed() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if Auth.auth().currentUser != nil && authRef.currentUser?.isAnonymous != nil {
            FIRService.fetchUserForUID(uid: uid) { (user) in
                // Load all wallpapers from db?
                //        let indexPath = IndexPath(row: 0, section: 0)
                //        self.collectionView.insertItems(at: [indexPath]) // insert in glidingCollection?
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.glidingView.reloadData()
                }
            }
        } else {
        }
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
        
        UserDefaults.standard.set(true, forKey: "lightTheme")
    }
    
    fileprivate func applyTheme() {
        DispatchQueue.main.async {
            self.view.backgroundColor = UIColor(patternImage: Theme.current.backgroundImage)
            self.glidingIntView.backgroundColor = Theme.current.cardView
            self.view.tintColor = Theme.current.tint
            self.uploadBtn.tintColor = Theme.current.tint
            
        }
    }
    
    // MARK: - Custom Transition
    // Tab Bar Show Function Transition
    @objc func tabBarShow(){
        var tabFrame = self.tabBarController?.tabBar.frame
        let tabHeight = tabFrame?.size.height
        tabFrame?.origin.y = self.view.frame.size.height - tabHeight!
        UIView.animate(withDuration: 0.5, animations: {
            self.tabBarController?.tabBar.frame = tabFrame!
        })
    }
    
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
    
    // MARK: - Upload Button Action
    @IBAction func uploadBtnPressed(_ sender: Any) {
        let uploadVC = storyboard?.instantiateViewController(withIdentifier: "UploadViewController") as! UploadViewController
        uploadVC.providesPresentationContextTransitionStyle = true
        uploadVC.definesPresentationContext = true
        uploadVC.modalPresentationStyle = .overCurrentContext
        uploadVC.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
        present(uploadVC, animated: true)
    }
    
    
    // MARK: - Sign Out Button Action
    @IBAction func signOutBtnPressed() {
        // Signed In User
        if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
            AuthService.instance.logOutUser()
            UserDefaults.standard.setIsLoggedIn(value: false)
            // MARK: Floating Signout Indicator (Success)
            signOutSuccessAlert()
            let backToLoginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(backToLoginVC, animated: true)
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
        
        var tabFrame = self.tabBarController?.tabBar.frame
        let tabHeight = tabFrame?.size.height
        tabFrame?.origin = CGPoint(x: 0, y: self.view.frame.size.height + tabHeight!)
        UIView.animate(withDuration: 0.5, animations: {
            self.tabBarController?.tabBar.frame = tabFrame!
        })
        
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
        
        let instructionsView = instructionsController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        switch (index) {
        case 0:
            instructionsView.bodyView.hintLabel.text = "Scroll through Wallpaper Categories here"
            instructionsView.bodyView.nextLabel.text = "Got it!"
        case 1:
            instructionsView.bodyView.hintLabel.text = "Click to Edit Wallpapers here"
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
            return coachMarksController.helper.makeCoachMark(for: uploadBtn)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
}
