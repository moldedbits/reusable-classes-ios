//
//  LocationAnnotation.swift
//  VSCoreLocationDemo
//
//  Created by vishal singh on 29/12/15.
//  Copyright © 2015 moldedbits. All rights reserved.
//

import Foundation
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}