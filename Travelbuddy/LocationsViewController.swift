//
//  LocationsViewController.swift
//  Travelbuddy
//
//  Created by Steven Carey on 4/19/20.
//  Copyright © 2020 Travel Buddy Team. All rights reserved.
//

import UIKit
import Parse

class LocationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var locationsTableView: UITableView!
    
    var travelLocations : [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationsTableView.dataSource = self
        locationsTableView.delegate = self
        
        
        GetLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        GetLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        GetLocations()
    }
    
    func GetLocations() {
        // Get all locations for the current user
        let query = PFQuery(className:"Location")
        query.whereKey("user", equalTo: PFUser.current()!)
        query.order(byDescending: "createdOn")
        query.findObjectsInBackground { (locations: [PFObject]?, error: Error?) in
            if locations != nil {
                // locations retrieved
                self.travelLocations = locations!
                self.locationsTableView.reloadData()
            } else {
                print("Error: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return travelLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = locationsTableView.dequeueReusableCell(withIdentifier: "LocationsTableViewCell") as! LocationsTableViewCell
        
        let location = travelLocations[indexPath.row]
        //set values in cell
        cell.locationNameLabel.text = location.value(forKey: "name") as? String
        cell.locationDescriptionLabel.text = location.value(forKey: "synopsis") as? String
        
        cell.location = travelLocations[indexPath.row]
        
        let visited = location.value(forKey: "visited") as! Bool
        
        cell.updateButton(visited: visited)
        
        if location.value(forKey: "locationImage") != nil {
            let imageFile = location.value(forKey: "locationImage") as! PFFileObject
            let imageUrlString = imageFile.url!
            let imageUrl = URL(string: imageUrlString)!
            cell.locationImageView.af_setImage(withURL: imageUrl)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationDetailViewControllerSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = locationsTableView.indexPath(for: cell)
            if  indexPath != nil {
                let destinationNavigationController = segue.destination as! UINavigationController
                let detailsViewController = destinationNavigationController.topViewController as! LocationDetailsViewController
                
                detailsViewController.location = travelLocations[indexPath!.row]
            }
        }
    }

}
