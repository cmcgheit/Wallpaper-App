//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import UIKit
import Firebase
import SwiftyJSON

var selectedImage: UIImage?

class FIRService: NSObject {
    
    var wallpaperDataRef = databaseRef.child("wallpapers")
    var wallpaperUserRef = databaseRef.child("users")
    
    var artCatStorRef = storageRef.child("images").child("art")
    var musicCatStorRef = storageRef.child("images").child("music")
    var sportsCatStorRef = storageRef.child("images").child("sports")
    
    var artCatDataRef = databaseRef.child("wallpapers").queryOrdered(byChild: "wallpaperCategory/art")
    var musicCatDataRef = databaseRef.child("wallpapers").queryOrdered(byChild: "wallpaperCategory/music")
    var sportsCatDataRef = databaseRef.child("wallpapers").queryOrdered(byChild: "wallpaperCategory/sports")
    
    private static let _instance = FIRService()
    
    static var instance: FIRService {
        return _instance
    }
    
    // MARK: - Fetching Posts for User uid (when have specific user wallpapers feed)
    public static func fetchUserForUID(uid: String, completion: @escaping (User) -> ()) {
        databaseRef.child("uid").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { (error) in
            print("Failed to fetch user specific posts:", error)
        }
    }
    
    // MARK: - Download Wallpapers FROM Firebase Database
    public static func downloadImagesFromFirebaseData(completion: @escaping () -> ()) {
        // guard let uid = authRef.currentUser?.uid else { return }
        let ref = databaseRef.child("wallpapers")//.child(uid) download wallpapers for specific user
        let handle = ref.observe(.childAdded) { (snapshot) in
            if let wallpaperPostDict = snapshot.value as? [String: Any] {
                let wallpaperURL = wallpaperPostDict["wallpaperURL"] as! String
                let wallpaperDesc = wallpaperPostDict["wallpaperDesc"] as? String
                let wallpaperCategory = wallpaperPostDict["wallpaperCategory"] as! String
                
                var newWallpaperPost = Wallpaper(dictionary: wallpaperPostDict)
                newWallpaperPost.wallpaperURL = wallpaperURL
                newWallpaperPost.wallpaperDesc = wallpaperDesc
                newWallpaperPost.wallpaperCategory = wallpaperCategory
            }
            completion()
        }
    }
    
    
    // MARK: - Download Wallpapers FROM Firebase Storage
    public static func downloadImagesFromFirebaseStor(url: URL, completion: @escaping (UIImage?, Error?) -> ()) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        ref.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if error != nil {
                completion(nil, error!)
            } else {
                if let data = data {
                    if let wallpaperImg = UIImage(data: data) {
                        completion(wallpaperImg, nil)
                    }
                }
            }
        }
    }
    
    //MARK: - Upload/Save Images to Firebase Storage/Firebase Database
    public static func saveWalltoFirebase(image: UIImage, wallpaperURL: String?, wallpaperDesc: String?, wallpaperCategory: String?, completion: @escaping (Error?)->()) {
        // guard let uid = authRef.currentUser?.uid else { return }
        let ref = storageRef.child("images") //.child(uid) add images to specific user uid
        guard let data = image.prepareImageForSaving() else { return }
        ref.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                completion(error)
            } else {
                let dbRef = databaseRef.child("wallpapers") //.child(uid).childByAutoId() add image to specific user uid dictionary in database
                ref.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print("Error saving wallpaper to Firebase database:", error!)
                        completion(error)
                    } else {
                        if let wallpaperURL = url?.absoluteString {
                            let dbDict: [String: Any] = ["wallpaperURL": wallpaperURL,
                                                         "wallpaperDesc": wallpaperDesc!,
                                                         "wallpaperCategory": wallpaperCategory!]
                            dbRef.setValue(dbDict)
                            completion(nil)
                        }
                    }
                })
            }
        }
    }
    
    // MARK: - Delete Wallpaper from Storage Function
    public static func removeFromStorage(wallpaper: Wallpaper, completion: @escaping (Bool) -> ()) {
        if let url = wallpaper.wallpaperURL {
            let ref = Storage.storage().reference(forURL: url)
            ref.delete { (error) in
                if error != nil {
                    print("Error! Couldn't delete wallpaper")
                    completion(false)
                } else {
                    print("Successfully deleted wallpaper from storage")
                }
            }
        }
    }
    
    // MARK: - Wallpaper Category Functions
    
    // MARK: - Wallpaper Firebase Music Function
    public static func getMusicCategory(completion: @escaping ([[String : Any]]) -> ()) {
        var musicCategory = [[String: Any]]()
        let wallpapersRef = databaseRef.child("wallpapers")
        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "music")
        
        queryRef.observe(.childAdded, with: { snapshot in
            
            if let musicDict = snapshot.value as? [String: Any] {
                let wallpaperURL = musicDict["wallpaperURL"] as? String
                let wallpaperDesc = musicDict["wallpaperDesc"] as? String
                let wallpaperCategory = musicDict["wallpaperCategory"] as? String
                musicCategory.append(musicDict)
                
                completion(musicCategory)
            }
        })
    }
    // MARK: - Wallpaper Firebase Art Function
    public static func getArtCategory(completion: @escaping ([[String : Any]]) -> ()) {
        var artCategory = [[String: Any]]()
        let wallpapersRef = databaseRef.child("wallpapers")
        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "art")
        
        queryRef.observe(.childAdded, with: { snapshot in
            
            if let artDict = snapshot.value as? [String: Any] {
                let wallpaperURL = artDict["wallpaperURL"] as? String
                let wallpaperDesc = artDict["wallpaperDesc"] as? String
                let wallpaperCategory = artDict["wallpaperCategory"] as? String
                artCategory.append(artDict)
                
                completion(artCategory)
            }
            
        })
    }
    // MARK: - Wallpaper Firebase Sports Function
    public static func getSportsCategory(completion: @escaping ([[String: Any]]) -> ()) {
        var sportsCategory = [[String: Any]]()
        let wallpapersRef = databaseRef.child("wallpapers")
        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "sports")
        
        queryRef.observe(.childAdded, with: { snapshot in
            if let sportsDict = snapshot.value as? [String: Any] {
                let wallpaperURL = sportsDict["wallpaperURL"] as? String
                let wallpaperDesc = sportsDict["wallpaperDesc"] as? String
                let wallpaperCategory = sportsDict["wallpaperCategory"] as? String
                sportsCategory.append(sportsDict)
                
                completion(sportsCategory)
            }
        })
    }
}

