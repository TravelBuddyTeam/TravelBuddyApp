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
    MKMapViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager : CLLocationManager!
    var lastLocation : CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        searchBar.delegate = self

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.requestWhenInUseAuthorization()
        
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
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        
        // find location on map
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // set to show cancel button
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }

}
