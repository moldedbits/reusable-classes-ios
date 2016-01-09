//
//  CurrentLocationScreen.swift
//  GeoLocationExample
//
//  Created by vishal singh on 06/01/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit
import MapKit

class CurrentLocationScreen: UIViewController, GeoLocationDelegate {
    
    private var map: MKMapView!
    
    private var screenHeight, screenWidth: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeoLocation.shared.delegate = self
        screenHeight = view.frame.height
        screenWidth = view.frame.width
        
        setupMap()
        setupButton()
    }
    
    override func viewWillLayoutSubviews() {
        map.frame = view.frame
    }
    
    private func setupMap() {
        map = MKMapView(frame: view.frame)
        view.addSubview(map)
    }
    
    private func setupButton() {
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
        GeoLocation.shared.accuracy = kCLLocationAccuracyNearestTenMeters
        GeoLocation.shared.getCurrentLocation()
    }
    
    func addAnnotationOnLocationCoordinate(coordinates: CLLocationCoordinate2D) {
        if let annotations = map.annotations as? [LocationAnnotation] {
            for annotation in annotations {
                if annotation.coordinate.latitude == coordinates.latitude && annotation.coordinate.longitude == coordinates.longitude {
                    return
                }
            }
        }
        map.removeAnnotations(map.annotations)
        map.addAnnotation(LocationAnnotation(coordinate: coordinates, name: "Current Location", info: nil))
    }
    
    //MARK: - GeoLocation delegates
    
    func geoLocationDidUpdateCurrentLocations(locations: [CLLocation]?, withError error: NSError?) {
        if let updatedLocation = locations?.last {
            addAnnotationOnLocationCoordinate(updatedLocation.coordinate)
        } else if let errorOccured = error {
            displayError(errorOccured)
        }
    }

    //MARK: - Map view delegates
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
