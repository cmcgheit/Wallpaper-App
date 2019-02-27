//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit

protocol ThemeProtocol {
    
    var mainFontName: String { get }
    var mainBackgroundColor: UIColor { get }
    var textColor: UIColor { get }
    var accent: UIColor { get }
    var cardView: UIColor { get }
    var tint: UIColor { get }
}