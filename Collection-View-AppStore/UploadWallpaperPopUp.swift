//
//  UploadWallpaperPopUp.swift
//  Collection-View-AppStore
//
//  
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit

class UploadWallpaperPopUp: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var wallpaperPopUpView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var wallpaperDescTextView: UITextView!
    @IBOutlet weak var wallpaperCatLbl: UILabel!
    @IBOutlet weak var wallpaperCatTxtFld: UITextField! // eventually a picker?
    

    var wallpaperDescPlaceholderText = "Describe this wallpaper"
    var wallpaperCatPlaceholderText = "Give the wallpaper a category"
    
    let catPickerViewCategories = ["Sports", "Music", "Art"]
    
    //Upload Camera properties
    var imagePicker: UIImagePickerController!
    var takenImage: UIImage!
    
    // PickerView properties
    let catPickerView = UIPickerView()
    var rotationAngle: CGFloat!
    let width: CGFloat = 100
    let height: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Setup category PickerView
        catPickerView.delegate = self
        catPickerView.dataSource = self
        catPickerView.layer.borderColor = UIColor.darkGray.cgColor
        catPickerView.layer.borderWidth = 0.8
        rotationAngle = -90 * (.pi/180) // rotates picker horizontally
        catPickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        catPickerView.frame = CGRect(x: 0 - 150, y: 0, width: view.frame.width + 300, height: 100)
        catPickerView.center = self.view.center
        
        self.view.addSubview(catPickerView)
        
        wallpaperCatTxtFld.inputView = catPickerView // Assigns pickerView to catTextFld
        
        
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
    
    @IBAction func uploadBtnPressed(_ sender: UIButton) {
        if wallpaperDescTextView.text != "" && takenImage != nil  && wallpaperCatTxtFld.text != ""  {
            closeBtn.isHidden = false // upload only if all fields are filled out
            let newUploadWallpaper = Wallpaper(wallpaperImage: takenImage, wallpaperDesc: wallpaperDescTextView.text, wallpaperCategory: wallpaperCatTxtFld.text!)
            newUploadWallpaper.uploadWallpaper()
            self.dismiss(animated: true, completion: nil)
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
    
    // MARK: Cat PickerView Functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return catPickerViewCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = catPickerViewCategories[row]
        view.addSubview(label)
        view.transform = CGAffineTransform(rotationAngle: 90 * (.pi/180))
    
        return view
    }
    // Sets PickerView as TextFld after selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        wallpaperCatTxtFld.text = catPickerViewCategories[row]
        wallpaperCatTxtFld.resignFirstResponder()
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
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}







