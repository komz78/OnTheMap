//
//  ConfirmAddInfoViewController.swift
//  OnTheMap
//
//  Created by Komil Bagshi on 23/12/2018.
//  Copyright © 2018 KamelBaqshi. All rights reserved.
//

import UIKit
import MapKit


class ConfirmAddInfoViewController: UIViewController , MKMapViewDelegate {
    
    
    @IBOutlet var mapView: MKMapView!
    
    var mapString:String?
    var mediaURL:String?
    var latitude:Double?
    var longitude:Double?
    var uniqueKey = (UIApplication.shared.delegate as! AppDelegate).uniqueKey
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        createAnnotation()
    }
    
    @IBAction func finishClicked(_ sender: Any) {
        ActivityIndicator.startActivityIndicator(view: self.view)
        APICalls.postStudentLocation(mapString, mediaURL, uniqueKey, latitude, longitude) { (studentsLocation, error) in
            
            DispatchQueue.main.async {
                
                if error != nil {
                    ActivityIndicator.stopActivityIndicator()
                    
                    let title = "Erorr performing request."
                    let message = "There was an error performing your request"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                    
                    return
                }
                ActivityIndicator.stopActivityIndicator()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }//end postStudentLocation
    }
    
    
    func createAnnotation(){
        
        let annotation = MKPointAnnotation()
        annotation.title = mapString!
        annotation.subtitle = mediaURL!
        annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
        self.mapView.addAnnotation(annotation)
        
        //zooming to location
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    
    //delegate - MapKit
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}
