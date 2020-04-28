//
//  HomeViewController.swift
//  Travelbuddy
//
//  Created by Steven Carey on 4/8/20.
//  Copyright © 2020 Travel Buddy Team. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class HomeViewController: UIViewController, CLLocationManagerDelegate,
MKMapViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var suggestionsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager : CLLocationManager!
    var lastLocation : CLLocationCoordinate2D!
    var chosenSuggestion : MKPlacemark!
    
    var createdLocation : PFObject!
    
    var suggestions:[MKMapItem] = []
    var locationAnnotations:[TravelLocationAnnotation] = []
    var usersAnnotations:[UsersLocationAnnotation] = []
    
    var nearByUsers : [PFObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        searchBar.delegate = self
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    private func hideSuggestionTable() {
        suggestionsTableView.isHidden = true
    }
    
    private func showSuggestionTable() {
        suggestionsTableView.isHidden = false
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let annotations = [mapView.userLocation]
        mapView.showAnnotations(annotations, animated: false)
        
        // store users location
        let geoPoint = PFGeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        if let currentUser = PFUser.current(){
            if (currentUser.value(forKey: "location") == nil) {
                currentUser["location"] = geoPoint
                currentUser.saveInBackground()
            }
        }
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.first as? CLLocation
        lastLocation = location?.coordinate
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // give suggestions
        let searchBarText = searchBar.text
        
        let suggestionsRequest = MKLocalSearch.Request()
        suggestionsRequest.naturalLanguageQuery = searchBarText
        suggestionsRequest.region = mapView.region
        let search = MKLocalSearch(request: suggestionsRequest)
        
        search.start { (response, error) in
            guard let response = response else {
                return
            }
            
            self.suggestions = response.mapItems
            self.suggestionsTableView.reloadData()
        }
        
        self.suggestionsTableView.frame = CGRect(
            x: self.suggestionsTableView.frame.maxX,
            y: self.suggestionsTableView.frame.maxY,
            width: self.suggestionsTableView.frame.width,
            height: CGFloat()
        )
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        hideSuggestionTable()
        // find location on map
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // set to show cancel button
        searchBar.showsCancelButton = true
        
        // show suggestions table view
        showSuggestionTable()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        hideSuggestionTable()
        suggestions.removeAll()
        suggestionsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell", for: indexPath) as! SuggestionCell
        
        let suggestion = suggestions[indexPath.row].placemark
        cell.locationNameLabel.text = suggestion.name
        
        cell.locationAddressLabel.text = "\(suggestion.thoroughfare == nil ? "" : suggestion.thoroughfare! + ", ")\(suggestion.subLocality == nil ? "" : suggestion.subLocality! + ", ")\(suggestion.locality == nil ? "" : suggestion.locality! + ", ")\(suggestion.administrativeArea == nil ? "" : suggestion.administrativeArea! + " ")\(suggestion.postalCode == nil ? "" : suggestion.postalCode! + ", ") \(suggestion.country == nil ? "" : suggestion.country!)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show the location selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedSuggestion = suggestions[indexPath.row].placemark
        chosenSuggestion = selectedSuggestion
        // Get chosen location and show on map
        let location = selectedSuggestion.coordinate
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
        let region = MKCoordinateRegion(center: location, span: mapSpan)
        mapView.setRegion(region, animated: true)
        
        // remove all location anotations before adding
        mapView.removeAnnotations(locationAnnotations)
        mapView.removeAnnotations(usersAnnotations)
        usersAnnotations.removeAll()
        locationAnnotations.removeAll()
        
        // Add annotation
        let travelLocationAnnotation = TravelLocationAnnotation(
            title: "Travel To",
            subtitle: selectedSuggestion.name,
            coordinate: location
        )
        mapView.addAnnotation(travelLocationAnnotation)
        locationAnnotations.append(travelLocationAnnotation)
        
        hideSuggestionTable()
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        // find users around the location
        let radiusUsers = 50.0 // in mile
        let locationGeoPoint = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        
        GetUsersInRadius(radius: radiusUsers, pivot: locationGeoPoint)
    }
    
    func GetUsersInRadius(radius : Double, pivot : PFGeoPoint) {
        let query = PFQuery(className:"_User")
        query.whereKey("location", nearGeoPoint: pivot, withinMiles: radius)
        query.whereKey("username", notEqualTo: (PFUser.current()?.username)! as String)
        //query.whereKey("username", equalTo: "diddy")
        print("Pivot: latitude: \(pivot.latitude) longitude: \(pivot.longitude)")
        query.findObjectsInBackground { (users: [PFObject]?, error: Error?) in
            if users != nil {
                self.nearByUsers = users
                print("Total nearby Users: \(users!.count)")

                for user in self.nearByUsers {
                     //Add user annotation

                    let username = user.value(forKey: "username") as? String
                    let userLocation = user.value(forKey: "location") as? PFGeoPoint
                    let coordinate = CLLocationCoordinate2D(latitude: userLocation!.latitude, longitude: userLocation!.longitude)

                    // Add annotation
                    let userLocationAnnotation = UsersLocationAnnotation(
                        title: username,
                        subtitle: "Travel Buddy (default status message)",
                        coordinate: coordinate
                    )
                    self.mapView.addAnnotation(userLocationAnnotation)
                    self.usersAnnotations.append(userLocationAnnotation)
                }
            } else {
                print("Error: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        // create locations annotation view
        if annotation.isKind(of: TravelLocationAnnotation.self) {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")

            annotationView.pinTintColor = UIColor.red
            annotationView.canShowCallout = true
            let button = UIButton(type: .contactAdd)
            button.addTarget(self, action: #selector(HomeViewController.AddLocation(sender:)), for: .touchUpInside)
            annotationView.rightCalloutAccessoryView = button
            
            return annotationView
        }
        
        // create users annotation view
        if annotation.isKind(of: UsersLocationAnnotation.self) {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "userPin")

            annotationView.pinTintColor = UIColor.green
            annotationView.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = button
            
            return annotationView
        }

        return nil
    }
    
    @objc func AddLocation(sender: UIButton) {
        // Add location coordinate to database
        let view = sender.superview
        view?.removeFromSuperview()
        
        let address = "\(chosenSuggestion.thoroughfare == nil ? "" : chosenSuggestion.thoroughfare! + ", ")\(chosenSuggestion.subLocality == nil ? "" : chosenSuggestion.subLocality! + ", ")\(chosenSuggestion.locality == nil ? "" : chosenSuggestion.locality! + ", ")\(chosenSuggestion.administrativeArea == nil ? "" : chosenSuggestion.administrativeArea! + " ")\(chosenSuggestion.postalCode == nil ? "" : chosenSuggestion.postalCode! + ", ") \(chosenSuggestion.country == nil ? "" : chosenSuggestion.country!)"
        
        let location = PFObject(className: "Location")
        location["visited"] = false;
        location["user"] = PFUser.current()
        location["coordinate"] = PFGeoPoint(latitude: chosenSuggestion.coordinate.latitude, longitude: chosenSuggestion.coordinate.longitude)
        location["address"] = address
        location["createdOn"] = Date()
        location["name"] = chosenSuggestion.name
        location["synopsis"] = chosenSuggestion.description
        location.saveInBackground()
        
        // store created location for segue access
        createdLocation = location
        
        // perform segue to locations
        performSegue(withIdentifier: "mapToLocationSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToLocationSegue" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let detailsViewController = destinationNavigationController.topViewController as! LocationDetailsViewController
            
            detailsViewController.location = createdLocation
        }
    }
}
