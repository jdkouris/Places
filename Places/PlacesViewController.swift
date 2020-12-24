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
    
    var places = [[String: Any]]()
    var isQueryPending = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.distanceFilter = 100.0
        
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
        
        mapView?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func queryFoursquare(location: CLLocation) {
        if isQueryPending { return }
        isQueryPending = true
        
        let clientId        = URLQueryItem(name: "client_id", value: Keys.clientID)
        let clientSecret    = URLQueryItem(name: "client_secret", value: Keys.clientSecret)
        let version         = URLQueryItem(name: "v", value: "20190401")
        let coordinate      = URLQueryItem(name: "ll", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
        let query           = URLQueryItem(name: "query", value: "gym")
        let intent          = URLQueryItem(name: "intent", value: "browse")
        let radius          = URLQueryItem(name: "radius", value: "250")
        
        var urlComponents = URLComponents(string: "https://api.foursquare.com/v2/venues/search")!
        urlComponents.queryItems = [clientId, clientSecret, version, coordinate, query, intent, radius]
        
        let task = URLSession.shared.dataTask(with: urlComponents.url!) { (data, response, error) in
            defer {
                self.isQueryPending = false
            }
            
            if error != nil {
                print("***** ERROR ***** \(error!.localizedDescription)")
                return
            }
            
            if data == nil || response == nil {
                print("***** SOMETHING WENT WRONG *****")
                return
            }
            
            self.places.removeAll()
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: [])
                
                if let jsonObject = jsonData as? [String: Any],
                   let response = jsonObject["response"] as? [String: Any],
                   let venues = response["venues"] as? [[String: Any]] {
                    
                    for venue in venues {
                        if let name = venue["name"] as? String,
                           let location = venue["location"] as? [String: Any],
                           let latitude = location["lat"] as? Double,
                           let longitude = location["lng"] as? Double,
                           let formattedAddress = location["formattedAddress"] as? [String] {
                            
                            self.places.append([
                                "name": name,
                                "address": formattedAddress.joined(separator: " "),
                                "latitude": latitude,
                                "longitude": longitude
                            ])
                        }
                    }
                }
            } catch {
                print("*** JSON ERROR *** \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.updatePlaces()
                self.tableView.reloadData()
            }
        }
        task.resume()
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

extension PlacesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard mapView != nil else { return }
        guard let newLocation = locations.last else { return }
        
        let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        let adjustedRegion = mapView.regionThatFits(region)
        mapView.setRegion(adjustedRegion, animated: true)
        
        queryFoursquare(location: newLocation)
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
