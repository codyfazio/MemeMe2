//
//  MemeEditorViewController.swift
//
//  Created by Cody Fazio on 4/9/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import UIKit
import Foundation


class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    //Create global variable to save Meme
    var memeMaker : Meme!
    //Create array to pass to AppDelegate
    var memes: [Meme]!
    
    //Add references to UI elements in storyboard
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    //Create variables to store buttons for navigation and tab bars
    var pickImagefromAlbumButton = UIBarButtonItem()
    var pickImagefromCameraButton = UIBarButtonItem()
    var flexibleSpaceButton = UIBarButtonItem()
    var cancelButton = UIBarButtonItem()
    var shareButton = UIBarButtonItem()
    var memeImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set delegates for text elements
        topText.delegate = self
        bottomText.delegate = self
        //Call function to update memes array
        updateMemes()
    }
    
       override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Call function to update memes array
        updateMemes()
        //Start listening for notifications related to keyboard
        self.subscribeToKeyboardNotifications()
        //Hide tab bar
        self.tabBarController?.hidesBottomBarWhenPushed = true
        
        //Set all text attributes for text fields
        setTextAttributes(bottomText)
        setTextAttributes(topText)
        
        //Set initial text for text fields
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        
        //Set attributes for all bar buttons
        pickImagefromAlbumButton = UIBarButtonItem(title: "Album", style: .Done, target: self, action: "pickImageFromAlbum")
        pickImagefromCameraButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "pickImageFromCamera")
        pickImagefromCameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel , target: self, action: "cancel")
        shareButton = UIBarButtonItem(barButtonSystemItem: .Action , target: self, action: "share")
        
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
        
        //Arrange and display bar buttons
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.toolbarItems = [flexibleSpaceButton,pickImagefromAlbumButton,flexibleSpaceButton,pickImagefromCameraButton,flexibleSpaceButton]
        self.navigationItem.rightBarButtonItem = shareButton
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.hidesBackButton = true
    }
    
    //When the current view is about to leave screen, stop listening for keyboard notifications
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    //Display image picker controller to select image from library
    func pickImageFromAlbum() {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    //Take a picture and use it for a meme
    func pickImageFromCamera() {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Dismiss image picker controller without selecting an image
    func imagePickerControllerDidCancel(picker:UIImagePickerController){
        println("dismissing imagepicker")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //When an image for memeing has been selected, store the image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage { imageView.image = image
            self.dismissViewControllerAnimated(true, completion: nil) }
    }
    
    //Text Field Related Functions
    
    func setTextAttributes(textfield: UITextField) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor() ,
            NSForegroundColorAttributeName : UIColor.whiteColor() ,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3.0]
        
        textfield.defaultTextAttributes = memeTextAttributes
        textfield.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        textfield.textAlignment = NSTextAlignment.Center
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool //
    { topText.resignFirstResponder()
        bottomText.resignFirstResponder()
        return true
    }
    
    
    //Keyboard Related Functions
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomText.editing {
        self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomText.editing {
            bottomText.endEditing(true)
            self.view.frame.origin.y += getKeyboardHeight(notification) }
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
        let objectsToShare = [UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypeAirDrop,UIActivityTypeSaveToCameraRoll]
        let activity = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        activity.completionWithItemsHandler = { (activity, success, items, error) in
        let selectedMemeController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")! as! UITabBarController
            
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
        self.navigationController?.setNavigationBarHidden(flag, animated:animated)
        self.navigationController?.setToolbarHidden(flag, animated:animated)
        self.tabBarController?.hidesBottomBarWhenPushed = true
        }
    //Dismisses the current view controler and displays the sent memes tabs
    func cancel(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")! as? UITabBarController
        self.navigationController?.presentViewController(detailController!, animated: true,completion:nil)
    }

}






