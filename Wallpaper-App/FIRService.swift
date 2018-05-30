//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import UIKit
import Firebase

var selectedImage: UIImage?

class FIRService {
    
    let storageRef = Storage.storage().reference()
    let databaseRef = Database.database().reference()
    let authRef = Auth.auth()
    
    let wallpaperDataRef = Database.database().reference().child("wallpapers")
    let wallpaperUserRef = Database.database().reference().child("users")
    let artCatRef = Storage.storage().reference().child("art")
    let musicCatRef = Storage.storage().reference().child("music")
    let sportsCatRef = Storage.storage().reference().child("sports")
    
    private static let _instance = FIRService()
    
    static var instance: FIRService {
        return _instance
    }
    
    // MARK: - Fetching Posts for User uid (when have specific user wallpapers feed)
    static func fetchUserForUID(uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference().child("uid").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }) { (error) in
            print("Failed to fetch user specific posts:", error)
        }
    }
    
    // MARK: - Download Wallpapers FROM Firebase Database
    
    func downloadImagesFromFirebaseData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let wallpaperDataDownloadRef = Database.database().reference().child("wallpapers").child(uid)
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
        Storage.storage().reference().child("images").child(filename).putData(uploadData, metadata: nil) { (metadata, error) in
            
            if let error = error {
                print("Failed to upload wallpaper image", error)
                return
            }
            
            guard let metadata = metadata else {
                // error
                return
            }
            
            self.storageRef.downloadURL { (url, error ) in
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
    
    //         MARK: - Downloading Images from Firebase storage
    //                let imageName = NSUUID().uuidString
    //                let imageRef = storageReference.child("images").child("sports").child("chicago-full.png") //\(imageName)
    //                imageRef.getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
    //                    if error != nil {
    //                        let image = UIImage(named: "placeholder-image")
    //                        cell.imageView?.kf.setImage(with: data as? Resource, placeholder: image)
    //                    }
    //                })
    
    //        // MARK: - Function to save images user uploads to Firebase storage
    // OR TWEAK UPLOADWALLPAPER FUNCTION??
    //        let uniqueString = NSUUID().uuidString
    //        if let userUploadedImage = takenImage { // have to do case by category, currently just goes to wallpaper general folder in firebase storage
    //            let storageRef = storageReference.child("wallpapers").child("\(uniqueString).png")
    //            if let uploadData = UIImagePNGRepresentation(userUploadedImage) {
    //                storageRef.put(uploadData, metadata: nil, completion: { (data, error) in
    //                    if error != nil {
    //                        print("Error: \(error!.localizedDescription)")
    //                        return
    //                    }
    //                    if let uploadImageUrl = data?.wallpaperURL()?.absoluteString {
    //                        print("Photo Url: \(uploadImageUrl)")
    //        let databaseRef = FIRDatabase.database().reference().child("wallpapers").child("wallpaperCategory")child(uniqueString) // put in appropiate category
    //        databaseRef.setValue(uploadImageUrl, withCompletionBlock: { (error, dataRef) in
    //            if error != nil {
    //                print("Database Error: \(error!.localizedDescription)")
    //            }
    //            else {
    //                print("Image successfully saved to Firebase Database")
    //            }
    //        })
    //    }
    //})
    //}
    //}
}

