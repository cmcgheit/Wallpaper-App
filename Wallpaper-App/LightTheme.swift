//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit

class LightTheme: ThemeProtocol {

    var mainFontName: String = FontName.regular
    var textColor: UIColor = tealColor
    var buttonColor = UIColor.darkGray
    var accent: UIColor = goldColor
    var backgroundImage = #imageLiteral(resourceName: "SilverCream")
    var cardView: UIColor = UIColor.white
    var tint: UIColor = goldColor
    
    var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
}
