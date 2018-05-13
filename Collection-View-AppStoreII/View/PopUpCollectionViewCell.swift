//Created with ♥️ by: Carey M 

import UIKit
// import EasyTransitions

class PopUpCollectionViewCell: UICollectionViewCell, NibLoadableView {
    
    @IBOutlet weak var cardView: CardView!

    override func awakeFromNib() {
        super.awakeFromNib()
        set(shadowStyle: .todayCard)
    }

}
