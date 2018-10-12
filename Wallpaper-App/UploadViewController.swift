//  UploadWallpaperPopUp.swift
//  Copyright © 2017 C McGhee. All rights reserved.

import Foundation
import UIKit
import Photos
import Firebase
import SwiftEntryKit
import Instructions
import McPicker

class UploadViewController: UIViewController {
    
    @IBOutlet weak var popUpView: CustomCardView!
    @IBOutlet weak var wallpaperImgView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var wallpaperDescTextView: UITextView!
    @IBOutlet weak var wallpaperCatLbl: UILabel!
    @IBOutlet weak var wallpaperCatPickBtn: UIButton!
    
    var wallpaperDescPlaceholderText = "Click here to describe the uploaded wallpaper"
    var wallpaperCatPlaceholderText = "Tap here to set category"
    
    //Upload Camera properties
    var imagePicker: UIImagePickerController!
    var takenImage: UIImage!
    
    // Instructions
    let uploadInstructionsController = CoachMarksController()
    
    // Picker
    let catPickerData: [[String]] = [["Sports", "Music", "Arts"]]
    
    public var userTappedCloseButtonClosure: (() -> Void)?
    
    // MARK: - Attributes Wrapper
    private var attributesWrapper: EntryAttributeWrapper {
        var attributes = EKAttributes.topFloat
        attributes.entryBackground = .color(color: UIColor.white)
        attributes.roundCorners = .all(radius: 10)
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        return EntryAttributeWrapper(with: attributes)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wallpaperDescTextView?.textColor = .darkGray
        wallpaperDescTextView.text = wallpaperDescPlaceholderText
        wallpaperCatPickBtn.setTitle(wallpaperCatPlaceholderText, for: .normal)
        
        makeShadowView()
        wallpaperDescTextView.becomeFirstResponder()
        wallpaperImgView.image = UIImage(named: "cliphereupload")
        
        // Instructions
        uploadInstructionsController.dataSource = self
        self.uploadInstructionsController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
        self.uploadInstructionsController.overlay.allowTap = true
        
        customBackBtn()
        
    }
    
    // MARK: - Media SourceTypes
    fileprivate func sourceTypePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Present Camera
    fileprivate func presentCamera() {
        let camera = UIImagePickerController()
        camera.delegate = self
        camera.sourceType = .camera
        self.present(camera, animated: true)
    }
    
    // MARK: - Present Photo Library Picker
    fileprivate func presentPhotoPicker() {
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        self.present(photoPicker, animated: true)
    }
    
    // MARK: - SwiftEntryKit Alerts
    // Notification Message
    private func showNotificationEKMessage(attributes: EKAttributes, title: String, desc: String, textColor: UIColor, imageName: String? = nil) {
        let title = EKProperty.LabelContent(text: title, style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: UIColor.darkGray))
        let desc = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: UIColor.darkGray))
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: desc)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributesWrapper.attributes)
        
    }
    // Denied Alert
    private func showEKDeniedAlert(attributes: EKAttributes) {
        let titleText = EKProperty.LabelContent(text: "Photo Library Authorization Denied", style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: UIColor.darkGray))
        let descText = EKProperty.LabelContent(text: "You declined authorization of access to your photos, please allow access to upload wallpapers", style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: UIColor.darkGray))
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        
        let closeText = "Close"
        let okayText = "Okay"
        let simpleMessage = EKSimpleMessage(image: image, title: titleText, description: descText)
        
        let okayButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: tealColor)
        let okayButtonLabel = EKProperty.LabelContent(text: okayText, style: okayButtonLabelStyle)
        let okayButton = EKProperty.ButtonContent(label: okayButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: redColor) {
            DispatchQueue.main.async {
                let url = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.open(url!, options: [:])
            }
        }
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: tealColor)
        let closeButtonLabel = EKProperty.LabelContent(text: closeText, style: closeButtonLabelStyle)
        let closeButton = EKProperty.ButtonContent(label: closeButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: redColor) {
            SwiftEntryKit.dismiss()
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okayButton, closeButton, separatorColor: tealColor, expandAnimatedly: true)
        
        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        
        let contentView = EKAlertMessageView(with: alertMessage)
        
        SwiftEntryKit.display(entry: contentView, using: self.attributesWrapper.attributes)
    }
    
    // Restrict Access Alert
    private func showEKRestrictAlert(attributes: EKAttributes) {
        let titleText = EKProperty.LabelContent(text: "Restricted Access for Photo Library", style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: UIColor.darkGray))
        let descText = EKProperty.LabelContent(text: "Your restrictions in settings have denied access to the photo library", style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: UIColor.darkGray))
        
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        
        let closeText = "Close"
        let okayText = "Okay"
        let simpleMessage = EKSimpleMessage(image: image, title: titleText, description: descText)
        
        let okayButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: tealColor)
        let okayButtonLabel = EKProperty.LabelContent(text: okayText, style: okayButtonLabelStyle)
        let okayButton = EKProperty.ButtonContent(label: okayButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: redColor) {
            // Take User to Settings Button Action
            DispatchQueue.main.async {
                let url = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.open(url!, options: [:])
            }
        }
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: tealColor)
        let closeButtonLabel = EKProperty.LabelContent(text: closeText, style: closeButtonLabelStyle)
        let closeButton = EKProperty.ButtonContent(label: closeButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: redColor) {
            SwiftEntryKit.dismiss()
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okayButton, closeButton, separatorColor: tealColor, expandAnimatedly: true)
        
        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        
        let contentView = EKAlertMessageView(with: alertMessage)
        
        SwiftEntryKit.display(entry: contentView, using: self.attributesWrapper.attributes)
    }
    
    // No Determined Status Alert
    private func showEKNotDetAlert(attributes: EKAttributes) {
        let titleText = EKProperty.LabelContent(text: "Undetermined Access", style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: UIColor.darkGray))
        let descText = EKProperty.LabelContent(text: "Access to your photo library is undetermined, go to settings and allow photo library access to upload/save wallpapers", style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: UIColor.darkGray))
        
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        
        let closeText = "Close"
        let okayText = "Okay"
        let simpleMessage = EKSimpleMessage(image: image, title: titleText, description: descText)
        
        let okayButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: tealColor)
        let okayButtonLabel = EKProperty.LabelContent(text: okayText, style: okayButtonLabelStyle)
        let okayButton = EKProperty.ButtonContent(label: okayButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: redColor) {
            DispatchQueue.main.async {
                let url = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.open(url!, options: [:])
            }
        }
        
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: tealColor)
        let closeButtonLabel = EKProperty.LabelContent(text: closeText, style: closeButtonLabelStyle)
        let closeButton = EKProperty.ButtonContent(label: closeButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: redColor) {
            SwiftEntryKit.dismiss()
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(with: okayButton, closeButton, separatorColor: tealColor, expandAnimatedly: true)
        
        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        
        let contentView = EKAlertMessageView(with: alertMessage)
        
        SwiftEntryKit.display(entry: contentView, using: self.attributesWrapper.attributes)
    }
    
    // Upload Types Alert
    private func showUploadTypesAlert(attributes: EKAttributes) {
        let titleText = EKProperty.LabelContent(text: "Upload a Photo from Your Library or Take a Photo in Camera", style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: UIColor.darkGray))
        let descText = EKProperty.LabelContent(text: "Click on the way you want to upload a wallpaper", style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: UIColor.darkGray))
        
        let image = EKProperty.ImageContent(image: UIImage(named: "uploadbuttonon")!, size: CGSize(width: 35, height: 35))
        
        let camBtnText = "Camera"
        let libraryBtnText = "Photo Library"
        let simpleMessage = EKSimpleMessage(image: image, title: titleText, description: descText)
        
        let camButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: tealColor)
        let camButtonLabel = EKProperty.LabelContent(text: camBtnText, style: camButtonLabelStyle)
        let camButton = EKProperty.ButtonContent(label: camButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: redColor) {
            self.requestCameraAccess()
        }
        
        let libraryButtonLabelStyle = EKProperty.LabelStyle(font: UIFont.gillsRegFont(ofSize: 20), color: tealColor)
        let libraryButtonLabel = EKProperty.LabelContent(text: libraryBtnText, style: libraryButtonLabelStyle)
        let libraryButton = EKProperty.ButtonContent(label: libraryButtonLabel, backgroundColor: .clear, highlightedBackgroundColor: redColor) {
            self.requestPhotoLibraryAccess()
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(with: camButton, libraryButton, separatorColor: tealColor, expandAnimatedly: true)
        
        let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
        
        let contentView = EKAlertMessageView(with: alertMessage)
        
        SwiftEntryKit.display(entry: contentView, using: self.attributesWrapper.attributes)
    }
    
    func noAccessToCameraAlert() {
        let titleCamText = "No Access To Camera"
        let descCamText = "Please allow camera access, so the app can access your camera to upload a picture as a wallpaper"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: titleCamText, desc: descCamText, textColor: UIColor.darkGray)
    }
    
    func uploadSuccessfulAlert() {
        let titleUpText = "Upload Successful"
        let descUpText = "Your wallpaper image has been uploaded successfully"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: titleUpText, desc: descUpText, textColor: UIColor.darkGray)
    }
    
    func uploadErrorAlert() {
        let titleText = "Error in Upload"
        let descText = "Something went wrong in the upload. Please try again"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: titleText, desc: descText, textColor: UIColor.darkGray)
    }
    
    func noAllItemsError() {
        let titleText = "Error With Fields"
        let descText = "Please fill out all fields, then continue"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: titleText, desc: descText, textColor: UIColor.darkGray)
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
    
    // MARK: - Notification Observers
    func notificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(firstTimeUploadVC), name: Notification.Name.firstTimeViewController, object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(firstTimeUploadVC())
    }
    
    // MARK: - Check User First Time User Viewing VC (Instructions)
    @objc func firstTimeUploadVC() {
        if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
            // User signed-In
            Defaults.setInstructions(value: false)
        } else {
            NotificationCenter.default.post(name: .firstTimeViewController, object: nil)
            Defaults.setInstructions(value: true)
            self.uploadInstructionsController.start(on: self)
        }
    }
    
    // MARK: - Category Picker Button Action
    @IBAction func categoryPicker(_ sender: UIButton) {
        McPicker.showAsPopover(data: catPickerData, fromViewController: self, sourceView: sender, doneHandler: { [weak self] (selections: [Int : String]) -> Void in
            if let catName = selections[0] {
                self?.wallpaperCatPickBtn.setTitle(catName, for: .normal) // updates selection with catName
            }
            }, cancelHandler: { () -> Void in
                print("Canceled Popover")
        }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
            let newSelection = selections[componentThatChanged] ?? "Failed to get new selection!"
            print("Component \(componentThatChanged) changed value to \(newSelection)")
        })
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
                    self.presentPhotoPicker()
                    // If User authorizes, allow upload
                    if self.wallpaperDescTextView.text.isEmpty && self.takenImage != nil {
                        self.closeBtn.isHidden = false // upload only if all fields are filled out
                        //            FIRService.uploadWallToFirebaseStor(image: takenImage) { (, error) in
                        //
                        //            }
                        NotificationCenter.default.post(name: Notification.Name.updateFeedNotificationName, object: nil)
                        // MARK: - Upload Successful Alert
                        self.uploadSuccessfulAlert()
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        // Error in Upload
                        // MARK: - Upload Error Alert
                        self.uploadErrorAlert()
                        self.dismiss(animated: true, completion: nil)
                    }
                case .notDetermined:
                    if status == PHAuthorizationStatus.authorized {
                        self.presentPhotoPicker()
                    } else {
                        // Not Determined and not authorized
                        self.showEKNotDetAlert(attributes: self.attributesWrapper.attributes)
                        self.dismiss(animated: true)
                    }
                case .restricted:
                    // Restricted Access in Settings
                    self.showEKRestrictAlert(attributes: self.attributesWrapper.attributes)
                    self.dismiss(animated: true, completion: nil)
                case .denied:
                    // User declined authorization
                    // MARK: - No Authorization Alert
                    self.showEKDeniedAlert(attributes: self.attributesWrapper.attributes)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    // MARK: - Wallpaper Image Button Action
    @IBAction func wallpaperImgUploadClicked() {
        // Option Camera/Photo Library
        showUploadTypesAlert(attributes: self.attributesWrapper.attributes)
    }
    
    // MARK: - Upload Wallpaper Button Action
    @IBAction func uploadBtnPressed(_ sender: UIButton) {
        // check all fields filled out
        // upload wallpaper to database
    }
    
    // MARK: - Close Button Pressed Action
    @IBAction  func closeBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: TextView Delegate Functions
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

extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // MARK: - Upload Wallpapers to Firebase
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.takenImage = image
        self.wallpaperImgView.image = self.takenImage
        takenImage = takenImage.resizeWithWidth(width: 700)! // Resize taken image
        let compressData = UIImageJPEGRepresentation(takenImage, 0.5) // Compress taken image
        let compressedImage = UIImage(data: compressData!)
        _ = storageRef.putData(compressData!, metadata: nil) { (metadata, error) in
            // let size = metadata?.size
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            guard metadata != nil else {
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
                return
            }
            // access to download URL after upload.
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    }
                    return
                }
                FIRService.saveWalltoFirebase(image: compressedImage!, wallpaperURL: downloadURL, wallpaperDesc: self.wallpaperDescTextView.text, wallpaperCategory: self.wallpaperCatLbl.text) { (error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                        return
                    }
                }
            }
        }
        self.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}

// MARK: - Instructions Functions
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
