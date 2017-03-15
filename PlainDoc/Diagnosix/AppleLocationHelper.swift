//
//  AppleLocationHelper.swift
//  Diagnosix
//
//  Created by Aron Gates on 12/18/16.
//  Copyright © 2016 Aron Gates. All rights reserved.
//

import Foundation
import MapKit

struct Typealiases {
    typealias JSONDict = [String:Any]
}

class GetLocation {
    
    let locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    func request() {
        locManager.requestWhenInUseAuthorization()
    }
    
    func getAddress(completion: @escaping (Typealiases.JSONDict) -> ()) {
        
        locManager.requestWhenInUseAuthorization()
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locManager.location
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) -> Void in
                
                if error != nil {
                    print("Error getting location: \(error)")
                } else {
                    let placeArray = placemarks as [CLPlacemark]!
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    completion(placeMark.addressDictionary as! Typealiases.JSONDict)
                }
            }
        }
    }
}
