//
//  PlacesViewController.swift
//  Places
//
//  Created by John Kouris on 12/22/20.
//

import UIKit
import MapKit

class PlacesViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.distanceFilter = 50.0
        
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
    }


}

extension PlacesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard mapView != nil else { return }
        guard let newLocation = locations.last else { return }
        
        let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        let adjustedRegion = mapView.regionThatFits(region)
        mapView.setRegion(adjustedRegion, animated: true)
    }
}
