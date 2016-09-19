//
//  MemeEditorViewController.swift
//
//  Created by Cody Fazio on 4/9/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import UIKit
import Foundation


class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    
    //MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    //MARK:Properties
    var memeMaker : Meme!
    var memes: [Meme]!
    var cancelButton = UIBarButtonItem()
    var shareButton = UIBarButtonItem()
    var memeImage = UIImage()
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        topText.delegate = self
        bottomText.delegate = self
        updateMemes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateMemes()
        configureNavUI()
        subscribeToKeyboardNotifications()
        
       
        
        //Only display shareButton if an image has been selected
        if (imageView.image == nil) {
            shareButton.isEnabled = false
        }
        else {
            shareButton.isEnabled = true}
        
        //Only display cancel button to return to Sent views if a meme has been sent
        if(memes.count >= 1) {
            cancelButton.isEnabled = true
        }
        else {
            cancelButton.isEnabled = false
        }
        
            }
    
    //When the current view is about to leave screen, stop listening for keyboard notifications
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    func configureNavUI() {
        
        setTextAttributes(bottomText, defaultText: "BOTTOM")
        setTextAttributes(topText, defaultText: "TOP")
        
        self.tabBarController?.hidesBottomBarWhenPushed = true

        //Set attributes for all bar buttons
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel , target: self, action: #selector(MemeEditorViewController.cancel))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action , target: self, action: #selector(MemeEditorViewController.share))

        //Arrange and display bar buttons
        navigationController?.setToolbarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = shareButton
        navigationItem.rightBarButtonItem = cancelButton
        navigationItem.hidesBackButton = true
    }
    
    //MARK: ImagePicker Functions
    @IBAction func pickImageFromAlbum(_ button: UIBarButtonItem) {
       presentImagePicker(.photoLibrary)
    }
    @IBAction func pickImageFromCamera(_ button:UIBarButtonItem) {
        presentImagePicker(.camera)
    }
    
    func presentImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController){
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage { imageView.image = image
            self.dismiss(animated: true, completion: nil) }
    }
    
    
    //MARK: Text Field Functions
    func setTextAttributes(_ textField: UITextField, defaultText: String) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.black ,
            NSForegroundColorAttributeName : UIColor.white ,
            NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
            NSStrokeWidthAttributeName : -5.0] as [String : Any]
        
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        textField.textAlignment = NSTextAlignment.center
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //MARK: Keyboard Related Functions
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if bottomText.isFirstResponder {
        self.view.frame.origin.y += getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.view.frame.origin.y = 0 
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    //Meme Related Functions
    
    //Save our generated Meme into our meme array
    func save () {
        memeImage = generateMemedImage()
        memeMaker = Meme (top: topText.text!, bottom: bottomText.text!, image: imageView.image!, memedImage: memeImage)
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
            appDelegate.memes.append(memeMaker)
        }
    //Save a meme and present the Activity Controller with options for sharing a meme
    func share () {
        save()
        _ = [UIActivityType.postToFacebook,UIActivityType.postToTwitter,UIActivityType.message,UIActivityType.mail,UIActivityType.airDrop,UIActivityType.saveToCameraRoll]
        let activity = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        activity.completionWithItemsHandler = { (activity, success, items, error) in
        let selectedMemeController = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            
            self.navigationController!.present(selectedMemeController, animated: true, completion: nil)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.setToolbarHidden(true, animated: false)
            
        }
        self.present(activity, animated: true, completion: nil)
    }

    //Create a meme by removing extraneous UI elements and capturing the view as an image
    func generateMemedImage() -> UIImage {
        hide(true,animated: true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawHierarchy(in: self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        hide(false, animated: false)
        return memedImage
        }
    //Update the meme array
    func updateMemes(){
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }
    
    //Hides the navigation and tool bars
    func hide(_ flag: Bool, animated: Bool){
        navigationController?.setNavigationBarHidden(flag, animated:animated)
        navigationController?.setToolbarHidden(flag, animated:animated)
        tabBarController?.hidesBottomBarWhenPushed = true
        }
    
    
    //Dismisses the current view controler and displays the sent memes tabs
    func cancel(){
        self.navigationController?.dismiss(animated: true, completion: nil)
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
        self.navigationController?.present(detailController!, animated: true,completion:nil)
    }

}






