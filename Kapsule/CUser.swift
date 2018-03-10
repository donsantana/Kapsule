//
//  CUser.swift
//  Kapsule
//
//  Created by Done Santana on 3/7/18.
//  Copyright © 2018 Done Santana. All rights reserved.
//

import Foundation
import CoreLocation

class CUser {
    var name:String
    var email:String
    var location:CLLocationCoordinate2D

    init(name:String, email:String) {
        self.name = name
        self.email = email
        self.location = CLLocationCoordinate2D()
    }
    
    func updateLocation(newLocation:CLLocationCoordinate2D) {
        self.location = newLocation
    }
}
