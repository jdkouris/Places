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
    }


}

