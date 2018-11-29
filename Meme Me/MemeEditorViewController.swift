//
//  VMemeEditorViewController.swift
//  Meme Me
//
//  Created by João Leite on 08/10/18.
//  Copyright © 2018 João Leite. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController{
    
    // MARK: - Constants and Variables
    let memeTextAttributes:[NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        .strokeWidth: -3.0]
    var keyboardSubscription = false
    
    // MARK: - IBOutlets and IBActions

    @IBOutlet weak var imgPicker: UIImageView!
    @IBOutlet weak var btnCamera: UIBarButtonItem!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    @IBOutlet weak var txtTop: UITextField!
    @IBOutlet weak var txtBottom: UITextField!
    @IBOutlet weak var uiToolbar: UIToolbar!
    
    @IBAction func cameraButton(_ sender: Any) {
        presentPickerViewController(sourceType: .camera)
    }
    
    @IBAction func galeryButton(_ sender: Any) {
        presentPickerViewController(sourceType: .photoLibrary)
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        let newMemeImage = save()
        
        let shareView = UIActivityViewController(activityItems: [newMemeImage],
                                                 applicationActivities: nil)
        
        shareView.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                self.presentInformationAlert(alertTitle: "Uh-oh", alertMessage: "Your meme wasn't saved or shared.")
                return
            }
            self.presentInformationAlert(alertTitle: "Meme Saved!",
                                         alertMessage: "Your new meme is now saved on your Camera Roll")
            
            UIImageWriteToSavedPhotosAlbum(newMemeImage,
                                           self,
                                           #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                                           nil)
            
        }
        present(shareView, animated: true, completion: nil)
    }
    
    //MARK: - View Methods
    override func viewWillAppear(_ animated: Bool) {
        btnCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        toggleKeyboardNotificationSubscription()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField(txtTop)
        configureTextField(txtBottom)
        btnShare.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        toggleKeyboardNotificationSubscription()
    }
    
    // MARK: - Custom Methods
    
    func configureTextField(_ textField: UITextField) {
        textField.delegate = self
        textField.isEnabled = false
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    func presentPickerViewController(sourceType: UIImagePickerController.SourceType) {
        let viewController = UIImagePickerController()
        viewController.delegate = self
        viewController.sourceType = sourceType
        viewController.allowsEditing = true
        present(viewController, animated: true, completion: nil)
    }
    
    func save() -> UIImage {
        // Create the meme
        return Meme(topLabel: txtTop.text!, bottomLabel: txtBottom.text!, originalImage: imgPicker
            .image!, memeImage: generateMemedImage()).memeImage
        
    }
    
    func generateMemedImage() -> UIImage {
        hideToolbars(true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        hideToolbars(false)
        
        return memedImage
    }
    
    func hideToolbars(_ hide: Bool) {
        self.navigationController?.setNavigationBarHidden(hide, animated: false)
        self.uiToolbar.isHidden = hide
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            presentInformationAlert(alertTitle: "Failed to save image",
                                    alertMessage: error.localizedDescription)
        }
    }
    
    func presentInformationAlert(alertTitle: String, alertMessage: String){
        let informationAlert = UIAlertController(title: alertTitle,
                                                 message: alertMessage,
                                                 preferredStyle: .alert)
        
        informationAlert.addAction(UIAlertAction(title: "OK",
                                                 style: .default))
        present(informationAlert, animated: true, completion: nil)
    }
}

// MARK: - UIImagePicker and UINavigationController Methods
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imgPicker.image = image
            txtTop.isEnabled = true
            txtTop.text = "TOP"
            txtBottom.isEnabled = true
            txtBottom.text = "BOTTOM"
            btnShare.isEnabled = true
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - TextFieldDelegate Methods
extension MemeEditorViewController: UITextFieldDelegate {
    
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

