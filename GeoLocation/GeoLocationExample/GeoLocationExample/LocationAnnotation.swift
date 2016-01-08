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
    let title: String?
    let subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, name: String?, info: String?) {
        self.coordinate = coordinate
        self.title = name
        self.subtitle = info
    }
}