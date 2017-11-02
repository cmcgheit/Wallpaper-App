//
//  UploadWallpaperPopUp.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 10/31/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit

class UploadWallpaperPopUp: UIViewController {
    
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var closePopupBtn: UIImageView!
    
    var descTextViewPlaceHolderText = "Enter a description for the image here"
    
    // MARK: - Camera properties
    var imagePicker: UIImagePickerController!
    var uploadedWallpaper: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadImageView.layer.cornerRadius = 14.0
        descTextView.text = descTextViewPlaceHolderText
        descTextView.textColor = .lightGray
        descTextView.delegate = self
        
        closePopupBtn.isHidden = true
        
        imagePicker = UIImagePickerController()
        // let imagePicker = storyboard.instantiateViewControllerWithIdentifier("imagePicker") as! imagePickerControllerViewController
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraUploadPressed() {
        if descTextView.text != "" && descTextView.text != descTextViewPlaceHolderText && uploadImageView != nil {
            let newUploadWallpaper = Wallpaper(wallpaperImage: uploadImageView.image!, wallpaperDesc: descTextView.text)
            newUploadWallpaper.uploadWallpaper()
            // segue to popup
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func doneUploading() {
        // First hide button, then appear, once user has filled out form
        self.dismiss(animated: true, completion: nil)
    }
}

extension UploadWallpaperPopUp: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descTextView.text == descTextViewPlaceHolderText {
            descTextView.text = ""
            descTextView.textColor = .lightGray
        }
        descTextView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descTextView.text == "" {
            descTextView.text = descTextViewPlaceHolderText
            descTextView.textColor = .lightGray
        }
        descTextView.resignFirstResponder()
    }
}

extension UploadWallpaperPopUp: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.uploadedWallpaper = image
        self.uploadImageView.image = self.uploadedWallpaper
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

