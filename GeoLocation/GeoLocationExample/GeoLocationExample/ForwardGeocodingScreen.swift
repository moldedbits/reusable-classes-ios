//
//  ForwardGeocodingScreen.swift
//  GeoLocationExample
//
//  Created by vishal singh on 06/01/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit
import MapKit

class ForwardGeocodingScreen: UIViewController, UISearchBarDelegate {

    private var map: MKMapView!
    
    private var screenHeight, screenWidth: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenHeight = view.frame.height
        screenWidth = view.frame.width
        view.backgroundColor = UIColor.blueColor()
        
        setupMap()
        setupView()
    }
    
    private func setupMap() {
        map = MKMapView(frame: CGRectMake(0, 0, screenWidth, screenHeight / 2))
        view.addSubview(map)
    }
    
    private func setupView() {
        let searchBar = UISearchBar(frame: CGRectMake(0, screenHeight / 2 + 10.0, screenWidth, 40))
        view.addSubview(searchBar)
        searchBar.placeholder = "Look for a place"
        searchBar.delegate = self
    }
    
    func addAnnotationOnLocationCoordinate(coordinates: CLLocationCoordinate2D) {
        if let annotations = map.annotations as? [LocationAnnotation] {
            for annotation in annotations {
                if annotation.coordinate.latitude == coordinates.latitude && annotation.coordinate.longitude == coordinates.longitude {
                    return
                }
            }
        }
        map.addAnnotation(LocationAnnotation(coordinate: coordinates))
    }
    
    func dismissScreen() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Search Bar delegates
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        map.removeAnnotations(map.annotations)
        let foundPlacemark = GeoLocation.shared.placemarksForAddress(searchText, service: .Apple).0?.first

        if foundPlacemark != nil {
            addAnnotationOnLocationCoordinate((foundPlacemark?.location?.coordinate)!)
        }
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
