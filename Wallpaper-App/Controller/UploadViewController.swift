//  UploadWallpaperPopUp.swift
//  Copyright © 2017 C McGhee. All rights reserved.

import Foundation
import UIKit
import Photos
import Firebase
import CropViewController
import SwiftEntryKit
import Instructions
import SwiftyPickerPopover

class UploadViewController: UIViewController {
    
    @IBOutlet fileprivate var popUpView: CustomCardView!
    @IBOutlet fileprivate var wallpaperImgView: UIImageView!
    @IBOutlet fileprivate var closeBtn: UIButton!
    @IBOutlet fileprivate var uploadBtn: UIButton!
    @IBOutlet fileprivate var wallpaperDescTextView: UITextView!
    @IBOutlet fileprivate var wallpaperCatLbl: UILabel!
    @IBOutlet fileprivate var wallpaperCatPickBtn: UIButton!
    
    var wallpaperDescPlaceholderText = "Click here to describe the uploaded wallpaper"
    var wallpaperCatPlaceholderText = "Tap here to set category"
    
    //Upload Camera properties
    var takenImage: UIImage!
    var wallpaperURL: URL!
    
    // CropViewController
    private var croppingStyle = CropViewCroppingStyle.default
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    // Instructions
    let uploadInstructionsController = CoachMarksController()
    
    public var userTappedCloseButtonClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wallpaperDescTextView?.textColor = .darkGray
        wallpaperDescTextView.text = wallpaperDescPlaceholderText
        wallpaperCatPickBtn.setTitle(wallpaperCatPlaceholderText, for: .normal)
        
        makeShadowView()
        customBackBtn()
        wallpaperDescTextView.becomeFirstResponder()
        wallpaperImgView.image = UIImage(named: "clickhereupload")
        wallpaperImgView.layer.cornerRadius = 10
        
        // Instructions
        uploadInstructionsController.dataSource = self
        uploadInstructionsController.overlay.color = UIColor(red: 0.9765, green: 0.9765, blue: 0.9765, alpha: 1.0) // background color when instructions show #f9f9f9        uploadInstructionsController.overlay.allowTap = true
        
        // MARK: - Check User First Time Viewing VC (Instructions)
        let launchedBefore = Defaults.bool(forKey: "alreadylaunched")
        if launchedBefore {
            Defaults.setInstructions(value: false)
        } else {
            Defaults.setInstructions(value: true)
            self.uploadInstructionsController.start(in: .window(over: self))
            Defaults.set(true, forKey: "alreadylaunched")
        }
        
        // Wallpaper Image Tap Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(wallpaperImgUploadClicked))
        wallpaperImgView.addGestureRecognizer(tap)
        wallpaperImgView.isUserInteractionEnabled = true
        
        // CropViewController
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePhoto))
        
    }
    
    // MARK: - Present Camera
    fileprivate func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            // cameraPicker.allowEditing = true // allow cropping of photo before upload
            self.present(cameraPicker, animated: true)
        }
    }
    
    // MARK: - Present Photo Library
    fileprivate func presentPhotoPicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoPicker = UIImagePickerController()
            photoPicker.delegate = self
            photoPicker.sourceType = .photoLibrary
            // photoPicker.allowsEditing = true
            self.present(photoPicker, animated: true)
        }
    }
    
    // Custom Photo Library Options Alert
    private func showEKDeniedAlert(attributes: EKAttributes) {
        let titleText = EKProperty.LabelContent(text: "Photo Library Authorization Denied", style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: .darkGray))
        let descText = EKProperty.LabelContent(text: "You declined authorization of access to your photos, please allow access to upload wallpapers", style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: .darkGray))
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        
        let closeText = "Close"
        let okayText = "Okay"
        let simpleMessage = EKSimpleMessage(image: image, title: titleText, description: descText)
        
        let okayButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: .darkGray)
        let okayButtonLabel = EKProperty.LabelContent(text: okayText, style: okayButtonLabelStyle)
        let okayButton = EKProperty.ButtonContent(label: okayButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: .lightGray) {
            DispatchQueue.main.async {
                let url = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(url!, options: [:])
            }
        }
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: .darkGray)
        let closeButtonLabel = EKProperty.LabelContent(text: closeText, style: closeButtonLabelStyle)
        let closeButton = EKProperty.ButtonContent(label: closeButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: .lightGray) {
            SwiftEntryKit.dismiss()
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okayButton, closeButton, separatorColor: .darkGray, expandAnimatedly: true)
        
        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        
        let contentView = EKAlertMessageView(with: alertMessage)
        
        SwiftEntryKit.display(entry: contentView, using: self.attributesWrapper.attributes)
    }
    
    // Custom Photo Library Access Alert
    private func showEKRestrictAlert(attributes: EKAttributes) {
        let titleText = EKProperty.LabelContent(text: "Restricted Access for Photo Library", style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: .darkGray))
        let descText = EKProperty.LabelContent(text: "Your restrictions in settings have denied access to the photo library", style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: .darkGray))
        
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        
        let closeText = "Close"
        let okayText = "Okay"
        let simpleMessage = EKSimpleMessage(image: image, title: titleText, description: descText)
        
        let okayButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: .darkGray)
        let okayButtonLabel = EKProperty.LabelContent(text: okayText, style: okayButtonLabelStyle)
        let okayButton = EKProperty.ButtonContent(label: okayButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: .lightGray) {
            // Take User to Settings Button Action
            DispatchQueue.main.async {
                let url = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(url!, options: [:])
            }
        }
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: .darkGray)
        let closeButtonLabel = EKProperty.LabelContent(text: closeText, style: closeButtonLabelStyle)
        let closeButton = EKProperty.ButtonContent(label: closeButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: .lightGray) {
            SwiftEntryKit.dismiss()
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okayButton, closeButton, separatorColor: .darkGray, expandAnimatedly: true)
        
        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        
        let contentView = EKAlertMessageView(with: alertMessage)
        
        SwiftEntryKit.display(entry: contentView, using: self.attributesWrapper.attributes)
    }
    
    // Custom Photo Library Undetermined Access Alert
    private func showEKNotDetAlert(attributes: EKAttributes) {
        let titleText = EKProperty.LabelContent(text: "Undetermined Access", style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: .darkGray))
        let descText = EKProperty.LabelContent(text: "Access to your photo library is undetermined, go to settings and allow photo library access to upload/save wallpapers", style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: .darkGray))
        
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        
        let closeText = "Close"
        let okayText = "Okay"
        let simpleMessage = EKSimpleMessage(image: image, title: titleText, description: descText)
        
        let okayButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: .darkGray)
        let okayButtonLabel = EKProperty.LabelContent(text: okayText, style: okayButtonLabelStyle)
        let okayButton = EKProperty.ButtonContent(label: okayButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: .lightGray) {
            DispatchQueue.main.async {
                let url = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(url!, options: [:])
            }
        }
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: .darkGray)
        let closeButtonLabel = EKProperty.LabelContent(text: closeText, style: closeButtonLabelStyle)
        let closeButton = EKProperty.ButtonContent(label: closeButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: .lightGray) {
            SwiftEntryKit.dismiss()
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okayButton, closeButton, separatorColor: .darkGray, expandAnimatedly: true)
        
        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        
        let contentView = EKAlertMessageView(with: alertMessage)
        
        SwiftEntryKit.display(entry: contentView, using: self.attributesWrapper.attributes)
    }
    
    // Custom Upload Types Alert
    private func showUploadTypesPopUp(attributes: EKAttributes) {
        let titleText = EKProperty.LabelContent(text: "Upload a Photo from Your Library or Take a Photo in Camera", style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: .darkGray))
        let descText = EKProperty.LabelContent(text: "Click on the way you want to upload a wallpaper", style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: .darkGray))
        let image = EKProperty.ImageContent(image: UIImage(named: "download")!, size: CGSize(width: 35, height: 35))
        let camBtnText = "Camera"
        let libraryBtnText = "Photo Library"
        let simpleMessage = EKSimpleMessage(image: image, title: titleText, description: descText)
        
        let camButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: .darkGray)
        let camButtonLabel = EKProperty.LabelContent(text: camBtnText, style: camButtonLabelStyle)
        let camButton = EKProperty.ButtonContent(label: camButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: .lightGray) {
            self.requestCameraAccess()
        }
        
        let libraryButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: .darkGray)
        let libraryButtonLabel = EKProperty.LabelContent(text: libraryBtnText, style: libraryButtonLabelStyle)
        let libraryButton = EKProperty.ButtonContent(label: libraryButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: .lightGray) {
            self.requestPhotoLibraryAccess()
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(with: camButton, libraryButton, separatorColor: .darkGray, expandAnimatedly: true)
        
        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        
        let contentView = EKAlertMessageView(with: alertMessage)
        
        SwiftEntryKit.display(entry: contentView, using: self.attributesWrapper.attributes)
    }
    
    // MARK: - Individual Alerts
    func noAccessToCameraAlert() {
        let titleCamText = "No Access To Camera"
        let descCamText = "Please allow camera access, so the app can access your camera to upload a picture as a wallpaper"
        self.showNotificationEKMessage(attributes: attributesWrapper.attributes, title: titleCamText, desc: descCamText, textColor: .darkGray)
    }
    
    func uploadSuccessfulAlert() {
        let titleUpText = "Upload Successful"
        let descUpText = "Your wallpaper image has been uploaded successfully"
        self.showBannerNotificationMessage(attributes: attributesWrapper.attributes, text: titleUpText, desc: descUpText, textColor: .darkGray)
    }
    
    func uploadErrorAlert() {
        let titleText = "Error in Upload"
        let descText = "Something went wrong in the upload. Please try again"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: titleText, desc: descText, textColor: .darkGray)
    }
    
    func noAllItemsError() {
        let titleText = "Error With Fields"
        let descText = "Please fill out all fields, then continue"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: titleText, desc: descText, textColor: .darkGray)
    }
    
    func makeShadowView() {
        wallpaperDescTextView.layer.cornerRadius = 10
        wallpaperDescTextView.layer.shadowOpacity = 0.2
        wallpaperDescTextView.layer.shadowColor = UIColor.black.cgColor
        wallpaperDescTextView.layer.shadowRadius = 2 // HALF of blur
        wallpaperDescTextView.layer.shadowOffset = CGSize(width: 0, height: 2) // Spread x, y
        wallpaperDescTextView.layer.masksToBounds =  false
    }
    
    // MARK: - Keyboard Dismiss
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Category Picker Button Action
    @IBAction func categoryPicker(_ sender: UIButton) {
        // Picker background (same as view background)
        self.view.backgroundColor = UIColor.white
        let catPicker = StringPickerPopover(title: "", choices: ["Sports","Music","Art"])
            // .setImageNames(["imageIcon",nil,"thumbUpIcon"]) // set images from assets
            .setSize(width: 200, height: 150)
            .setCornerRadius(10)
            .setValueChange(action: { _, _, selectedString in
                self.wallpaperCatPickBtn.setTitle(selectedString, for: .normal) // updates selection with catName
                print("current string: \(selectedString)")
            })
            .setDoneButton(
                title: "Select",
                font: UIFont.gillsRegFont(ofSize: 17),
                color: UIColor.red,
                action: {
                    popover, selectedRow, selectedString in
                    print("done row \(selectedRow) \(selectedString)")
            })
            .setCancelButton(
                title: "Cancel",
                font: UIFont.gillsRegFont(ofSize: 17),
                color: UIColor.blue,
                action: {_, _, _ in
                    self.wallpaperCatPickBtn.setTitle(self.wallpaperCatPlaceholderText, for: .normal) // placeholder when cleared
                    print("cancelled")
            })
            .setOutsideTapDismissing(allowed: true)
            .setDimmedBackgroundView(enabled: true)
        catPicker.appear(originView: sender, baseViewController: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.uploadInstructionsController.stop(immediately: true)
    }
    
    // MARK: - Camera Access
    func requestCameraAccess() {
        // MARK: - Ask User Permission to Access Camera
        AVCaptureDevice.requestAccess(for: .video) { response in
            if response {
                self.presentCamera()
            } else {
                self.noAccessToCameraAlert()
                // handle other errors
            }
        }
    }
    
    // MARK: - Photo Library Access
    func requestPhotoLibraryAccess() {
        // MARK: - Ask User Permission to Access Photo Library before Upload Wallpapers
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    // If User authorizes, present photopicker
                    self.presentPhotoPicker()
                case .notDetermined:
                    if status == PHAuthorizationStatus.authorized {
                        self.presentPhotoPicker()
                    } else {
                        // Not Determined and not authorized
                        self.showEKNotDetAlert(attributes: self.attributesWrapper.attributes)
                    }
                case .restricted:
                    // Restricted Access in Settings
                    self.showEKRestrictAlert(attributes: self.attributesWrapper.attributes)
                case .denied:
                    // User declined authorization
                    // MARK: - No Authorization Alert
                    self.showEKDeniedAlert(attributes: self.attributesWrapper.attributes)
                }
            }
        }
    }
    
    
    // MARK: - Wallpaper Image Tap Gesture Function
    @objc func wallpaperImgUploadClicked() {
        // Option Camera/Photo Library
        self.showUploadTypesPopUp(attributes: self.attributesWrapper.attributes)
    }
    
    // MARK: - Upload Wallpaper Button Action
    @IBAction func uploadBtnPressed(_ sender: UIButton) {
        if wallpaperDescTextView.text != nil && wallpaperDescTextView.text != wallpaperDescPlaceholderText && wallpaperImgView.image != UIImage(named: "clickhereupload") && wallpaperImgView.image != nil && wallpaperCatPickBtn.currentTitle != nil && wallpaperCatPickBtn.currentTitle != wallpaperCatPlaceholderText {
            self.loading(.start)
            // MARK: - Upload Successful Alert
            FIRService.saveWalltoFirebase(image: takenImage, wallpaperURL: wallpaperURL, wallpaperDesc: wallpaperDescTextView.text, wallpaperCategory: wallpaperCatPickBtn.currentTitle?.lowercased()) { (error) in
                if error != nil { // upload error
                    self.uploadErrorAlert()
                    print(error?.localizedDescription ?? "")
                    return
                } else { // upload successful
                    Analytics.logEvent("user_uploaded_wallpaper", parameters: nil)
                    self.uploadSuccessfulAlert()
                    self.loading(.stop)
                    self.dismiss(animated: true)
                }
            }
        } else {
            noAllItemsError()
            // handle other errors/not all items
        }
    }
    
    // MARK: - Close Button Pressed Action
    @IBAction  func closeBtnPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: TextView Delegate Functions Ext
extension UploadViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.closeBtn.isHidden = true // hide button when user first starts typing
        
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

// MARK: - Picker Ext
extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let wallpaperImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage, let optimizedImageData = wallpaperImage.pngData() {
        
            let cropController = CropViewController(croppingStyle: croppingStyle, image: wallpaperImage)
            cropController.delegate = self
            print(optimizedImageData)
           
            if croppingStyle == .circular {
                if picker.sourceType == .camera {
                    picker.dismiss(animated: true, completion: {
                        self.present(cropController, animated: true, completion: nil)
                    })
                } else {
                    picker.pushViewController(cropController, animated: true)
                }
            }
            else { //otherwise dismiss, and then present from the main controller
                picker.dismiss(animated: true, completion: {
                    self.present(cropController, animated: true, completion: nil)
                })
            }
            
            self.takenImage = wallpaperImage
            self.wallpaperImgView.image = wallpaperImage // set wallpaper image view as selected image
        }
        //        else if let editedWallpaperImage = info[UIImagePickerControllerEditedImage] as? UIImage, let editedOptimizedImageData = UIImagePNGRepresentation(editedWallpaperImage) {
        //            print(editedOptimizedImageData)
        //            self.takenImage = editedWallpaperImage
        //            self.wallpaperImgView.image = editedWallpaperImage
        //
        //        }
        
        if let imageUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.referenceURL)] as? URL {
            self.wallpaperURL = imageUrl
            // print(wallpaperURL)
        }
        dismiss(animated: true)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // track number of times user has uploaded photos, then request a review after so many times StoreReviewHelper().requestReview()
        dismiss(animated: true)
    }
}

// MARK: - Instructions Ext
extension UploadViewController: CoachMarksControllerDelegate, CoachMarksControllerDataSource {
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let uploadIntView = uploadInstructionsController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        switch (index) {
        case 0:
            uploadIntView.bodyView.hintLabel.text = "Write information about Wallpaper here"
            uploadIntView.bodyView.nextLabel.text = "Got it!"
        case 1:
            uploadIntView.bodyView.hintLabel.text = "Upload Wallpaper to the database here"
            uploadIntView.bodyView.nextLabel.text = "Got it!"
        default: break
        }
        return (bodyView: uploadIntView.bodyView, arrowView: uploadIntView.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        // Set Instruction markers around UI Elements
        switch (index) {
        case 0:
            return uploadInstructionsController.helper.makeCoachMark(for: wallpaperDescTextView)
        case 1:
            return uploadInstructionsController.helper.makeCoachMark(for: uploadBtn)
        default:
            return uploadInstructionsController.helper.makeCoachMark()
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
}

// MARK: - CropViewController Ext
extension UploadViewController: CropViewControllerDelegate {
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        wallpaperImgView.image = image
        
        if cropViewController.croppingStyle != .circular {
            wallpaperImgView.isHidden = true
            
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: wallpaperImgView,
                                                   toFrame: CGRect.zero,
                                                   setup: { self.layoutImageView() },
                                                   completion: { self.wallpaperImgView.isHidden = false })
        }
        else {
            self.wallpaperImgView.isHidden = false
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    public func layoutImageView() {
        guard wallpaperImgView.image != nil else { return }
        
        let padding: CGFloat = 20.0
        
        var viewFrame = self.view.bounds
        viewFrame.size.width -= (padding * 2.0)
        viewFrame.size.height -= ((padding * 2.0))
        
        var imageFrame = CGRect.zero
        imageFrame.size = wallpaperImgView.image!.size;
        
        if wallpaperImgView.image!.size.width > viewFrame.size.width || wallpaperImgView.image!.size.height > viewFrame.size.height {
            let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
            imageFrame.size.width *= scale
            imageFrame.size.height *= scale
            imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
            imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
            wallpaperImgView.frame = imageFrame
        }
        else {
            self.wallpaperImgView.frame = imageFrame
            self.wallpaperImgView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        }
    }
    
    @objc public func sharePhoto() {
        guard let image = wallpaperImgView.image else {
            return
        }
        print(image)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
