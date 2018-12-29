//
//  TableTabViewController.swift
//  OnTheMap
//
//  Created by Komil Bagshi on 18/12/2018.
//  Copyright © 2018 KamelBaqshi. All rights reserved.
//

import UIKit

class TableTabViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    var studentLocations = [StudentLocation]()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLocations()
    }
    
    @IBAction func refreshClicked(_ sender: Any) {
        getLocations()
    }
    
    
    func getLocations () {
        //remove array to refresh of before loading data
        studentLocations.removeAll()
        tableView.reloadData()
        ActivityIndicator.startActivityIndicator(view: self.view)
        
        APICalls.getAllLocations () {(studentsLocations, error) in
            
            DispatchQueue.main.async {
                
                if error != nil {
                    ActivityIndicator.stopActivityIndicator()
                    let title = "Erorr performing request"
                    let message = "There was an error: \(error?.localizedDescription ?? "?")"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                    return
                }
                
                guard let locationsArray = studentsLocations else {
                    let title = "Erorr loading locations"
                    let message = "There was an error: \(error?.localizedDescription ?? "?")"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                    return
                }
                
                self.studentLocations = locationsArray
                
                self.tableView.reloadData()
                ActivityIndicator.stopActivityIndicator()
            }
        }//end getAllStudentLocations
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        //as suggested in review this was fixed and found the sulotion  in " https://stackoverflow.com/questions/28532926/if-no-table-view-results-display-no-results-on-screen "
        if studentLocations.count > 0 {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        }
        else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
            
            return 0
        }
        return studentLocations.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //performe seuge then do in prepare
        let myCell = tableView.dequeueReusableCell(withIdentifier: "StudentCell") as! StudentTableViewCell
        if studentLocations.count == 0 {
            return myCell
        }
        
        let info = self.studentLocations[(indexPath as NSIndexPath).row]
        // Set the name and link
        myCell.nameLabel.text = ("\(info.firstName ?? "?") \(info.lastName ?? "?")")
        myCell.websiteLabel.text = ("\(info.mediaURL ?? "?")")
        //notyet
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let info = self.studentLocations[(indexPath as NSIndexPath).row]
        //found this solution for bad urls on "https://stackoverflow.com/questions/28079123/how-to-check-validity-of-url-in-swift"
        let stringWithPossibleURL: String = info.mediaURL ?? "?"
        if let validURL: NSURL = NSURL(string: stringWithPossibleURL) {
            // Successfully constructed an NSURL; open it
            if UIApplication.shared.canOpenURL(validURL as URL) {
                UIApplication.shared.open(validURL as URL, options: [:], completionHandler: { (success) in
                    if success {
                        print("Opened url : \(success)")
                    }
                    else {
                        let title = "Invalid URL"
                        let message = "Please try again."
                        displayAlert.displayAlert(message: message, title: title, vc: self)
                    }
                })
            }
        } else {
            let title = "Invalid URL"
            let message = "Please try again."
            displayAlert.displayAlert(message: message, title: title, vc: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}

