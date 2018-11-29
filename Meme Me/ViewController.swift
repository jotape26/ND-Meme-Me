//
//  ViewController.swift
//  Meme Me
//
//  Created by João Leite on 08/10/18.
//  Copyright © 2018 João Leite. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imgPicker: UIImageView!
    @IBOutlet weak var btnCamera: UIBarButtonItem!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    @IBOutlet weak var txtTop: UITextField!
    @IBOutlet weak var txtBottom: UITextField!
    @IBOutlet weak var uiToolbar: UIToolbar!
    
    
    var keyboardSubscription = false
    
    let memeTextAttributes:[NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0]
    
    override func viewWillAppear(_ animated: Bool) {
        btnCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        toggleKeyboardNotificationSubscription()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtTop.delegate = self
        txtTop.isEnabled = false
        txtTop.defaultTextAttributes = memeTextAttributes
        
        txtBottom.delegate = self
        txtBottom.isEnabled = false
        txtBottom.defaultTextAttributes = memeTextAttributes
        
        txtBottom.textAlignment = .center
        txtTop.textAlignment = .center
        btnShare.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        toggleKeyboardNotificationSubscription()
    }
    
    // MARK = NavigationControllerDelegate Methods
    
    @IBAction func cameraButton(_ sender: Any) {
        let cameraView = UIImagePickerController()
        cameraView.delegate = self
        cameraView.sourceType = .camera
        cameraView.allowsEditing = true
        present(cameraView, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        let newMemeImage = save()
        let shareView = UIActivityViewController(activityItems: [newMemeImage], applicationActivities: nil)
        present(shareView, animated: true, completion: nil)
        
    }
    
    @IBAction func galeryButton(_ sender: Any) {
        let pickerView = UIImagePickerController()
        pickerView.delegate = self
        present(pickerView, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imgPicker.image = image
            txtTop.isEnabled = true
            txtTop.text = "TOP"
            
            txtBottom.isEnabled = true
            txtBottom.text = "BOTTOM"
            
            btnShare.isEnabled = true
            
            imgPicker.frame = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func save() -> UIImage {
        // Create the meme
        return Meme(topLabel: txtTop.text!, bottomLabel: txtBottom.text!, originalImage: imgPicker
            .image!, memeImage: generateMemedImage()).memeImage
        
    }
    
    func generateMemedImage() -> UIImage {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.uiToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.uiToolbar.isHidden = false
        
        return memedImage
    }
    
    // MARK = TextFieldDelegate Methods
    
    func toggleKeyboardNotificationSubscription(){
        self.keyboardSubscription = !keyboardSubscription
        if(self.keyboardSubscription){
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }else{
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        if txtBottom.isEditing{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        view.frame.origin.y = 0
    } 
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

