//Created with ♥️ by: Carey M

import UIKit

class FeedVC: StatusBarAnimatableViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    
    private var transition: CardTransition?
    
    private lazy var wallpaperModel: [WallpaperItem] = [
        WallpaperItem(title: "Chicago Bulls",
                      header: "Chicago NBA basketball team",
                      desc: "Pro basketball team out of Chicago, IL", image: UIImage(named: "chicagobasketball.png")!.resize(toWidth: UIScreen.main.bounds.size.width * (1/Constants.cardHighlightedFactor))),
        WallpaperItem(title: "Cleveland Cavaliers",
                      header: "Cleveland NBA basketball team",
                      desc: "Pro basketball team out of Cleveland, OH.",
                      image: UIImage(named: "clevelandbasketball.png")!.resize(toWidth: UIScreen.main.bounds.size.width * (1/Constants.cardHighlightedFactor))),
        WallpaperItem(title: "Washington Wizards",
                      header: "Washington NBA basketball team",
                      desc: "Pro basketball team out of Washington, DC",
                      image: UIImage(named:"dcbasketball.png")!.resize(toWidth: UIScreen.main.bounds.size.width * (1/Constants.cardHighlightedFactor))),
        WallpaperItem(title: "Memphis Grizzles",
                      header: "Memphis NBA basketball team",
                      desc: "Pro basketball team out of Memphis, TN",
                      image: UIImage(named: "memphisbasketball.png")!.resize(toWidth: UIScreen.main.bounds.size.width * (1/Constants.cardHighlightedFactor))),
        WallpaperItem(title: "Minnesota Timberwolves",
                      header: "Minnesota NBA basketball team",
                      desc: "Pro basketball team out of Minneapolis, MN",
                      image: UIImage(named: "minnebasketball.png")!.resize(toWidth: UIScreen.main.bounds.size.width * (1/Constants.cardHighlightedFactor))),
        WallpaperItem(title: "Philadelphia Sixers",
                      header: "Philadelphia NBA basketball team",
                      desc: "Pro basketball team out of Philadelphia, PA",
                      image: UIImage(named: "philabasketball.png")!.resize(toWidth: UIScreen.main.bounds.size.width * (1/Constants.cardHighlightedFactor))),
        WallpaperItem(title: "San Antonio Spurs",
                      header: "San Antonio NBA basketball team",
                      desc: "Pro basketball team out of San Antonio, TX", image: UIImage(named: "sanantoniobasketball.png")!.resize(toWidth: UIScreen.main.bounds.size.width * (1/Constants.cardHighlightedFactor))),
        WallpaperItem(title: "Toronto Raptors",
                      header: "Toronto NBA basketball team",
                      desc: "Pro basketball team out of Toronto, Canada", image: UIImage(named: "torontobasketball.png")!.resize(toWidth: UIScreen.main.bounds.size.width * (1/Constants.cardHighlightedFactor))),
        WallpaperItem(title: "Utah Jazz",
                      header: "Utah NBA basketball team",
                      desc: "Pro basketball team out of Salt Lake City, UT",
                      image: UIImage(named: "utahbasketball.png")!.resize(toWidth: UIScreen.main.bounds.size.width * (1/Constants.cardHighlightedFactor)))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make it responds to highlight state faster
        collectionView.delaysContentTouches = false
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = .init(top: 20, left: 0, bottom: 64, right: 0)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.register(UINib(nibName: "\(PopUpCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "cardCell")
    }
    
    override var statusBarAnimatableConfig: StatusBarAnimatableConfig {
        return StatusBarAnimatableConfig(prefersHidden: false,
                                         animation: .slide)
    }
}

extension FeedVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpaperModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! PopUpCollectionViewCell
        cell.cardView?.viewModel = wallpaperModel[indexPath.row]
    }
}

extension FeedVC {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cardHorizontalOffset: CGFloat = 20
        let cardHeightByWidthRatio: CGFloat = 1.2
        let width = collectionView.bounds.size.width - 2 * cardHorizontalOffset
        let height: CGFloat = width * cardHeightByWidthRatio
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Get tapped cell location
        let cell = collectionView.cellForItem(at: indexPath) as! PopUpCollectionViewCell
        
        // Freeze highlighted state (or else it will bounce back)
        cell.freezeAnimations()
        
        // Get current frame on screen
        let currentCellFrame = cell.layer.presentation()!.frame
        
        // Convert current frame to screen's coordinates
        let cardPresentationFrameOnScreen = cell.superview!.convert(currentCellFrame, to: nil)
        
        // Get card frame without transform in screen's coordinates  (for the dismissing back later to original location)
        let cardFrameWithoutTransform = { () -> CGRect in
            let center = cell.center
            let size = cell.bounds.size
            let r = CGRect(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2,
                width: size.width,
                height: size.height
            )
            return cell.superview!.convert(r, to: nil)
        }()
        
        let wallModel = wallpaperModel[indexPath.row]
        
        // Set up card detail view controller
        let vc = storyboard!.instantiateViewController(withIdentifier: "popUpDetailVC") as! PopUpDetailVC
        vc.cardViewModel = wallModel.highlightedImage()
        vc.unhighlightedCardViewModel = wallModel // Keep the original one to restore when dismiss
        let params = CardTransition.Params(fromCardFrame: cardPresentationFrameOnScreen,
                                           fromCardFrameWithoutTransform: cardFrameWithoutTransform,
                                           fromCell: cell)
        transition = CardTransition(params: params)
        vc.transitioningDelegate = transition
        
        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        vc.modalPresentationCapturesStatusBarAppearance = true
        vc.modalPresentationStyle = .custom
        
        present(vc, animated: true, completion: { [unowned cell] in
            // Unfreeze
            cell.unfreezeAnimations()
        })
    }
}
