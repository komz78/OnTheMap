//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Komil Bagshi on 18/12/2018.
//  Copyright © 2018 KamelBaqshi. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var warningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        
        passwordTextField.resignFirstResponder()

        guard let username = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        ActivityIndicator.startActivityIndicator(view: self.view)
        
        if (username.isEmpty) || (password.isEmpty) {
            ActivityIndicator.stopActivityIndicator()
            let title = "Fill the required fields"
            let message = "Please fill both the email and password"
            displayAlert.displayAlert(message: message, title: title, vc: self)
            
        } else {
            APICalls.login(username, password){(loginSuccess, key, error) in
                DispatchQueue.main.async {
                    //print the error
                    if error != nil {
                        ActivityIndicator.stopActivityIndicator()
                        let title = "Erorr performing request"
                        let message = "There was an error performing your request"
                        displayAlert.displayAlert(message: message, title: title, vc: self)
                        return
                    }
                    
                    //check boolean
                    if !loginSuccess {
                        ActivityIndicator.stopActivityIndicator()
                        
                        let title = "Erorr logging in"
                        let message = "incorrect email or password"
                        displayAlert.displayAlert(message: message, title: title, vc: self)
                    } else {
                        ActivityIndicator.stopActivityIndicator()
                        self.performSegue(withIdentifier: "MapViewController", sender: nil)
                        print ("the key is \(key)")
                        // add key to the app delegate
                        (UIApplication.shared.delegate as! AppDelegate).uniqueKey = key
                    }
                }}
        }
    }
    
    
    // view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //signup
    @IBAction func signupClicked(_ sender: Any) {
        //open udacity signup page url
        guard let url = URL(string: "https://auth.udacity.com/sign-up") else {return}
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Opened url : \(success)")
            })
        }
    }
    
    //keyboard
    func subscribeToKeyboardNotifications() {
        //show
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        //hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        //show
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if emailTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
        if passwordTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    // MARK: - Validation
    func isValidateEmail(email:String) -> Bool {
        return (email.count >= 7) && (email.contains("@")) && (email.contains("."))
    }
    
    func isValidatePassword(password:String) -> Bool {
        return password.count >= 6
    }
    
}


extension LoginViewController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }
    
}


extension LoginViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailTextField {
            if !isValidateEmail(email: textField.text!) {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
                warningLabel.text = "Bad Email format..."
            } else {
                textField.layer.borderWidth = 0.0
                warningLabel.text = ""
            }
        }
        
        if textField == passwordTextField {
            if !isValidatePassword(password: textField.text!) {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
                warningLabel.text = "Short Password..."
            } else {
                textField.layer.borderWidth = 0.0
                warningLabel.text = ""
            }
        }
        
        return true
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderWidth = 0
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
