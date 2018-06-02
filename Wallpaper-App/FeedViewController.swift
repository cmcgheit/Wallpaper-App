//  FeedViewController
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import GlidingCollection
import SwiftEntryKit
import Kingfisher
import SwiftyJSON
import EasyTransitions
import GoogleMobileAds
import Instructions

class FeedViewController: UIViewController {
    
    @IBOutlet var glidingView: GlidingCollection!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var vibeBlurView: UIVisualEffectView!
    @IBOutlet weak var signOutBtn: UIButton!
    var bannerView: GADBannerView!
    
    let wallpaperRef = databaseRef.child("wallpapers")
    
    private var modalTransitionDelegate = ModalTransitionDelegate()
    private var animatorInfo: AppStoreAnimatorInfo?
    
    fileprivate var collectionView: UICollectionView!
    var effect: UIVisualEffect!
    
    var wallpapers = [Wallpaper]() // feed wallpapers from db
    
    var wallpaperCategory = [Wallpaper]() // feed category names from db
    
    var sportsCategory = [String]() // individual feed info?
    var musicCategory = [String]()
    var artCategory = [String]()
    
    let instructionsController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        // MARK: - Check Auth User Signed-In
        if Auth.auth().currentUser != nil {
            // User signed-In
        } else {
            let signUpVC = SignUpViewController()
            present(signUpVC, animated: true)
        }
        
        // Firebase
        FIRService.instance.getArtCategory() //downloading functions from firebase, put in array?
        FIRService.instance.getMusicCategory()
        FIRService.instance.getSportsCategory()
        
        // MARK: - Update feed notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: UploadWallpaperPopUp.updateFeedNotificationName, object: nil)
        
        // MARK: - Setup Visual Effect, no blur when app starts
        effect = vibeBlurView.effect
        vibeBlurView.effect = nil
        
        // MARK: - Double Tap Gesture to close PopUpView
        let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedViewController.backgroundTapped))
        closeTapGesture.numberOfTapsRequired = 2
        
        vibeBlurView.isUserInteractionEnabled = true
        vibeBlurView.addGestureRecognizer(closeTapGesture) // tap vibeBlurView (background) to dismiss PopUpView
        
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
        
     // Instructions
        self.instructionsController.dataSource = self
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    // MARK: - Refresh Wallpaper Feed
    func handleRefresh() {
        wallpapers.removeAll() //clear wallpaper feed to refresh
        fetchFeed()
    }
    
    // MARK: - Setup Gliding Collection/Wallpaper Feed
    func setup() {
        setupGlidingCollectionView()
        loadImages()
    }
    
    // MARK: - Fetch Wallpaper Feed
    func fetchFeed() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FIRService.fetchUserForUID(uid: uid) { (user) in
            // Load database for user.uid
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
    
    fileprivate func loadImages() {
        // Load all wallpapers from db
        FIRService.downloadImagesFromFirebaseData {
            for wallpaperItems in self.wallpapers {
                print(self.wallpapers)
            }
        }
//        let indexPath = IndexPath(row: 0, section: 0)
//        self.collectionView.insertItems(at: [indexPath]) // insert in glidingCollection?
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.glidingView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        func uploadBtnPressed(_ sender: Any) {
            presentUploadPopUp()
        }
    }
    
    // MARK: - Upload Pop Up Function/Transition
    @objc func presentUploadPopUp() {
        let uploadPopUpVC = UploadWallpaperPopUp()
        present(uploadPopUpVC, animated: true, completion: nil)
    }
}

// MARK: - CollectionView
extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = glidingView.expandedItemIndex
        if self.wallpapers.count > 0 {
            return wallpapers.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WallpaperCell", for: indexPath) as? WallpaperRoundedCardCell else { return UICollectionViewCell() }
        let section = glidingView.expandedItemIndex
        let wallpaper = wallpapers[indexPath.row]
        //(section: glidingCollection.expandedItemIndex, atIndex: indexPath.row)
        cell.imageView.kf.setImage(with: URL(string: wallpaper.wallpaperURL!))
        
        
        //        let sportsCat = sportsCategory[indexPath.row]
        //        let musicCat = musicCategory[indexPath.row]
        //        let artCat = artCategory[indexPath.row]
        //        let wallpaperCategories = wallpaperCatList[indexPath.row]
        //        switch wallpaperCategories {
        //        case .Sports:
        //            cell.imageView.kf.setImage(with: URL(string: sportsCat))
        //        case .Music:
        //            cell.imageView.kf.setImage(with: URL(string: musicCat))
        //        case .Art:
        //            cell.imageView.kf.setImage(with: URL(string: artCat))
        //        default:
        //            cell.imageView.image = UIImage(named: "placeholder-image")
        //        }
        
        cell.contentView.clipsToBounds = true
        let layer = cell.layer
        let config = GlidingConfig.shared
        layer.shadowOffset = config.cardShadowOffset
        layer.shadowColor = config.cardShadowColor.cgColor
        layer.shadowOpacity = config.cardShadowOpacity
        layer.shadowRadius = config.cardShadowRadius
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        return cell
    }
    
    @IBAction func signOutBtnPressed() {
        if authRef.currentUser != nil {
        AuthService.instance.logOutUser()
        let loginVC = LoginViewController()
        present(loginVC, animated: true)
        } else {
            // MARK: Floating Signout Indicator
            var attributes = EKAttributes.topFloat
            attributes.entryBackground = .color(color: tealColor)
            attributes.roundCorners = .all(radius: 10)
            attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            
            let titleText = "Signed Out Successfully"
            let title = EKProperty.LabelContent(text: titleText, style: .init(font: UIFont(name: "Gills-Sans", size: 20)!, color: UIColor.darkGray))
            let descText = "You have signed out of Wall Variety succesfully. Sign back in from the Login Screen"
            let description = EKProperty.LabelContent(text: descText, style: .init(font: UIFont(name: "Gill-Sans", size: 17)!, color: UIColor.darkGray))
            let image = EKProperty.ImageContent(image: #imageLiteral(resourceName: "exclaimred"))
            let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
            
            let contentView = EKNotificationMessageView(with: notificationMessage)
            SwiftEntryKit.display(entry: contentView, using: attributes)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - PopUp Transition Function
        let section = glidingView.expandedItemIndex
        let item = indexPath.item
        print("selected item #\(item) in section #\(section)")
        let popUpViewController = PopUpViewController()
        
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            present(popUpViewController, animated: true, completion: nil)
            return
        }
        
        let cellFrame = view.convert(cell.frame, from: glidingView)
        let appStoreAnimator = AppStoreAnimator(initialFrame: cellFrame)
        appStoreAnimator.onReady = { cell.isHidden = true}
        appStoreAnimator.onDismissed = { cell.isHidden = false }
        appStoreAnimator.auxAnimation = {popUpViewController.layout(presenting: $0)}
        
        modalTransitionDelegate.set(animator: appStoreAnimator, for: .present)
        modalTransitionDelegate.set(animator: appStoreAnimator, for: .dismiss)
        modalTransitionDelegate.wire(viewController: popUpViewController, with: .regular(.fromTop))
        
        popUpViewController.transitioningDelegate = modalTransitionDelegate
        popUpViewController.modalPresentationStyle = .custom
        
        present(popUpViewController, animated: true, completion: nil)
        animatorInfo = AppStoreAnimatorInfo(animator: appStoreAnimator, index: indexPath)
        
    }
}

// MARK: - Gliding Collection Extension Functions
extension FeedViewController: GlidingCollectionDatasource {
    
    func numberOfItems(in collection: GlidingCollection) -> Int {
        return wallpapers.count
    }
    
    func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
        return wallpaperCatList[index].rawValue
    }
}

// MARK: - Instructions Extension Functions

extension FeedViewController: CoachMarksControllerDelegate, CoachMarksControllerDataSource {
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let instructionsView = instructionsController.helper.makeDefaultCoachViews()
        
        instructionsView.bodyView.hintLabel.text = "Test Instruction"
        instructionsView.bodyView.nextLabel.text = "Got it!"
        
        return (bodyView: instructionsView.bodyView, arrowView: nil)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        let instructionsView = UIView()
        return instructionsController.helper.makeCoachMark(for: instructionsView)
    }
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
}





