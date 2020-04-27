//
//  LocationDetailsViewController.swift
//  Travelbuddy
//
//  Created by Daniel Adu-Djan on 4/27/20.
//  Copyright © 2020 Travel Buddy Team. All rights reserved.
//

import UIKit
import MapKit
import Parse

class LocationDetailsViewController: UIViewController {
    
    var location : PFObject!
    
    @IBOutlet weak var heroLocationImageView: UIImageView!
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var locationAddressTextField: UITextField!
    @IBOutlet weak var locationDescriptionTextField: UITextField!
    @IBOutlet weak var locationVisitedSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let visited = location.value(forKey: "visited") as! Bool
        
        locationNameTextField.text = location.value(forKey: "name") as? String
        locationAddressTextField.text = location.value(forKey: "address") as? String
        locationDescriptionTextField.text = location.value(forKey: "synopsis") as? String
        if (visited) {
            locationVisitedSegmentedControl.selectedSegmentIndex = 0
        } else {
            locationVisitedSegmentedControl.selectedSegmentIndex = 1
        }
    }

    @IBAction func onVisitedToggle(_ sender: Any) {
        if locationVisitedSegmentedControl.selectedSegmentIndex == 0 {
            location["visited"] = true
        } else {
            location["visited"] = false
        }
        location.saveInBackground()
    }
    
    
    
    @IBAction func onUpdateButton(_ sender: Any) {
        location["name"] = locationNameTextField.text
        location["address"] = locationAddressTextField.text
        location["synopsis"] = locationDescriptionTextField.text
        location.saveInBackground()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
