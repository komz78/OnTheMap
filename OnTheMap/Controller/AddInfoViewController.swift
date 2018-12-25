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

    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func findLocationClicked(_ sender: Any) {
        
        guard let websiteLink = websiteTextField.text else {return}
        
        if websiteLink.range(of:"http://") == nil{

            let title = "Invalid URL"
            let message = "No http:// in website."
            displayAlert.displayAlert(message: message, title: title, vc: self)
            
        }else {
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
    
    
}
