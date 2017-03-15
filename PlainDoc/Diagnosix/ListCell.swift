//
//  ListCell.swift
//  Diagnosix
//
//  Created by Aron Gates on 2/28/17.
//  Copyright © 2017 Aron Gates. All rights reserved.
//

import UIKit
import FoldingCell
import MapKit

class ListCell: FoldingCell {

    @IBOutlet weak var sumAddress: UILabel!
    @IBOutlet weak var sumDate: UILabel!
    @IBOutlet weak var leftHighlight: UIView!
    @IBOutlet weak var diagnosisDate: UILabel!
    @IBOutlet weak var diagnosisLoc: UILabel!
    @IBOutlet weak var appointmentNum: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    var address: String = "" {
        didSet {
            sumAddress.text = address
            handleAddressString(address: address)
        }
    }
    
    var ID: Int = 0
    
    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        self.itemCount = 3
        
        super.awakeFromNib()
        
        proceedButton.roundedButton()
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.33, 0.26, 0.26]
        return durations[itemIndex]
    }
    
    let geocoder: CLGeocoder = CLGeocoder()
    let regionRadius: CLLocationDistance = 100
    
    func handleAddressString(address : String) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            let placemark = MKPlacemark(placemark: (placemarks?.first)!)
            self.map.addAnnotation(placemark)
            self.centerMapOnLocation(location: placemark.location!)
        }
    }
    
    fileprivate func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
             regionRadius * 2.0,
             regionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: true)
    }
    
}
