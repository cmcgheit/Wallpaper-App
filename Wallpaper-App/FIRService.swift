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
    static func fetchUserForUID(uid: String, completion: @escaping (User) -> ()) {
        databaseRef.child("uid").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { (error) in
            print("Failed to fetch user specific posts:", error)
        }
    }
    
    // MARK: - Download Wallpapers FROM Firebase Database
    
    func downloadImagesFromFirebaseData() {
        guard let uid = authRef.currentUser?.uid else { return }
        let wallpaperDataDownloadRef = databaseRef.child("wallpapers").child(uid)
        wallpaperDataDownloadRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value)
            
            guard let wallpaperDataDictionaries = snapshot.value as? [String: Any] else { return }
            
            wallpaperDataDictionaries.forEach({ (key, value) in
                print("Key: \(key), Value: \(value)")
                
                guard let dictonary = value as? [String: Any] else { return }
                let wallpaperURL = dictonary["wallpaperURL"] as? String
            })
        }) { (error) in
            print("Failed to fetch wallpapers feed from database", error)
        }
    }
    
    
    // MARK: - Download Images FROM Firebase Storage
    func downloadImagesFromFirebaseStor() {
        if let wallpaperURL = wallpaper.wallpaperURL {
            let wallpaperStorageRef = Storage.storage().reference(forURL: wallpaperURL)
            wallpaperStorageRef.getData(maxSize: 2 * 1024 * 1024, completion: { [weak self] (data, error) in
                if let error = error {
                    print("Error downloading wallpapers from storage: \(error)")
                } else {
                    if let wallpaperData = data {
                        DispatchQueue.main.async {
                            let image = UIImage(data: wallpaperData)
                            //                            self?.imageView.image = image
                        }
                    }
                }
            })
        }
    }
    
    // Upload Images to Firebase Storage
    func uploadWallpaperToFirebase() {
        guard let image = selectedImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        let filename = NSUUID().uuidString // creates name to be uploaded
        storageRef.child("images").child(filename).putData(uploadData, metadata: nil) { (metadata, error) in
            
            if let error = error {
                print("Failed to upload wallpaper image", error)
                return
            }
            
            guard let metadata = metadata else {
                // error
                return
            }
            
            storageRef.downloadURL { (url, error ) in
                guard let downloadURL = url else {
                    // Error
                    return
                }
                print("Successfully uploaded wallpaper image:", downloadURL)
                // After upload to storage, save image to database
                self.saveImageToDatabase(downloadURL: downloadURL)
            }
        }
    }
    
    func saveImageToDatabase(downloadURL: URL) {
        
        guard let wallpaperImage = selectedImage else { return }
        //        guard let wallpaperDesc = wallpaperDesc else { return }
        //        guard let wallpaperCat = wallpaperCat else { return }
        
        guard let uid = authRef.currentUser?.uid else { return }
        
        let ref = wallpaperDataRef.childByAutoId()
        
        // Dictionary of uploaded info saved to Database
        let values = ["downloadURL": downloadURL, "imageWidth": wallpaperImage.size.width, "imageHeight": wallpaperImage.size.height] as [String : Any]// add dictionary item for text/category
        
        ref.updateChildValues(values) { ( error, ref) in
            
            if let error = error {
                print("Failed to save wallpaper image to database:", error)
                return
            }
            
            print("Successfully saved wallpaper image to database")
            
        }
    }
    
    //    //        databaseReference.child("wallpapers").queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "sports").observe(.childAdded, with: { (snapshot) in
    //    //            var sportsCategory = [Wallpaper]()
    //    //            if let sportsCatSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
    //    //                for snapshot in sportsCatSnapshot {
    //    //                    let sportsCat = Wallpaper(snapshot: snapshot)
    //    //                    sportsCategory.append(sportsCat)
    //    //                }
    //    //            }
    //    //        })
    //    //    }
    //    //   MARK: Categories Function SwiftyJSON way, need to call firebase database
    //    // class func from(json: JSON) -> SportsCategory? {
    //    // var wallpaperCategory: String
    //    // if let unwrappedwallCatTitle = json["wallpaperCategory"].string {
    //    // wallpaperCategory = unwrappedwallCatTitle
    //    // } else {
    //    // wallpaperCategory = ""
    //    // }
    //    // let wallpaperDesc = json["wallpaperDesc"].string
    //    // let wallpaperURL = json["wallpaperURL"].string
    //    // return SportsCategory(wallpaperCategory: wallpaperCategory, wallpaperDesc: wallpaperDesc, wallpaperURL:  wallpaperURL)
    //    // }
    //    // }
    //
    
    // MARK: Firebase Category Functions
        func getMusicCategory() {
            self.musicCategory = [] //init it any time this func is called.
            let wallpapersRef = databaseRef.child("wallpapers")
            let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "music")
    
            queryRef.observe(.childAdded, with: { snapshot in
    
                if ( snapshot.value is NSNull ) {
                    print("no snapshot made from music node")
                } else {
    
                    for child in (snapshot.children) {
    
                        let snap = child as! DataSnapshot //each child is a snapshot
    
                        let musicDict = snap.value as! [String: String] // make art dict from art node in firebase ata
    
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
        func getArtCategory() {
            self.artCategory = [] //init it any time this func is called.
            let wallpapersRef = databaseRef.child("wallpapers")
            let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "art")
    
            queryRef.observe(.childAdded, with: { snapshot in
    
                if ( snapshot.value is NSNull ) {
                    print("no snapshot made from art node")
                } else {
    
                    for child in (snapshot.children) {
    
                        let snap = child as! DataSnapshot //each child is a snapshot
    
                        let artDict = snap.value as! [String: String] // make art dict from art node in firebase data
    
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

