//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by  lama almarshad on 03/10/2019.
//  Copyright © 2019  lama almarshad. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var TopText: UITextField!
    @IBOutlet weak var BottomText: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolBarTop: UIToolbar!
    @IBOutlet weak var navBarBottom: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTextField(TopText, with: "Top")
        setupTextField(BottomText, with: "Bottom")
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
    }
    
    func setupTextField(_ textField: UITextField, with defaultText: String)  {
        textField.text = defaultText
        textField.textAlignment = NSTextAlignment.center
        textField.defaultTextAttributes = [ NSAttributedString.Key
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        .foregroundColor: UIColor.white,
        .strokeColor: UIColor.black,
        .strokeWidth: -3.0]
        textField.delegate = self
    }
     func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text=""
     }
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if BottomText.isEditing {
            view.frame.origin.y = -(getKeyboardHight(notification: notification))
        }
    }
     func subscribeToKeyboardNotifications()   {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name:  UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                                name:  UIResponder.keyboardWillHideNotification,
                                                object: nil)
    }
    @objc func keyboardWillHide(_ notification : Notification)  {
        view.frame.origin.y = 0//+= getKeyboardHight(notification: notification)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification,                                       object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification,                                       object: nil)
    }
    func getKeyboardHight(notification : Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    struct Meme {
        let topText : String
        let bottomText : String
        let originalImage : UIImage
        let memedImage : UIImage
    }
    func save(memedImage : UIImage) {
            // Create the meme
            let meme = Meme(topText: TopText.text!, bottomText: BottomText.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    func generateMemedImage() -> UIImage {
         // TODO: Hide toolbar and navbar
        toolBarTop.isHidden = true
        navBarBottom.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        toolBarTop.isHidden = false
        navBarBottom.isHidden = false
        
        return memedImage
    }
    
   
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        presentImagePickerOfType(sourceType: .photoLibrary)
        /*let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)*/
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = pickedImage
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.clipsToBounds = false
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func presentImagePickerOfType(sourceType: UIImagePickerController.SourceType)  {
         let imagePicker = UIImagePickerController()
               imagePicker.delegate = self
               imagePicker.sourceType = sourceType
               present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        presentImagePickerOfType(sourceType: .camera)
        /*let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)*/
    }
    
    @IBAction func cancleImage(_ sender: Any){//_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareImage(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [generateMemedImage()],                                                                applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            (type, complated, item, error) in
            if complated {
                self.save(memedImage: memedImage)
            }
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}

