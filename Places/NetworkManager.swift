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
    
    func queryFoursquare(location: CLLocation) {
        if isQueryPending { return }
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
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: [])
                print(jsonData)
            } catch {
                print("*** JSON ERROR *** \(error.localizedDescription)")
                return
            }
            
        }
        task.resume()
    }
}
