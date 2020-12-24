//
//  LocationManager.swift
//  Places
//
//  Created by John Kouris on 12/22/20.
//

import Foundation
import MapKit

class LocationManager: NSObject {
    static let shared = LocationManager()
    var locationManager = CLLocationManager()
    var onLocationUpdate: ((CLLocation) -> Void)?
    
    func start(completionHandler: @escaping (CLLocation) -> Void) {
        locationManager.requestWhenInUseAuthorization()

        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 100.0
        locationManager.delegate = self

        locationManager.startUpdatingLocation()

        onLocationUpdate = completionHandler
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        onLocationUpdate?(newLocation)
    }
}
