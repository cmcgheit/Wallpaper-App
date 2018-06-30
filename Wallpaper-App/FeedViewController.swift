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
import EasyTransitions
import Instructions

class FeedViewController: UIViewController {
    
    @IBOutlet var glidingView: GlidingCollection!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var glidingIntView: UIView!
    @IBOutlet weak var themeSwitch: CustomSwitch!
    
    var handle: AuthStateDidChangeListenerHandle?
    var bannerView: GADBannerView!
    fileprivate var collectionView: UICollectionView!
    
    private var modalTransitionDelegate = ModalTransitionDelegate()
    private var animatorInfo: AppStoreAnimatorInfo?
    
    var wallpaperCategories = [WallpaperCategories]() //all
    var wallpaperSections = ["Art", "Music", "Sports"]
    var sportsCategory = [WallpaperCategory]()
    var musicCategory = [WallpaperCategory]()
    var artCategory = [WallpaperCategory]()
    
    // Placeholders - set individual eventually
    let artPlaceholder = UIImage(named: "placeholder-image")
    let musicPlaceholder = UIImage(named: "placeholder-image")
    let sportsPlaceholder = UIImage(named: "placeholder-image")
    
    let instructionsController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        makeCategories()
        
        applyTheme()
        
        // Theme - checks for theme setting
        if UserDefaults.standard.object(forKey: "lightTheme") != nil {
            UserDefaults.standard.set(true, forKey: "lightTheme")
        } else {
            UserDefaults.standard.set(true, forKey: "darkTheme")
        }
        
        // Instructions
        self.instructionsController.dataSource = self
        self.instructionsController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
        self.instructionsController.overlay.allowTap = true
        
        // MARK: - Update feed Notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: UploadWallpaperPopUp.updateFeedNotificationName, object: nil)
        
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
    }
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        // MARK: - Check Auth User Signed-In Listener/Handler
        handle = Auth.auth().addStateDidChangeListener { ( auth, user) in
            if Auth.auth().currentUser != nil {
                // User signed-In
                UserDefaults.standard.setIsLoggedIn(value: true)
            } else {
                UserDefaults.standard.setIsLoggedIn(value: false)
                let signUpVC = SignUpViewController()
                self.present(signUpVC, animated: true)
            }
        }
        // MARK: - Check for User (Instructions)
        if Auth.auth().currentUser != nil {
            // User signed-In, don't show instructions, way to show instructions to user only once
            UserDefaults.standard.setInstructions(value: false)
        } else {
            // No user, show instructions
            UserDefaults.standard.setInstructions(value: true)
            self.instructionsController.start(on: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        view.backgroundColor = UIColor(patternImage: Theme.current.backgroundImage)
        
        if Theme.themeChanged {
            collectionView.reloadData() //reload collection for theme change
        }
        
        func uploadBtnPressed(_ sender: Any) {
            presentUploadPopUp()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
        
        self.instructionsController.stop(immediately: true)
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    // MARK: - Refresh Wallpaper Feed
    func handleRefresh() {
        wallpaperCategories.removeAll() //clear wallpaper feed to refresh
        fetchFeed()
    }
    
    // MARK: - Setup Gliding Collection/Wallpaper Feed
    func setup() {
        setupGlidingCollectionView()
    }
    
    // MARK: - Fetch Wallpaper Feed For Specific User
    func fetchFeed() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if Auth.auth().currentUser != nil {
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
    private func setupGlidingCollectionView() {
        glidingView.dataSource = self
        
        let nib = UINib(nibName: "WallpaperRoundedCardCell", bundle: nil)
        collectionView = glidingView.collectionView
        collectionView.register(nib, forCellWithReuseIdentifier: "WallpaperCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = glidingView.backgroundColor
    }
    
    
    // MARK: - Theme
    @IBAction func themeChanged(_ sender: CustomSwitch) {
        
        Theme.current = sender.isOn ? LightTheme() : DarkTheme()
        Theme.themeChanged = true
        applyTheme()
        
        UserDefaults.standard.set(true, forKey: "lightTheme")
    }
    
    fileprivate func applyTheme() {
        
        view.backgroundColor = UIColor(patternImage: Theme.current.backgroundImage)
        
    }
    
    // MARK: - Upload Pop Up Function/Transition
    @objc func presentUploadPopUp() {
        let uploadPopUpVC = UploadWallpaperPopUp()
        present(uploadPopUpVC, animated: true, completion: nil)
    }
    
    // MARK: - Sign Out Button Action
    @IBAction func signOutBtnPressed() {
        if authRef.currentUser != nil {
            AuthService.instance.logOutUser()
            UserDefaults.standard.setIsLoggedIn(value: false)
            // MARK: Floating Signout Indicator (Success)
            var attributes = EKAttributes.topFloat
            attributes.entryBackground = .color(color: UIColor.white)
            attributes.roundCorners = .all(radius: 10)
            attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            
            let titleText = "Signed Out Successfully"
            let title = EKProperty.LabelContent(text: titleText, style: .init(font: UIFont.gillsLightFont(ofSize: 20), color: UIColor.darkGray))
            let descText = "You have signed out of Wall Variety successfully"
            let description = EKProperty.LabelContent(text: descText, style: .init(font: UIFont.gillsLightFont(ofSize: 17), color: UIColor.darkGray))
            let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35), makeRound: true)
            let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
            
            let contentView = EKNotificationMessageView(with: notificationMessage)
            SwiftEntryKit.display(entry: contentView, using: attributes)
            
            self.performSegue(withIdentifier: "backtoLoginViewController", sender: self)
        } else {
            // MARK: - Floating Signout Indicator (Error)
            var attributes = EKAttributes.topFloat
            attributes.entryBackground = .color(color: UIColor.white)
            attributes.roundCorners = .all(radius: 10)
            attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            
            let titleText = "Problem Signing Out"
            let title = EKProperty.LabelContent(text: titleText, style: .init(font: UIFont.gillsLightFont(ofSize: 20), color: UIColor.darkGray))
            let descText = "Please check that you have entered the correct email or password"
            let description = EKProperty.LabelContent(text: descText, style: .init(font: UIFont.gillsLightFont(ofSize: 17), color: UIColor.darkGray))
            let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35), makeRound: true)
            let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
            
            let contentView = EKNotificationMessageView(with: notificationMessage)
            SwiftEntryKit.display(entry: contentView, using: attributes)
            
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
    
    func allWallpapersAt(section: Int) -> [WallpaperCategory] {
        if section == 0 {
            return artCategory
        } else if section == 1 {
            return musicCategory
        } else {
            return sportsCategory
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


// MARK: - CollectionView
extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfWallpapersAt(section: glidingView.expandedItemIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WallpaperCell", for: indexPath) as? WallpaperRoundedCardCell else { return UICollectionViewCell() }
        
        let wallpapers = wallpapersAt(section: glidingView.expandedItemIndex, atIndex: indexPath.row)
        cell.setUpCell(wallpaper: wallpapers)
        let layer = cell.layer
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! WallpaperRoundedCardCell
        // MARK: - PopUp Transition Function
        let section = glidingView.expandedItemIndex
        
        let popUpVC = PopUpViewController()
        popUpVC.selectedIndex = indexPath
        popUpVC.wallpaper = allWallpapersAt(section: section)
        popUpVC.placeholder = placeholderFor(section: section)

        popUpVC.wallpaperPhotoURL = cell.wallpaper.wallpaperURL
        popUpVC.wallpaperDescText = cell.wallpaper.wallpaperDesc
    
        let cellFrame = view.convert(cell.frame, from: glidingView)
        let appStoreAnimator = AppStoreAnimator(initialFrame: cellFrame)
        appStoreAnimator.onReady = { cell.isHidden = true}
        appStoreAnimator.onDismissed = { cell.isHidden = false }
        appStoreAnimator.auxAnimation = {popUpVC.layout(presenting: $0)}
        
        modalTransitionDelegate.set(animator: appStoreAnimator, for: .present)
        modalTransitionDelegate.set(animator: appStoreAnimator, for: .dismiss)
        modalTransitionDelegate.wire(viewController: popUpVC, with: .regular(.fromTop))
        
        popUpVC.transitioningDelegate = modalTransitionDelegate
        popUpVC.modalPresentationStyle = .custom
        
        present(popUpVC, animated: true, completion: nil)
        animatorInfo = AppStoreAnimatorInfo(animator: appStoreAnimator, index: indexPath)
        
    }
}

// MARK: - Gliding Collection Extension Functions
extension FeedViewController: GlidingCollectionDatasource {
    
    func numberOfItems(in collection: GlidingCollection) -> Int {
        return wallpaperSections.count
    }
    
    func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
        return "⚡ " + wallpaperSections[index]
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

