//
//  ViewController.swift
//  MemeMe
//
//  Created by Carol Chapman on 12/6/15.
//  Copyright © 2015 Carol Chapman. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -8.0
    ]

    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var topText: UITextField!
    
    @IBOutlet weak var bottomText: UITextField!

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var topTextConstraint : NSLayoutConstraint!
    var bottomTextConstraint : NSLayoutConstraint!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        setTextDefaults(topText, defaultText: "TOP", tag: 100)
        setTextDefaults(bottomText, defaultText: "BOTTOM", tag: 200)
    
        shareButton.enabled = imagePickerView.image != nil
    }
    
    func setTextDefaults(textField: UITextField, defaultText: String, tag: Int) {
        textField.text = defaultText
        textField.tag = tag
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
    }

    @IBAction func pickPhoto(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func share(sender: AnyObject) {
        let newImage = generateMemedImage()
        let objectsToShare = [newImage]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        activityVC.completionWithItemsHandler = {
            (activity, success, items, error) in
            if success {
                self.save()
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        presentViewController(activityVC, animated: true, completion: nil)
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        //set everything to initial state
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        imagePickerView.image = nil
        shareButton.enabled = false
    }
    
    func save() {
        //Create the meme
        let imageToSave = generateMemedImage()
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, memedImage: imageToSave)
        
        // Add it to the memes array in the Application Delegate
        (UIApplication.sharedApplication().delegate as!
            AppDelegate).memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage
    {
        toolBar.hidden = true
        navigationBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolBar.hidden = false
        navigationBar.hidden = false
        
        return memedImage
    }
    
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.enabled = true
        } else {
            shareButton.enabled = false
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel() {
        shareButton.enabled = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomText.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0

    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "TOP" && textField.tag == 100 {
            textField.text = ""
        }
        else if textField.text == "BOTTOM" && textField.tag == 200 {
            textField.text = ""
        }
    }
    
    /**
     thanks to Frazer Hogg for this code
        http://stackoverflow.com/questions/32479499/updating-auto-layout-constraints-to-reposition-text-field
    */
    func layoutTextFields() {
        
        //Remove any existing constraints
        if topTextConstraint != nil {
            view.removeConstraint(topTextConstraint)
        }
        
        if bottomTextConstraint != nil {
            view.removeConstraint(bottomTextConstraint)
        }
        
        //Get the position of the image inside the imageView
        let size = imagePickerView.image != nil ? imagePickerView.image!.size : imagePickerView.frame.size
        let frame = AVMakeRectWithAspectRatioInsideRect(size, imagePickerView.bounds)
        
        //A margin for the new constrains; 10% of the frame's height
        let margin = frame.origin.y + frame.size.height * 0.10
        
        //Create and add the new constraints
        topTextConstraint = NSLayoutConstraint(
            item: topText,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: imagePickerView,
            attribute: .Top,
            multiplier: 1.0,
            constant: margin)
        view.addConstraint(topTextConstraint)
        
        bottomTextConstraint = NSLayoutConstraint(
            item: bottomText,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: imagePickerView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: -margin)
        view.addConstraint(bottomTextConstraint)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTextFields()
    }


}

