//  UploadWallpaperPopUp.swift
//  Copyright © 2017 C McGhee. All rights reserved.

import Foundation
import UIKit
import Firebase
import SwiftEntryKit
import Instructions
import McPicker

class UploadWallpaperPopUp: UIViewController {
    
    @IBOutlet weak var wallpaperPopUpView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var wallpaperDescTextView: UITextView!
    @IBOutlet weak var wallpaperCatLbl: UILabel!
    @IBOutlet weak var wallpaperCatPickLbl: UILabel!
    
    var wallpaperDescPlaceholderText = "Describe this wallpaper"
    var wallpaperCatPlaceholderText = "Give the wallpaper a category"
    
    //Upload Camera properties
    var imagePicker: UIImagePickerController!
    var takenImage: UIImage!
    
    // Instructions
    let uploadInstructionsController = CoachMarksController()
    
    // Picker
    let catPickerData: [[String]] = [["Sports", "Music", "Arts"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instructions
        self.uploadInstructionsController.dataSource = self
        self.uploadInstructionsController.overlay.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
        self.uploadInstructionsController.overlay.allowTap = true
        
        closeBtn?.isHidden = true // hide close until user has filled out all fields to upload image
        wallpaperDescTextView?.textColor = .darkGray
        
        customBackBtn()
        
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
        
        // Assign image from View Controller/Navigation Controller
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            
            if rootController is UINavigationController {
                if let navigationController = rootController as? UINavigationController {
                    if let topViewController = navigationController.topViewController {
                        topViewController.present(imagePicker, animated: true, completion: nil)
                    }
                }
            } else {
                // is a view controller
                rootController.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // MARK: - Set navigation bar to transparent
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    // MARK: - Category Picker Button Action
    @IBAction func categoryPicker(_ sender: UIButton) {
        McPicker.showAsPopover(data: catPickerData, fromViewController: self, sourceView: sender, doneHandler: { [weak self] (selections: [Int : String]) -> Void in
            if let catName = selections[0] {
                self?.wallpaperCatPickLbl.text = catName // updates selection with catName
            }
            }, cancelHandler: { () -> Void in
                print("Canceled Popover")
        }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
            let newSelection = selections[componentThatChanged] ?? "Failed to get new selection!"
            print("Component \(componentThatChanged) changed value to \(newSelection)")
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.uploadInstructionsController.start(on: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.uploadInstructionsController.stop(immediately: true)
        
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    @IBAction func uploadBtnPressed(_ sender: UIButton) {
        if wallpaperDescTextView.text.isEmpty && takenImage != nil  && (wallpaperCatPickLbl.text?.isEmpty)!  {
            closeBtn.isHidden = false // upload only if all fields are filled out
            //            FIRService.uploadWallToFirebaseStor(image: takenImage) { (, error) in
            //                
            //            }
            NotificationCenter.default.post(name: UploadWallpaperPopUp.updateFeedNotificationName, object: nil)
            // MARK: - Upload Successful Alert
            var attributes = EKAttributes.topFloat
            attributes.entryBackground = .color(color: UIColor.white)
            attributes.roundCorners = .all(radius: 10)
            attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            
            let titleText = "Upload Successful"
            let title = EKProperty.LabelContent(text: titleText, style: .init(font: UIFont.systemFont(ofSize: 20), color: UIColor.darkGray))
            let descText = "Your wallpaper image has been uploaded successfully"
            let description = EKProperty.LabelContent(text: descText, style: .init(font: UIFont.systemFont(ofSize: 17), color: UIColor.darkGray))
            let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35), makeRound: true)
            let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
            
            let contentView = EKNotificationMessageView(with: notificationMessage)
            SwiftEntryKit.display(entry: contentView, using: attributes)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction  func closeBtnPressed(_ sender: UIButton) {
        if wallpaperDescTextView.text.isEmpty && wallpaperPopUpView.image != nil && (wallpaperCatLbl.text?.isEmpty)! { // only close if data fields empty?
            // send data from wallpaperCatLbl?
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
        // Use compressedImage for upload
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Instructions Functions
extension UploadWallpaperPopUp: CoachMarksControllerDelegate, CoachMarksControllerDataSource {
    
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
