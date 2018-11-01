//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit

class DarkTheme: ThemeProtocol {
    
    var mainFontName: String = FontName.regular
    var textColor: UIColor = UIColor.white
    var accent: UIColor = orangeColor
    var backgroundImage = #imageLiteral(resourceName: "BlackGrey")
    var cardView: UIColor = UIColor.black
    var tint: UIColor = orangeColor
    
    var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
