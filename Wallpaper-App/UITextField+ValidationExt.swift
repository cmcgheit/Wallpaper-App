// Wallpaper-App Coded with ♥️ by Carey M

import Foundation
import UIKit

extension UITextField {
    
    func validateField(_ functions: [(String) -> Bool]) -> Bool {
        return functions.map { f in f(self.text ?? "") }.reduce(true) { $0 && $1 }
    }
    
}

extension String {
    func evaluate(with condition: String) -> Bool {
        guard let range = range(of: condition, options: .regularExpression, range: nil, locale: nil) else {
            return false
        }
        
        return range.lowerBound == startIndex && range.upperBound == endIndex
    }
}
