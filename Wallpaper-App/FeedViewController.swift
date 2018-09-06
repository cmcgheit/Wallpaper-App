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
    @IBOutlet weak var signOutBtn: RoundedRectPinkButton!
    @IBOutlet weak var glidingIntView: UIView!
    @IBOutlet weak var themeSwitch: CustomSwitch!
    
    var handle: AuthStateDidChangeListenerHandle?
    var bannerView: GADBannerView!
    fileprivate var collectionView: UICollectionView!
    
    private var modalTransitionDelegate = ModalTransitionDelegate()
    
    let presentPopUpViewController = PresentSectionViewController()
    
    var isStatusBarHidden = false
    
    private var animatorInfo: AppStoreAnimatorInfo?
    let transition = TransitionClone()
    var collectionIndex: IndexPath?
    var imageFrame = CGRect.zero
    
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
    
    //     // MARK: - Init
    //        init() {
    //            let layout = UICollectionViewFlowLayout()
    //            layout.itemSize = CGSize(width: 335, height: 412)
    //            layout.minimumLineSpacing = 30
    //            layout.minimumInteritemSpacing = 20
    //            layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    //            layout.scrollDirection = .vertical
    //            super.init(collectionViewLayout: layout)
    //        }
    //
    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        glidingView.reloadData()
        
        makeCategories()
        
        applyTheme()
        
        customBackBtn()
        
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
        
        notificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // MARK: - Navi Bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.presentTransparentNavigationBar()
        
        // navigationController?.hideTransparentNavigationBar()
        
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        view.backgroundColor = UIColor(patternImage: Theme.current.backgroundImage)
        
        if Theme.themeChanged {
            collectionView.reloadData() //reload collection for theme change
        }
        
        func uploadBtnPressed(_ sender: Any) {
//            presentUploadPopUp()
            let uploadPopUpVC = UploadWallpaperPopUp(nibName: "UploadWallpaperPopUp", bundle: nil)
            self.present(uploadPopUpVC, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
        
        self.instructionsController.stop(immediately: true)
        
        removeNotifications()
    }
    
    // MARK: - Categories Function
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: Notification.Name.updateFeedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(firstTimeVC), name: Notification.Name.saveTextInField, object: nil)
        
        // Transition
        NotificationCenter.default.addObserver(self, selector: #selector(tabBarShow), name: NSNotification.Name(rawValue: "tabBarShow"), object: nil)
    }
    
    func removeNotifications() {
        
        NotificationCenter.default.removeObserver(handleUpdateFeed())
        NotificationCenter.default.removeObserver(firstTimeVC())
        NotificationCenter.default.removeObserver(tabBarShow())
    }
    
    @objc func tabBarShow(){
        var tabFrame = self.tabBarController?.tabBar.frame
        let tabHeight = tabFrame?.size.height
        tabFrame?.origin.y = self.view.frame.size.height - tabHeight!
        UIView.animate(withDuration: 0.5, animations: {
            self.tabBarController?.tabBar.frame = tabFrame!
        })
    }
    
    // MARK: - Status Bar
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    //    // MARK: - Cell Selection Setup (EasyTransitions)
    //    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    //        super.viewWillTransition(to: size, with: coordinator)
    //        recalculateItemSizes(givenWidth: size.width)
    //
    //        coordinator.animate(alongsideTransition: nil) { (context) in
    //            //As the position of the cells might have changed, if we have an AppStoreAnimator, we update it's
    //            //"initialFrame" so the dimisss animation still matches
    //            if let animatorInfo = self.animatorInfo {
    //                if let cell = self.collectionView?.cellForItem(at: animatorInfo.index) {
    //                    let cellFrame = self.view.convert(cell.frame, from: self.collectionView)
    //                    animatorInfo.animator.initialFrame = cellFrame
    //                }
    //                else {
    //                    //ups! the cell is not longer on the screen so… ¯\_(ツ)_/¯ lets move it out of the screen
    //                    animatorInfo.animator.initialFrame = CGRect(x: (size.width-animatorInfo.animator.initialFrame.width)/2.0, y: size.height, width: animatorInfo.animator.initialFrame.width, height: animatorInfo.animator.initialFrame.height)
    //                }
    //            }
    //        }
    //    }
    
    //    func recalculateItemSizes(givenWidth width: CGFloat) {
    //        let vcWidth = width - 20//20 is left margin
    //        var width: CGFloat = 355 //335 is ideal size + 20 of right margin for each item
    //        let colums = round(vcWidth / width) //Aproximate times the ideal size fits the screen
    //        width = (vcWidth / colums) - 20 //we substract the right marging
    //        (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: width, height: 412)
    //    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    // MARK: - Check User First Time Viewing VC (Instructions)
    @objc func firstTimeVC() {
        if Auth.auth().currentUser != nil {
            UserDefaults.standard.setInstructions(value: false)
        } else {
            NotificationCenter.default.post(name: .firstTimeViewController, object: nil)
            UserDefaults.standard.setInstructions(value: true)
            self.instructionsController.start(on: self)
        }
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
        collectionView.register(nib, forCellWithReuseIdentifier: "wallpaperCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        glidingView.backgroundColor = UIColor.clear
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
    
//    // MARK: - Upload Pop Up Function/Transition
//    @objc func presentUploadPopUp() {
//        prepareModalPresentation()
//    }
//
//    func prepareModalPresentation() {
//        let modalTransitionsDelegate = ModalTransitionDelegate()
//        let controller = UploadWallpaperPopUp()
//        let popUpController = P(presentedViewController: controller, presenting: self)
//        modalTransitionsDelegate.set(presentationController: popUpController)
//
//        let presentAnimator = PresentationControllerAnimator(finalFrame: popUpController.frameOfPresentedViewInContainerView)
//        presentAnimator.auxAnimation = { controller.animations(presenting: $0)}
//        modalTransitionsDelegate.set(animator: presentAnimator, for: .present)
//        modalTransitionsDelegate.set(animator: presentAnimator, for: .dismiss)
//
//        modalTransitionsDelegate.wire(
//            viewController: self,
//            with: .regular(.fromBottom),
//            navigationAction: { self.present(controller, animated: true, completion: nil)
//
//        })
//
//        presentAnimator.onDismissed = prepareModalPresentation
//        presentAnimator.onPresented = {
//            modalTransitionsDelegate.wire( viewController: controller,
//                                           with: .regular(.fromTop),
//                                           navigationAction: {
//                                            controller.dismiss(animated: true, completion: nil)
//            })
//        }
//        controller.transitioningDelegate = modalTransitionsDelegate
//        controller.modalPresentationStyle = .custom
//    }
    
    // MARK: - Sign Out Button Action
    @IBAction func signOutBtnPressed() {
        if authRef.currentUser != nil {
            AuthService.instance.logOutUser()
            UserDefaults.standard.setIsLoggedIn(value: false)
            // MARK: Floating Signout Indicator (Success)
            let titleText = "Signed Out Successfully"
            let descText = "You have signed out of Wall Variety successfully"
            
            showNotificationEKMessage(attributes: attributesWrapper.attributes, title: titleText, desc: descText, textColor: UIColor.darkGray)
            
            self.performSegue(withIdentifier: "backtoLoginViewController", sender: self)
        } else {
            // MARK: - Floating Signout Indicator (Error)
            let titleText = "Problem Signing Out"
            let descText = "Please check that you have entered the correct email or password"
            showNotificationEKMessage(attributes: attributesWrapper.attributes, title: titleText, desc: descText, textColor: UIColor.darkGray)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaperCell", for: indexPath) as? WallpaperRoundedCardCell else { return UICollectionViewCell() }
        
        let wallpapers = wallpapersAt(section: glidingView.expandedItemIndex, atIndex: indexPath.row)
        cell.setUpCell(wallpaper: wallpapers)
        
        // custom transition
        cell.layer.transform = animateCell(cellFrame: cell.frame)
        
        // popup transition
        transition.destinationFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: cell.imageView.frame.height * view.frame.width / cell.imageView.frame.width)
        
        imageFrame = cell.imageView.frame
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! WallpaperRoundedCardCell
        // MARK: - PopUp Transition Function
        let section = glidingView.expandedItemIndex
        
        let popUpVC = PopUpViewController()
        
        //        guard let cell = collectionView.cellForItem(at: indexPath) else {
        //            present(detailViewController, animated: true, completion: nil)
        //            return
        //        }
        
        popUpVC.selectedIndex = indexPath
        popUpVC.wallpaper = allWallpapersAt(section: section)
        popUpVC.placeholder = placeholderFor(section: section)
        
        popUpVC.wallpaperPhotoURL = cell.wallpaper.wallpaperURL
        popUpVC.wallpaperDescText = cell.wallpaper.wallpaperDesc
        
        // cell.layer.transform = animateCell(cellFrame: cellFrame) // parallax
        
        // Custom
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        popUpVC.transitioningDelegate = self
        let cellFrame = collectionView.convert((attributes?.frame)!, to: view)
        
        presentPopUpViewController.cellFrame = cellFrame
        presentPopUpViewController.cellTransform = animateCell(cellFrame: cellFrame)
        
        // PopUp Custom Transition
        //        collectionIndex = indexPath
        //
        //        if let cell = collectionView.cellForItem(at: indexPath) as? WallpaperRoundedCardCell {
        //            let a = collectionView.convert(cell.frame, to: collectionView.superview)
        //
        //            transition.startingFrame = CGRect(x: a.minX+15, y: a.minY+15, width: 375 / 414 * view.frame.width - 30, height: 408 / 736 * view.frame.height - 30)
        //
        //            let sb = storyboard?.instantiateViewController(withIdentifier: "popUpVC") as! PopUpViewController
        //            sb.image = picture[indexPath.row]
        //            sb.transitioningDelegate = self
        //            sb.modalPresentationStyle = .custom
        //
        //            self.present(sb, animated: true, completion: nil)
        
        isStatusBarHidden = true
        UIView.animate(withDuration: 0.5) { // hides status bar when transition to popup
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        // let cellFrame = view.convert(cell.frame, from: collectionView)
        
        //        let appStoreAnimator = AppStoreAnimator(initialFrame: cellFrame)
        //        appStoreAnimator.onReady = { cell.isHidden = true }
        //        appStoreAnimator.onDismissed = { cell.isHidden = false }
        //        appStoreAnimator.auxAnimation = { popUpVC.layout(presenting: $0) }
        //
        //        modalTransitionDelegate.set(animator: appStoreAnimator, for: .present)
        //        modalTransitionDelegate.set(animator: appStoreAnimator, for: .dismiss)
        //        modalTransitionDelegate.wire(
        //            viewController: popUpVC,
        //            with: .regular(.fromTop),
        //            navigationAction: {
        //                popUpVC.dismiss(animated: true, completion: nil)
        //        })
        
        //        popUpVC.transitioningDelegate = modalTransitionDelegate
        //        popUpVC.modalPresentationStyle = .custom
        
        present(popUpVC, animated: true, completion: nil)
        // animatorInfo = AppStoreAnimatorInfo(animator: appStoreAnimator, index: indexPath)
        
    }
    
    // PopUp Transition
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("collectionViewLayout")
        return CGSize(width: 375 / 414 * view.frame.width, height: 408 / 736 * view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("didHighlight")
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
        return "⚡ " + wallpaperSections[index]
    }
}

extension FeedViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        
        return transition
        // return presentPopUpViewController
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
