//
//  ForwardGeocodingScreen.swift
//  GeoLocationExample
//
//  Created by vishal singh on 06/01/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit
import MapKit

class ForwardGeocodingScreen: UIViewController {

    private var map: MKMapView!
    
    private var geoLocation = GeoLocation.shared
    private var screenHeight, screenWidth: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenHeight = view.frame.height
        screenWidth = view.frame.width
        
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
        let currentLocationButton = UIButton(type: .Custom)
        currentLocationButton.frame = CGRectMake(screenWidth * 0.8, screenHeight * 0.1, 50, screenHeight * 0.1)
        currentLocationButton.backgroundColor = UIColor.lightGrayColor()
        view.addSubview(currentLocationButton)
        currentLocationButton.addTarget(self, action: Selector("gotoCurrentLocation"), forControlEvents: .TouchUpInside)
        
        let goBackButton = UIButton(type: .Custom)
        goBackButton.frame = CGRectMake(30, screenHeight * 0.8, 50, screenHeight * 0.1)
        goBackButton.backgroundColor = UIColor.lightGrayColor()
        view.addSubview(goBackButton)
        goBackButton.addTarget(self, action: Selector("dismissScreen"), forControlEvents: .TouchUpInside)
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
    
    func dismissScreen() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Map view delegates
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? LocationAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
}
