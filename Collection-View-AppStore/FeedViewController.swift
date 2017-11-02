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

class FeedViewController: UIViewController {
    
    @IBOutlet var glidingView: GlidingCollection!
    fileprivate var collectionView: UICollectionView!
    @IBOutlet weak var uploadBtn: UIButton!
    
    fileprivate var items = ["Sports", "Music", "Art", "LifeStyle"] // Heading category titles
    fileprivate var wallpaperImages: [[UIImage?]] = []
    
    var wallpapers = [Wallpaper]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        Database.database().reference().child("wallpapers").observe(.childAdded, with: { (snapshot) in // reference to wallpapers in database
        
        
        DispatchQueue.main.async { // Adding New Wallpapers to beginning of Wallpaper feed
            let newWallpaper = Wallpaper(snapshot: snapshot)
            self.wallpapers.insert(newWallpaper, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self.collectionView.insertItems(at: [indexPath])
        }
    }
)}
    
    func setup() {
        setupGlidingCollectionView()
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
    

    @IBAction func uploadBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "UploadWallpaperPopUp", sender: nil)
    }
}



// MARK: - CollectionView
extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = glidingView.expandedItemIndex
        return wallpaperImages[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WallpaperCell", for: indexPath) as? WallpaperRoundedCardCell else { return UICollectionViewCell() } // may not need
        let section = glidingView.expandedItemIndex
        let image = wallpaperImages[section][indexPath.row]
        cell.imageView.image = image
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
        let section = glidingView.expandedItemIndex
        let item = indexPath.item
        print("Selected item #\(item) in section #\(section)")
        // segue to popup
    }
    
}

// MARK: - Gliding Collection Extension Functions
extension FeedViewController: GlidingCollectionDatasource {
    
    func numberOfItems(in collection: GlidingCollection) -> Int {
        return items.count //calls titles
    }
    
    func glidingCollection(_ collection: GlidingCollection, itemAtIndex index: Int) -> String {
        return "– " + items[index]
    }
    
}




