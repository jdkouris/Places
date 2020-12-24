//
//  NetworkManager.swift
//  Places
//
//  Created by John Kouris on 12/22/20.
//

import Foundation
import MapKit

class NetworkManager {
    static let shared = NetworkManager()
    var isQueryPending = false
    var places = [[String: Any]]()
    
    func queryFoursquare(location: CLLocation) -> [[String: Any]] {
        if isQueryPending { return [] }
        isQueryPending = true
        
        let clientId        = URLQueryItem(name: "client_id", value: Keys.clientID)
        let clientSecret    = URLQueryItem(name: "client_secret", value: Keys.clientSecret)
        let version         = URLQueryItem(name: "v", value: "20190401")
        let coordinate      = URLQueryItem(name: "ll", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
        let query           = URLQueryItem(name: "query", value: "coffee")
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
        }
        task.resume()
        
        return places
    }
}
