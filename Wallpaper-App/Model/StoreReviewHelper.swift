//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import StoreKit

struct StoreReviewHelper {
    static func incrementAppOpenedCount() {
        guard var appOpenCount = Defaults.value(forKey: UserDefaults.UserDefaultKeys.appOpenCount.rawValue) as? Int else {
            Defaults.set(1, forKey: UserDefaults.UserDefaultKeys.appOpenCount.rawValue)
            return
        }
        appOpenCount += 1
        Defaults.set(appOpenCount, forKey: UserDefaults.UserDefaultKeys.appOpenCount.rawValue)
    }
    
    static func checkAndAskForReview() {
        guard let appOpenCount = Defaults.value(forKey: UserDefaults.UserDefaultKeys.appOpenCount.rawValue) as? Int else {
            Defaults.set(1, forKey: UserDefaults.UserDefaultKeys.appOpenCount.rawValue)
            return
        }
        
        // Track app count to show request review
        switch appOpenCount {
        case 10,50:
            StoreReviewHelper().requestReview()
        case _ where appOpenCount%100 == 0:
            StoreReviewHelper().requestReview()
        default:
            print("App run count is \(appOpenCount)")
            break
        }
    }
    
    fileprivate func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            showRateUs()
        }
    }
    
    fileprivate func showRateUs() {
        rateApp(appId: appID)
    }
    
    fileprivate func rateApp(appId: String) {
        openURL("itms-apps://itunes.apple.com/app/" + appId)
    }
    
    fileprivate func openURL(_ urlString: String) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.open(url)
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
