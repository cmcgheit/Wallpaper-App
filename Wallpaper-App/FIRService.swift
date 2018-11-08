//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import UIKit
import Firebase
import SwiftyJSON

var wallpaperDataRef = databaseRef.child("wallpapers")
var wallpaperUserRef = databaseRef.child("users")

var selectedImage: UIImage?

class FIRService: NSObject {
    
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
    
    public static func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        wallpaperUserRef.child(uid).updateChildValues(userData)
    }
    
    // MARK: - Fetching Posts for User uid (when have specific user wallpapers feed)
    public static func fetchUserForUID(uid: String, completion: @escaping (User) -> ()) {
        databaseRef.child("wallpapers").observeSingleEvent(of: .value, with: { (snapshot) in
            // be called from wallpapers database node for specific user
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
        _ = ref.observe(.childAdded) { (snapshot) in
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
    public static func saveWalltoFirebase(image: UIImage, wallpaperURL: URL?, wallpaperDesc: String?, wallpaperCategory: String?, completion: @escaping (Error?)->()) {
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
    public static func getMusicCategory(completion: @escaping ([WallpaperCategory]) -> ()) {
        let wallpapersRef = databaseRef.child("wallpapers")
        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "music")
        
        queryRef.observe(.value, with: { snapshot in
            var musicCategory = [WallpaperCategory]()
            for child in snapshot.children {
                let musicCat = WallpaperCategory(snapshot: child as! DataSnapshot)
                musicCategory.append(musicCat!)
            }
            completion(musicCategory)
        })
    }
    // MARK: - Wallpaper Firebase Art Function
    public static func getArtCategory(completion: @escaping ([WallpaperCategory]) -> ()) {
        let wallpapersRef = databaseRef.child("wallpapers")
        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "art")
        
        queryRef.observe(.value, with: { snapshot in
            var artCategory = [WallpaperCategory]()
            for child in snapshot.children {
                let artCat = WallpaperCategory(snapshot: child as! DataSnapshot)
                artCategory.append(artCat!)
            }
            completion(artCategory)
        })
    }
    
    // MARK: - Wallpaper Firebase Sports Function
    public static func getSportsCategory(completion: @escaping ([WallpaperCategory]) -> ()) {
        let wallpapersRef = databaseRef.child("wallpapers")
        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "sports")
        
        queryRef.observe(.value, with: { snapshot in
            var sportsCategory = [WallpaperCategory]()
            for child in snapshot.children {
                let sportsCat = WallpaperCategory(snapshot: child as! DataSnapshot)
                sportsCategory.append(sportsCat!)
            }
            completion(sportsCategory)
        })
    }
    
    // MARK: - Function to Remove Firebase Observers/Listeners
    public static func removeFIRObservers() {
        wallpaperDataRef.removeAllObservers()
        wallpaperUserRef.removeAllObservers()
    }
}

