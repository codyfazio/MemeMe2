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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateMemes()
        configureNavUI()
        self.subscribeToKeyboardNotifications()
        
       
        
        //Only display shareButton if an image has been selected
        if (imageView.image == nil) {
            shareButton.enabled = false
        }
        else {
            shareButton.enabled = true}
        
        //Only display cancel button to return to Sent views if a meme has been sent
        if(memes.count >= 1) {
            cancelButton.enabled = true
        }
        else {
            cancelButton.enabled = false
        }
        
            }
    
    //When the current view is about to leave screen, stop listening for keyboard notifications
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    
    func configureNavUI() {
        
        setTextAttributes(bottomText, defaultText: "BOTTOM")
        setTextAttributes(topText, defaultText: "TOP")
        
        self.tabBarController?.hidesBottomBarWhenPushed = true

        //Set attributes for all bar buttons
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel , target: self, action: #selector(MemeEditorViewController.cancel))
        shareButton = UIBarButtonItem(barButtonSystemItem: .Action , target: self, action: #selector(MemeEditorViewController.share))

        //Arrange and display bar buttons
        navigationController?.setToolbarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = shareButton
        navigationItem.rightBarButtonItem = cancelButton
        navigationItem.hidesBackButton = true
    }
    
    //MARK: ImagePicker Functions
    @IBAction func pickImageFromAlbum(button: UIBarButtonItem) {
       presentImagePicker(.PhotoLibrary)
    }
    @IBAction func pickImageFromCamera(button:UIBarButtonItem) {
        presentImagePicker(.Camera)
    }
    
    func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker:UIImagePickerController){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage { imageView.image = image
            self.dismissViewControllerAnimated(true, completion: nil) }
    }
    
    
    //MARK: Text Field Functions
    func setTextAttributes(textField: UITextField, defaultText: String) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor() ,
            NSForegroundColorAttributeName : UIColor.whiteColor() ,
            NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
            NSStrokeWidthAttributeName : -5.0]
        
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        textField.textAlignment = NSTextAlignment.Center
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //MARK: Keyboard Related Functions
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomText.isFirstResponder() {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0 
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    //Meme Releated Functions
    
    //Save our generated Meme into our meme array
    func save () {
        memeImage = generateMemedImage()
        memeMaker = Meme (top: topText.text!, bottom: bottomText.text!, image: imageView.image!, memedImage: memeImage)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
            appDelegate.memes.append(memeMaker)
        }
    //Save a meme and present the Activity Controller with options for sharing a meme
    func share () {
        save()
        _ = [UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypeAirDrop,UIActivityTypeSaveToCameraRoll]
        let activity = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        activity.completionWithItemsHandler = { (activity, success, items, error) in
        let selectedMemeController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
            
            self.navigationController!.presentViewController(selectedMemeController, animated: true, completion: nil)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.setToolbarHidden(true, animated: false)
            
        }
        self.presentViewController(activity, animated: true, completion: nil)
    }

    //Create a meme by removing extraneous UI elements and capturing the view as an image
    func generateMemedImage() -> UIImage {
        hide(true,animated: true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        hide(false, animated: false)
        return memedImage
        }
    //Update the meme array
    func updateMemes(){
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
    }
    
    //Hides the navigation and tool bars
    func hide(flag: Bool, animated: Bool){
        navigationController?.setNavigationBarHidden(flag, animated:animated)
        navigationController?.setToolbarHidden(flag, animated:animated)
        tabBarController?.hidesBottomBarWhenPushed = true
        }
    
    
    //Dismisses the current view controler and displays the sent memes tabs
    func cancel(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as? UITabBarController
        self.navigationController?.presentViewController(detailController!, animated: true,completion:nil)
    }

}






