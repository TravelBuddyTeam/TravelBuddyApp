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
        
        //set values in cell
        cell.locationNameLabel.text = travelLocations[indexPath.row].value(forKey: "name") as? String
        cell.locationDescriptionLabel.text = travelLocations[indexPath.row].value(forKey: "synopsis") as? String
        
        cell.location = travelLocations[indexPath.row]
        
        let visited = travelLocations[indexPath.row].value(forKey: "visited") as! Bool
        
        cell.updateButton(visited: visited)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
    }

}
