//
//  ViewController.swift
//  MemeMe
//
//  Created by Anirudh Lath on 1/23/19.
//  Copyright © 2019 Anirudh Lath. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isEnabled = false
        
        setTextFieldAttributes(TextField: topText, String: "TOP")
        setTextFieldAttributes(TextField: bottomText, String: "BOTTOM")
        
        topText.delegate = self
        bottomText.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setTextFieldAttributes(TextField: UITextField, String: String) {
        
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth:  -4.0,
            ]
        
        TextField.defaultTextAttributes = memeTextAttributes
        TextField.text = String
        TextField.textAlignment = .center
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
        }
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imageSourceTypeIdentifier(SourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = SourceType
        present(pickerController, animated: true, completion: nil)
    }

    @IBAction func pickAnImage(_ sender: Any) {
        imageSourceTypeIdentifier(SourceType: .photoLibrary)
    }
    
    @IBAction func clickAnImage(_ sender: Any) {
        imageSourceTypeIdentifier(SourceType: .camera)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        
        navBar.isHidden = true
        toolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        navBar.isHidden = false
        toolbar.isHidden = false
        
        return memedImage
    }
    
    struct Meme {
        var topEntry: String = ""
        var bottomEntry: String = ""
        var originalImage: UIImage?
        var memedImage: UIImage?
    }
    
    func save() {
        // Create the meme
        _ = Meme(topEntry: topText.text!, bottomEntry: bottomText.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }
    
    
    @IBAction func shareMeme(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = {(activity, success, items, errors) in
            if (success) {
                self.save()
            }
        }
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.imagePickerView.image = nil
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

