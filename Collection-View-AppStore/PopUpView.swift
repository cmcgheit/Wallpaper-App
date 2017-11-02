//
//  PopUpView.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 11/1/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit

class PopUpView: UIViewController {
    
    @IBOutlet weak var wallpaperDescLbl: UILabel!
    @IBOutlet weak var wallpaperPopImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wallpaperPopImage.layer.cornerRadius = 14.0

       
    }

}
