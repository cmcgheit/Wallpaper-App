//
//  FeedViewController
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit
import Firebase
import GlidingCollection
import Kingfisher
import SwiftyJSON

enum WallpaperCategories: String {
    case Sports, Music, Art
}

var wallpaperCatList: [WallpaperCategories] = [.Sports, .Music, .Art]

class FeedViewController: UIViewController {
    
    @IBOutlet var glidingView: GlidingCollection!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var vibeBlurView: UIVisualEffectView!
    
    fileprivate var collectionView: UICollectionView!
    var effect: UIVisualEffect!
    
    var wallpapers = [Wallpaper]()
    
    var wallpaperCategory = [Wallpaper]()
    
    var sportsCategory = [String]()
    var musicCategory = [String]()
    var artCategory = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        // MARK: - Setup Visual Effect, no blur when app starts
        effect = vibeBlurView.effect
        vibeBlurView.effect = nil
        
        // MARK: - Double Tap Gesture to close PopUpView
        let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedViewController.backgroundTapped))
        closeTapGesture.numberOfTapsRequired = 2
        
        vibeBlurView.isUserInteractionEnabled = true
        vibeBlurView.addGestureRecognizer(closeTapGesture) // tap vibeBlurView (background) to dismiss PopUpView
        
    }
    
    func backgroundTapped(recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setup() {
        setupGlidingCollectionView()
        loadImages()
    }
    
    
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
            Database.database().reference().child("wallpapers").observe(.childAdded, with: { (snapshot) in // reference to wallpapers in database, add specific categories?
                
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
            if let popup = self.storyboard?.instantiateViewController(withIdentifier: "toUploadWallpaperPopUp") as? UploadWallpaperPopUp {
                self.present(popup, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Pop Up View Animation
    func animateInPopUp() {
        self.view.addSubview(popUpView)
        popUpView.center = self.view.center
        
        popUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popUpView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.vibeBlurView.effect = self.effect
            self.popUpView.alpha = 1
            self.popUpView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOutPopUp() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popUpView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popUpView.alpha = 0
            
            self.vibeBlurView.effect = nil
        }) { (success: Bool) in
            self.popUpView.removeFromSuperview()
        }
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
        let toPopUpView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PopUpView") as UIViewController
        toPopUpView.modalPresentationStyle = .overCurrentContext
        self.present(toPopUpView, animated: true, completion: nil)
        animateInPopUp() // call function or put function here for didselect
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


