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
    
    var sportsCategory = [String]()
    var musicCategory = [String]()
    var artCategory = [String]()
    
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
    func getMusicCategory() {
        self.musicCategory = [] // starts as empty array
        let wallpapersRef = databaseRef.child("wallpapers")
        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "music")
        
        queryRef.observe(.childAdded, with: { snapshot in
            
            if ( snapshot.value is NSNull ) {
                print("no snapshot made from music node")
            } else {
                
                for child in (snapshot.children) {
                    
                    let snap = child as! DataSnapshot
                    
                    let musicDict = snap.value as! [String: String]
                    
                    let wallpaperCategoryTitle = musicDict["wallpaperCategory"]
                    let wallpaperDesc = musicDict["wallpaperDesc"]
                    let wallpaperURL = musicDict["wallpaperURL"]
                    self.musicCategory.append(wallpaperCategoryTitle!)
                    self.musicCategory.append(wallpaperDesc!)
                    self.musicCategory.append(wallpaperURL!)
                }
            }
        })
    }
    // MARK: - Wallpaper Firebase Art Function
    func getArtCategory() {
        self.artCategory = []
        let wallpapersRef = databaseRef.child("wallpapers")
        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "art")
        
        queryRef.observe(.childAdded, with: { snapshot in
            
            if ( snapshot.value is NSNull ) {
                print("no snapshot made from art node")
            } else {
                
                for child in (snapshot.children) {
                    
                    let snap = child as! DataSnapshot
                    
                    let artDict = snap.value as! [String: String]
                    
                    let wallpaperCategoryTitle = artDict["wallpaperCategory"]
                    let wallpaperDesc = artDict["wallpaperDesc"]
                    let wallpaperURL = artDict["wallpaperURL"]
                    self.artCategory.append(wallpaperCategoryTitle!)
                    self.artCategory.append(wallpaperDesc!)
                    self.artCategory.append(wallpaperURL!)
                }
            }
        })
    }
    // MARK: - Wallpaper Firebase Sports Function
    func getSportsCategory() {
        self.sportsCategory = [] //init it any time this func is called.
        let wallpapersRef = databaseRef.child("wallpapers")
        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "sports")
        
        queryRef.observe(.childAdded, with: { snapshot in
            
            if ( snapshot.value is NSNull ) {
                print("no snapshot made from music node")
            } else {
                
                for child in (snapshot.children) {
                    
                    let snap = child as! DataSnapshot //each child is a snapshot
                    
                    let sportsDict = snap.value as! [String: String] // make art dict from art node in firebase data
                    
                    let wallpaperCategoryTitle = sportsDict["wallpaperCategory"]
                    let wallpaperDesc = sportsDict["wallpaperDesc"]
                    let wallpaperURL = sportsDict["wallpaperURL"]
                    self.sportsCategory.append(wallpaperCategoryTitle!)
                    self.sportsCategory.append(wallpaperDesc!)
                    self.sportsCategory.append(wallpaperURL!)
                }
            }
        })
    }
}

