//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Komil Bagshi on 18/12/2018.
//  Copyright © 2018 KamelBaqshi. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        
        APICalls.deleteSession { (logoutSuccess, key, error) in
            
            DispatchQueue.main.async {
                //print the error
                if error != nil {
                    let title = "Erorr performing request"
                     let message = "There was an error: \(error?.localizedDescription ?? "?")"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                    return
                }
                
                //check boolean
                if !logoutSuccess {
                    let title = "Erorr logging out"
                     let message = "There was an error: \(error?.localizedDescription ?? "?")"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                } else {
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    print ("the key is \(key)")
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLocations()
    }
    
    
    @IBAction func refreshClicked(_ sender: Any) {
        getLocations()
    }
    
    
    func getLocations () {
        
        ActivityIndicator.startActivityIndicator(view: self.mapView)
        //remove pins before loading data
        mapView.removeAnnotations(mapView.annotations)
        
        APICalls.getAllLocations () {(studentsLocations, error) in
            
            DispatchQueue.main.async {
                
                if error != nil {
                    ActivityIndicator.stopActivityIndicator()
                    let title = "Erorr performing request"
                    let message = "There was an error: \(error?.localizedDescription ?? "?")"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                    return
                }
                
                var annotations = [MKPointAnnotation] ()
                
                guard let locationsArray = studentsLocations else {
                    let title = "Erorr loading locations"
                     let message = "There was an error: \(error?.localizedDescription ?? "?")"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                    return
                }
                
                //Loop through the array of structs and get locations data from it so they can be displayed on the map
                for locationStruct in locationsArray {
                    
                    let long = CLLocationDegrees (locationStruct.longitude ?? 0)
                    let lat = CLLocationDegrees (locationStruct.latitude ?? 0)
                    
                    let coords = CLLocationCoordinate2D (latitude: lat, longitude: long)
                    let mediaURL = locationStruct.mediaURL ?? " "
                    let first = locationStruct.firstName ?? " "
                    let last = locationStruct.lastName ?? " "
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coords
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    annotations.append (annotation)
                }
                ActivityIndicator.stopActivityIndicator()
                self.mapView.addAnnotations (annotations)
            }
        }//end getAllLocations
    
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}
