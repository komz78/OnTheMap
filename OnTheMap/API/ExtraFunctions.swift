//
//  ExtraFunctions.swift
//  OnTheMap
//
//  Created by Komil Bagshi on 24/12/2018.
//  Copyright © 2018 KamelBaqshi. All rights reserved.
//

import Foundation
import UIKit


//activity indicator
struct ActivityIndicator {
    
    private static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    static func startActivityIndicator(view:UIView){
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    static func stopActivityIndicator(){
        activityIndicator.stopAnimating()
    }
}


struct displayAlert {
    
    static func displayAlert(message: String, title: String, vc: UIViewController)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion: nil)
    }
    
    
}
