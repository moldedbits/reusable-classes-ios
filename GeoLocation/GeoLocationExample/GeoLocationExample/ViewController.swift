//
//  ViewController.swift
//  GeoLocationExample
//
//  Created by vishal singh on 04/01/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    private var map: MKMapView!
    
    private var geoLocation = GeoLocation.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
        addButton()
        geoLocation.startUpdatingLocation()
    }
    
    override func viewWillLayoutSubviews() {
        map.frame = view.frame
    }
    
    private func setupMap() {
        map = MKMapView(frame: view.frame)
        view.addSubview(map)
    }
    
    private func addButton() {
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(30, 50, 100, 100)
        button.backgroundColor = UIColor.redColor()
        view.addSubview(button)
        button.addTarget(self, action: Selector("gotoCurrentLocation"), forControlEvents: .TouchUpInside)
    }
    
    func gotoCurrentLocation() {
        let currentLocation = GeoLocation.shared.currentLocation()
        //        map.setRegion(MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 5000000, 0), animated: true)
        if let annotations = map.annotations as? [LocationAnnotation] {
            for annotation in annotations {
                if annotation.coordinate.latitude == currentLocation.coordinate.latitude && annotation.coordinate.longitude == currentLocation.coordinate.longitude {
                    return
                }
            }
        }
        map.addAnnotation(LocationAnnotation(coordinate: currentLocation.coordinate))
    }
}
