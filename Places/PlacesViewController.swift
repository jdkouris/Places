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
    
    var places = [[String: Any]]()
    var isQueryPending = false
    let locationManager = LocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        locationManager.start { location in
            self.centerMapView(on: location)
            self.queryFoursquare(with: location)
        }
    }
    
    func centerMapView(on location: CLLocation) {
        guard mapView != nil else { return }

        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        let adjustedRegion = mapView!.regionThatFits(region)

        mapView!.setRegion(adjustedRegion, animated: true)
    }
    
    func queryFoursquare(with location: CLLocation) {
        FoursquareAPI.shared.query(location: location) { (places) in
            self.places = places
            self.updatePlaces()
            self.tableView.reloadData()
        }
    }
    
    private func updatePlaces() {
        guard mapView != nil else { return }
        
        mapView!.removeAnnotations(mapView!.annotations)
        
        for place in places {
            if let name = place["name"] as? String,
               let latitude = place["latitude"] as? CLLocationDegrees,
               let longitude = place["longitude"] as? CLLocationDegrees {
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = name
                mapView.addAnnotation(annotation)
            }
        }
    }

}

extension PlacesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
        
        cell.textLabel?.text = places[indexPath.row]["name"] as? String
        cell.detailTextLabel?.text = places[indexPath.row]["address"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard mapView != nil else { return }
        
        guard let tappedName = places[indexPath.row]["name"] as? String else { return }
        
        for annotation in mapView.annotations {
            mapView.deselectAnnotation(annotation, animated: true)
            
            if tappedName == annotation.title {
                mapView.selectAnnotation(annotation, animated: true)
                mapView.setCenter(annotation.coordinate, animated: true)
            }
        }
    }
}

extension PlacesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        
        return view
    }
}
