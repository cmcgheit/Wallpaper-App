//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit

class LightTheme: ThemeProtocol {
    
    var mainFontName: String = FontName.regular
    var mainBackgroundColor: UIColor = UIColor.lightGray
    var textColor: UIColor = tealColor
    var accent: UIColor = goldColor
    var cardView: UIColor = UIColor.white
    var tint: UIColor = goldColor
    
    var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
}
