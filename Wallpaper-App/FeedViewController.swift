//  FeedViewController
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import GlidingCollection
import Kingfisher
import SwiftyJSON
import EasyTransitions
import GoogleMobileAds

class FeedViewController: UIViewController {
    
    @IBOutlet var glidingView: GlidingCollection!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var vibeBlurView: UIVisualEffectView!
    var bannerView: GADBannerView!
    
    private var modalTransitionDelegate = ModalTransitionDelegate()
    private var animatorInfo: AppStoreAnimatorInfo?
    
    fileprivate var collectionView: UICollectionView!
    var effect: UIVisualEffect!
    
    var wallpapers = [Wallpaper]() // feed wallpapers from db
    
    var wallpaperCategory = [Wallpaper]() // feed category names from db
    
    var sportsCategory = [String]() // individual feed info?
    var musicCategory = [String]()
    var artCategory = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        // MARK: - Check Auth User Signed-In
        if Auth.auth().currentUser != nil {
            // User signed-In
        } else {
            // User NOT signed-In
        }
        
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
        bannerView.load(GADRequest())
        view.addSubview(bannerView)
        
        func addBannerViewToView(_ bannerView: GADBannerView) {
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            if #available(iOS 11.0, *) {
                positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
            } else {
                // In lower iOS versions, safe area is not available so we use
                // bottom layout guide and view edges, Fallback on earlier versions
            }
        }
        // MARK: - Admob Banner Safe Area Handling/Constraints
        @available (iOS 11, *)
        func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
                guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
                guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
                ])
        }
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
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
        DispatchQueue.main.async {
            // Loading from database?
            FIRService.instance.downloadImagesFromFirebaseData()
            Database.database().reference().child("wallpapers").observe(.childAdded, with: { (snapshot) in // reference to wallpapers in database, load all/individual?
                
                DispatchQueue.main.async { // Adding New Wallpapers to beginning of Wallpaper feed, add specific categories?
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    guard let userDictionary = snapshot.value as? [String : Any] else { return }
                    let user = User(uid: uid, dictionary: userDictionary)
                    let newWallpaper = Wallpaper(user: user, dictionary: userDictionary)
                    self.wallpapers.insert(newWallpaper, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.collectionView.insertItems(at: [indexPath])
                }
            }
            )}
        self.collectionView.reloadData()
        self.glidingView.reloadData()
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
        // let wallpaper = wallpapers[indexPath.row]
        // (section: glidingCollection.expandedItemIndex, atIndex: indexPath.row)
        // cell.imageView.kf.setImage(with: URL(string: wallpaper.wallpaperURL!))
        
        
        let sportsCategory = wallpapers[indexPath.row]
        let musicCategory = wallpapers[indexPath.row]
        let artCategory = wallpapers[indexPath.row]
        let wallpaperCategories = wallpaperCatList[indexPath.row]
        switch wallpaperCategories {
        case .Sports:
            cell.imageView.kf.setImage(with: URL(string: sportsCategory.wallpaperURL!))
        case .Music:
            cell.imageView.kf.setImage(with: URL(string: musicCategory.wallpaperURL!))
        case .Art:
            cell.imageView.kf.setImage(with: URL(string: artCategory.wallpaperURL!))
        default:
            cell.imageView.image = UIImage(named: "placeholder-image")
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - PopUp Transition Function
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


