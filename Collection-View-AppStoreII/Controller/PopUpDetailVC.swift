//Created with ♥️ by: Carey M

import UIKit
// import EasyTransitions

class PopUpDetailVC: UIViewController {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backView: UIView!
    
    // TODO: - Inject card detail.
    init() {
        super.init(nibName: String(describing: PopUpDetailVC.self),
                   bundle: Bundle(for: PopUpDetailVC.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.delegate = self
        backView.set(shadowStyle: .todayCard)
        layout(presenting: false)
        if #available(iOS 11, *) {
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    func layout(presenting: Bool) {
        let cardLayout: CardView.Layout = presenting ? .expanded : .collapsed
        contentView.layer.cornerRadius = cardLayout.cornerRadius
        backView.layer.cornerRadius = cardLayout.cornerRadius
        cardView.set(layout: cardLayout)
    }
}

extension PopUpDetailVC: CardViewDelegate {
    func closeCardView() {
        dismiss(animated: true, completion: nil)
    }
}

