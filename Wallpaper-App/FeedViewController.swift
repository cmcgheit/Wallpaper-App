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

enum WallpaperCategories: String {
    case Sports, Music, Art
}

var wallpaperCatList: [WallpaperCategories] = [.Sports, .Music, .Art]

class FeedViewController: UIViewController {
    
    @IBOutlet var glidingView: GlidingCollection!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var vibeBlurView: UIVisualEffectView!
    
    private var modalTransitionDelegate = ModalTransitionDelegate()
    private var animatorInfo: AppStoreAnimatorInfo?
    
    fileprivate var collectionView: UICollectionView!
    var effect: UIVisualEffect!
    
    var wallpapers = [Wallpaper]()
    
    var wallpaperCategory = [Wallpaper]()
    
    var sportsCategory = [String]()
    var musicCategory = [String]()
    var artCategory = [String]()
    
    // var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        // MARK: - Check Auth User?
        
        
        // MARK: - Setup Visual Effect, no blur when app starts
        effect = vibeBlurView.effect
        vibeBlurView.effect = nil
        
        // MARK: - Double Tap Gesture to close PopUpView
        let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedViewController.backgroundTapped))
        closeTapGesture.numberOfTapsRequired = 2
        
        vibeBlurView.isUserInteractionEnabled = true
        vibeBlurView.addGestureRecognizer(closeTapGesture) // tap vibeBlurView (background) to dismiss PopUpView
        
        // MARK: - Admob Banner Properties
        // bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        // bannerView.rootViewController = self
        // bannerView.load(GADRequest())
//        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
//
//        addBannerViewToView(bannerView)
//    }
//
//    func addBannerViewToView(_ bannerView: GADBannerView) {
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(bannerView)
//        if #available(iOS 11.0, *) {
//            // In iOS 11, we need to constrain the view to the safe area.
//            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
//        }
//        else {
//            // In lower iOS versions, safe area is not available so we use
//            // bottom layout guide and view edges.
//            positionBannerViewFullWidthAtBottomOfView(bannerView)
//        }
//    }
//
//    // MARK: - view positioning
//    @available (iOS 11, *)
//    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
//        // Position the banner. Stick it to the bottom of the Safe Area.
//        // Make it constrained to the edges of the safe area.
//        let guide = view.safeAreaLayoutGuide
//        NSLayoutConstraint.activate([
//            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
//            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
//            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
//            ])
//    }
//        view.addConstraints(
//            [NSLayoutConstraint(item: bannerView,
//                                attribute: .bottom,
//                                relatedBy: .equal,
//                                toItem: bottomLayoutGuide,
//                                attribute: .top,
//                                multiplier: 1,
//                                constant: 0),
//             NSLayoutConstraint(item: bannerView,
//                                attribute: .centerX,
//                                relatedBy: .equal,
//                                toItem: view,
//                                attribute: .centerX,
//                                multiplier: 1,
//                                constant: 0)
//            ])
//    }
    }
    
    @objc func backgroundTapped(recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setup() {
        setupGlidingCollectionView()
        loadImages()
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
            Database.database().reference().child("wallpapers").observe(.childAdded, with: { (snapshot) in // reference to wallpapers in database, load all/individual?
                
                DispatchQueue.main.async { // Adding New Wallpapers to beginning of Wallpaper feed, add specific categories?
                    let newWallpaper = Wallpaper(snapshot: snapshot)
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
                
        //         MARK: - Downloading Images from Firebase storage, currently can only download one individual image
        //                let imageName = NSUUID().uuidString
        //                let imageRef = storageReference.child("images").child("sports").child("chicago-full.png") //\(imageName)
        //                imageRef.getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
        //                    if error != nil {
        //                        let image = UIImage(named: "placeholder-image")
        //                        cell.imageView?.kf.setImage(with: data as? Resource, placeholder: image)
        //                    }
        //                })
        
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


