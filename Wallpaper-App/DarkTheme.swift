//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit

class DarkTheme: ThemeProtocol {
    
    var mainFontName: String = FontName.regular
    var textColor: UIColor = UIColor.white
    var buttonColor: UIColor = UIColor.white
    var accent: UIColor = orangeColor
    var backgroundImage = #imageLiteral(resourceName: "HypnoticFluidBlack")
    var cardView: UIColor = UIColor.black
    var tint: UIColor = UIColor.darkGray
    
    var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
