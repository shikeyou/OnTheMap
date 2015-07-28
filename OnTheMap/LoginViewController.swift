//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Keng Siang Lee on 24/7/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    //outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    
    //gesture recognizers
    var tapRecognizer: UITapGestureRecognizer!
    
    //================================================
    // LIFECYLE METHODS
    //================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //assign delegates
        emailTextField.delegate = self
        passwordTextField.delegate = self

        //init tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: "singleTapCallback:")
        tapRecognizer.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardDismissRecognizer()
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardDismissRecognizer()
        
        unsubscribeToKeyboardNotifications()
    }
    
    //================================================
    // METHODS FOR HANDLING UI/KEYBOARD ISSUES
    //================================================
    
    func singleTapCallback(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {

        //decrease top constraint to keep UI elements at the top (and not beyond the top)
        titleTopConstraint.constant = 8.0
    }
    
    func keyboardWillHide(notification: NSNotification) {

        //shift constraint back
        titleTopConstraint.constant = 80
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //================================================
    // DELEGATE METHODS FOR TEXT FIELDS
    //================================================
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //finish editing and dismiss keyboard
        textField.resignFirstResponder()
        
        //process the return based on which text field it is
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            performLogin()
        }
        
        return true
    }
    
    //================================================
    // ACTIONS
    //================================================
    
    func performLogin() {
        
        //check for non-empty inputs
        if emailTextField.text == "" || passwordTextField.text == "" {
            UiHelper.showAlert(view: self, title: "Unable to login", msg: "Please fill in both email and password")
            return
        }
        
        //show activity indicator
        UiHelper.showActivityIndicator(view: self.view)
        
        //perform login
        UdacityClient.sharedInstance().login(email: emailTextField.text!, password: passwordTextField.text!, completionHandler: { success, errorMsg in
            
            //hide activity indicator
            dispatch_async(dispatch_get_main_queue(), {
                UiHelper.hideActivityIndicator()
            })
            
            if success {
                
                //empty password field and seque to tab view
                dispatch_async(dispatch_get_main_queue(), {
                    self.passwordTextField.text = ""
                    self.performSegueWithIdentifier("mainViewSegue", sender: self)
                })
                
            } else {
                
                //show error msg
                UiHelper.showAlertAsync(view: self, title: "Login Failed", msg: errorMsg)
                
            }
            
        })
        
    }
    
    func performSignup() {
        
        //open link in browser
        HttpHelper.openUrl("https://www.udacity.com/account/auth#!/signup", view: self)
        
    }
    
    @IBAction func loginButtonClicked(sender: UIButton) {

        //dismiss keyboard first
        view.endEditing(true)
        
        //login
        performLogin()
    }
    
    @IBAction func signUpButtonClicked(sender: UIButton) {
        //sign up
        performSignup()
    }

}

