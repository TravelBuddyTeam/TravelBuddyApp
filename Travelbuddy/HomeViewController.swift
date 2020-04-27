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
    
    var suggestions:[MKMapItem] = []
    var annotations:[MKAnnotation] = []
    
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
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: location, span: mapSpan)
        mapView.setRegion(region, animated: true)
        
        // remove all anotations before adding
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
        
        // Add annotation
        let travelLocationAnnotation = TravelLocationAnnotation(
            title: "Add to Travel locations?",
            subtitle: selectedSuggestion.name,
            coordinate: location
        )
        mapView.addAnnotation(travelLocationAnnotation)
        annotations.append(travelLocationAnnotation)
        
        hideSuggestionTable()
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        // find users around the location
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        // create annotation view
        if annotation.isKind(of: TravelLocationAnnotation.self) {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")

            annotationView.pinTintColor = UIColor.red
            annotationView.canShowCallout = true
            let button = UIButton(type: .contactAdd)
            button.addTarget(self, action: #selector(HomeViewController.AddLocation(sender:)), for: .touchUpInside)
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
    }
}
