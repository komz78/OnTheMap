//
//  AddInfoViewController.swift
//  OnTheMap
//
//  Created by Komil Bagshi on 18/12/2018.
//  Copyright © 2018 KamelBaqshi. All rights reserved.
//


import UIKit
import MapKit

class AddInfoViewController: UIViewController {
    
    //iboutlets
    
    @IBOutlet var websiteTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    
    //long lat values
    var latitude : Double?
    var longitude : Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        websiteTextField.delegate = self
        locationTextField.delegate = self
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
    
    @IBAction func cancelClicked(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func findLocationClicked(_ sender: Any) {
        websiteTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        
        guard let websiteLink = websiteTextField.text else {return}
        
        let prefixOfwebsiteLinkFirst = String(websiteLink.prefix(7)) // http://
        let prefixOfwebsiteLinkSecond = String(websiteLink.prefix(8)) // https://
        
        // i wrote the below conditinion instead of
        // (prefixOfwebsiteLinkFirst == "http://") || (prefixOfwebsiteLinkSecond == "https://") ONLY!
        // because if the link is shorter than 7 it wont check the condition, so i had to check for the whole text range also, then check the prefix of website links.
        // ----- Note to self.
        
        let rangeCheckBool = (websiteLink.range(of:"http://") == nil ) || (websiteLink.range(of:"https://") == nil )
        let prefixCheckBool = (prefixOfwebsiteLinkFirst == "http://") || (prefixOfwebsiteLinkSecond == "https://")
        
        if  rangeCheckBool  &&  !prefixCheckBool {
            
            let title = "Invalid URL"
            let message = "No http:// or https:// in website link."
            displayAlert.displayAlert(message: message, title: title, vc: self)
            
            
        } else {
            if locationTextField.text != "" && websiteTextField.text != "" {
                
                ActivityIndicator.startActivityIndicator(view: self.view )
                
                let searchRequest = MKLocalSearch.Request()
                searchRequest.naturalLanguageQuery = locationTextField.text
                
                let activeSearch = MKLocalSearch(request: searchRequest)
                
                activeSearch.start { (response, error) in
                    
                    if error != nil {
                        ActivityIndicator.stopActivityIndicator()
                        let title = "Location not found."
                        let message = "Location Error : \(error!.localizedDescription)."
                        displayAlert.displayAlert(message: message, title: title, vc: self)
                        
                    }else {
                        ActivityIndicator.stopActivityIndicator()
                        self.latitude = response?.boundingRegion.center.latitude
                        self.longitude = response?.boundingRegion.center.longitude
                        self.performSegue(withIdentifier: "confirmAddInfoSegue", sender: nil)
                    }
                }
            }else {
                
                let title = "Location error."
                let message = "Enter URL or Location"
                displayAlert.displayAlert(message: message, title: title, vc: self)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmAddInfoSegue"{
            let vc = segue.destination as! ConfirmAddInfoViewController
            vc.latitude = self.latitude
            vc.longitude = self.longitude
            vc.mapString = locationTextField.text
            vc.mediaURL = websiteTextField.text
            
        }
        
    }
    
    //keyboard
    
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
        if websiteTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)/2
        }
        if locationTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)/2
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
    
    
}

extension AddInfoViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
