//  UploadWallpaperPopUp.swift
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import McPicker
import Instructions

class UploadWallpaperPopUp: UIViewController {
    
    @IBOutlet weak var wallpaperPopUpView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var wallpaperDescTextView: UITextView!
    @IBOutlet weak var wallpaperCatLbl: UILabel!
    @IBOutlet weak var wallpaperCatTxtFld: McTextField!
    
    var wallpaperDescPlaceholderText = "Describe this wallpaper"
    var wallpaperCatPlaceholderText = "Give the wallpaper a category"

    //Upload Camera properties
    var imagePicker: UIImagePickerController!
    var takenImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Category McPicker
        let pickerData: [[String]] = [["Sports", "Music", "Art"]]
        let mcInputView = McPicker(data: pickerData)
        mcInputView.backgroundColor = .gray
        mcInputView.backgroundColorAlpha = 0.25
        wallpaperCatTxtFld.inputViewMcPicker = mcInputView
        
        wallpaperCatTxtFld.doneHandler = { [weak wallpaperCatTxtFld] (selections) in
            wallpaperCatTxtFld?.text = selections[0]!
        }
        wallpaperCatTxtFld.selectionChangedHandler = { [weak wallpaperCatTxtFld] (selections, componentThatChanged) in
            wallpaperCatTxtFld?.text = selections[componentThatChanged]!
        }
        wallpaperCatTxtFld.cancelHandler = { [weak wallpaperCatTxtFld] in
            self.wallpaperCatTxtFld?.text = "Cancelled."
        }
        wallpaperCatTxtFld.textFieldWillBeginEditingHandler = { [weak wallpaperCatTxtFld] (selections) in
            if wallpaperCatTxtFld?.text == "" {
                // Selections always default to the first value per component
                wallpaperCatTxtFld?.text = selections[0]
            }
        }
        
        McPicker.showAsPopover(data: pickerData, fromViewController: self) { [weak self] (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                self?.wallpaperCatLbl.text = name
            }
        }
        
        // Right now calling from Navigation controller needs to be called from UIView/UIViewController
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            
            if rootController is UINavigationController {
                if let navigationController = rootController as? UINavigationController {
                    if let topViewController = navigationController.topViewController {
                        topViewController.present(imagePicker, animated: true, completion: nil)
                    }
                }
            }
            else {
                // is a view controller
                rootController.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        closeBtn?.isHidden = true // hide close until user has filled out all fields to upload image
        wallpaperDescTextView?.textColor = .darkGray
        
        // MARK: Camera Setup
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    @IBAction func uploadBtnPressed(_ sender: UIButton) {
        if wallpaperDescTextView.text != "" && takenImage != nil  && wallpaperCatTxtFld.text != ""  {
            closeBtn.isHidden = false // upload only if all fields are filled out
//            let newUploadWallpaper = Wallpaper(wallpaperImage: takenImage, wallpaperDesc: wallpaperDescTextView.text, wallpaperCategory: wallpaperCatTxtFld.text!)
////            newUploadWallpaper.uploadWallpaper()
            FIRService.instance.uploadWallpaperToFirebase()
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: UploadWallpaperPopUp.updateFeedNotificationName, object: nil)
        }
    }
    
    @IBAction  func closeBtnPressed(_ sender: UIButton) {
        if wallpaperDescTextView.text != "" && wallpaperPopUpView.image != nil && wallpaperCatTxtFld.text != "" {
            self.closeBtn?.isHidden = false
            self.dismiss(animated: true, completion: nil)
            //            viewController.willMove(toParentViewController: nil)
            //            viewController.view.removeFromSuperview()
            //            viewController.removeFromParentViewController()
        }
    }
}

// MARK: TextView Delegate Functions
extension UploadWallpaperPopUp: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if wallpaperDescTextView.text == wallpaperDescPlaceholderText {
            wallpaperDescTextView.text = ""
            wallpaperDescTextView.textColor = .darkGray
        }
        
        wallpaperDescTextView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if wallpaperDescTextView.text == "" {
            wallpaperDescTextView.text = wallpaperDescPlaceholderText
            wallpaperDescTextView.textColor = .darkGray
        }
        
        wallpaperDescTextView.resignFirstResponder()
    }
}

extension UploadWallpaperPopUp: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.takenImage = image
        self.wallpaperPopUpView.image = self.takenImage
        takenImage = takenImage.resizeWithWidth(width: 700)! // Resize taken image
         let compressData = UIImageJPEGRepresentation(takenImage, 0.5) // Compress taken image
         let compressedImage = UIImage(data: compressData!)
        FIRService.instance.uploadWallpaperToFirebase()
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}