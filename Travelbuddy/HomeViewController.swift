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
    
    var suggestions:[MKMapItem] = []
    
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
    }
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.first as? CLLocation
        lastLocation = location?.coordinate
        
        // store users location
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
            
//            self.suggestionsTableView.frame = CGRect(x: self.suggestionsTableView.frame.maxX, y: self.suggestionsTableView.frame.maxY, width: self.suggestionsTableView.frame.width, height: CGFloat(self.suggestions.count * 100))
        }
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell", for: indexPath) as! SuggestionCell
        
        let suggestion = suggestions[indexPath.row].placemark
        cell.locationNameLabel.text = suggestion.name
        
        cell.locationAddressLabel.text = "\(suggestion.thoroughfare ?? "") \(suggestion.locality ?? "") \(suggestion.subLocality ?? "") \(suggestion.administrativeArea ?? "") \(suggestion.postalCode ?? "") \(suggestion.country ?? "")"
        
        return cell
    }

}
