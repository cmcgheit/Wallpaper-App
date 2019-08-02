import UIKit

/// A cell that displays within a DrawerViewController. Displays
/// a static image, title label and description label but doesn't
/// do much more than that for the sake of this demo.

class DrawerTableViewCell: UITableViewCell {
    
    /// Static Cell Height
    static let cellHeight: CGFloat = 65.0
    
    /// Icon Image View
    @IBOutlet weak var iconImageView: UIImageView!
    
    /// Title Label
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Description Label
    @IBOutlet weak var descriptionLabel: UILabel!
    
}
