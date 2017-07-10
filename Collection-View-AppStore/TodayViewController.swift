//
//  TodayViewController.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    internal let presentStoryAnimationController = StoryViewAnimationController()
    internal let dismissStoryAnimationController = DismissStoryViewAnimationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(collectionView: collectionView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        destinationViewController.transitioningDelegate = self
    }
    
}

extension TodayViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentStoryAnimationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissStoryAnimationController
    }
    
}
