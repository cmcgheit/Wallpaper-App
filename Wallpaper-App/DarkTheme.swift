//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit

class DarkTheme: ThemeProtocol {
    
    var mainFontName: String = FontName.regular
    var mainBackgroundColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var accent: UIColor = orangeColor
    var cardView: UIColor = UIColor.black
    var tint: UIColor = UIColor.darkGray
    
    var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
