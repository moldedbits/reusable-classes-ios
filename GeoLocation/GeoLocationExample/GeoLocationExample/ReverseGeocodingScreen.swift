//
//  ReverseGeocodingScreen.swift
//  GeoLocationExample
//
//  Created by vishal singh on 06/01/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit
import MapKit

class ReverseGeocodingScreen: UIViewController, UITextFieldDelegate, GeoLocationDelegate {

    private var map: MKMapView!
    
    private var screenHeight, screenWidth: CGFloat!
    
    private let longitudeTextField = UITextField()
    private let latitudeTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeoLocation.shared.delegate = self
        
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
        addTextFields()
        addButtons()
    }

    private func addTextFields() {

        longitudeTextField.frame = CGRectMake(screenWidth * 0.1, screenHeight * 0.6, screenWidth * 0.3, screenHeight * 0.05)
        latitudeTextField.frame = CGRectMake(screenWidth * 0.6, screenHeight * 0.6, screenWidth * 0.3, screenHeight * 0.05)
        
        latitudeTextField.layer.cornerRadius = 5
        longitudeTextField.layer.cornerRadius = 5
        
        latitudeTextField.backgroundColor = UIColor.whiteColor()
        longitudeTextField.backgroundColor = UIColor.whiteColor()
        
        longitudeTextField.placeholder = "Longitude"
        latitudeTextField.placeholder = "Latitude"
        
        longitudeTextField.delegate = self
        latitudeTextField.delegate = self
        
        longitudeTextField.keyboardType = .NumberPad
        latitudeTextField.keyboardType = .NumberPad
        
        view.addSubview(longitudeTextField)
        view.addSubview(latitudeTextField)
    }
    
    private func addButtons() {
        let currentLocationButton = UIButton(type: .DetailDisclosure)
        currentLocationButton.frame = CGRectMake(screenWidth * 0.8, screenHeight * 0.8, 50, screenHeight * 0.1)
        currentLocationButton.backgroundColor = UIColor.clearColor()
        view.addSubview(currentLocationButton)
        currentLocationButton.addTarget(self, action: Selector("findPlacemarkForCoordinates"), forControlEvents: .TouchUpInside)
        
        let goBackButton = UIButton(type: .Custom)
        goBackButton.frame = CGRectMake(30, screenHeight * 0.8, 50, screenHeight * 0.1)
        goBackButton.backgroundColor = UIColor.lightGrayColor()
        view.addSubview(goBackButton)
        goBackButton.addTarget(self, action: Selector("dismissScreen"), forControlEvents: .TouchUpInside)
    }
    
    func findPlacemarkForCoordinates() {
        GeoLocation.shared.findPlacemarkForCoordinates(CLLocationCoordinate2D(latitude: Double(latitudeTextField.text!)!, longitude: Double(longitudeTextField.text!)!), service: .Google)
    }

    private func addAnnotationOnLocationCoordinate(coordinates: CLLocationCoordinate2D, name: String?, info: String?) {
        if let annotations = map.annotations as? [LocationAnnotation] {
            for annotation in annotations {
                if annotation.coordinate.latitude == coordinates.latitude && annotation.coordinate.longitude == coordinates.longitude {
                    return
                }
            }
        }
        map.addAnnotation(LocationAnnotation(coordinate: coordinates, name: name, info: info))
    }
    
    //MARK: - Geolocation Delegates
    
    func geoLocationDidFindPlacemarks(placemarks: [CLPlacemark]?, withError error: NSError?, forCoordinates coordinates: CLLocationCoordinate2D) {
        if let foundPlacemarks = placemarks {
            for foundPlacemark in foundPlacemarks {
                addAnnotationOnLocationCoordinate((foundPlacemark.location?.coordinate)!, name: foundPlacemark.name, info: foundPlacemark.administrativeArea)
            }
        } else if let errorOccured = error {
            displayError(errorOccured)
        }
    }
    
    //MARK: - TextField delegates
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
