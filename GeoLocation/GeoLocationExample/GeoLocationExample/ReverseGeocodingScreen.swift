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
    private var serviceType: MapService!
    
    private let longitudeTextField = UITextField()
    private let latitudeTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeoLocation.shared.delegate = self
        
        screenHeight = view.frame.height
        screenWidth = view.frame.width
        view.backgroundColor = UIColor.whiteColor()
        
        setupMap()
        setupView()
    }
    
    private func setupMap() {
        map = MKMapView(frame: CGRectMake(0, 0, screenWidth, screenHeight / 2))
        view.addSubview(map)
    }
    
    private func setupView() {
        addTextFields()
        setupButtons()
        setupSwitch()
        let tap = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard:"))
        view.addGestureRecognizer(tap)
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
    
    private func setupButtons() {
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
    
    private func setupSwitch() {
        let serviceSwitch = UISwitch(frame: CGRectMake(screenWidth * 0.4, screenHeight * 0.7, screenWidth * 0.2, screenHeight * 0.2))
        serviceSwitch.addTarget(self, action: Selector("serviceSwitchValueChanged:"), forControlEvents: .ValueChanged)
        view.addSubview(serviceSwitch)
        serviceType = .Apple
    }
    
    func serviceSwitchValueChanged(sender: UISwitch) {
        if !sender.on {
            serviceType = .Apple
            view.backgroundColor = UIColor.whiteColor()
        } else {
            serviceType = .Google
            view.backgroundColor = UIColor.blueColor()
        }
    }
    
    func findPlacemarkForCoordinates() {
        GeoLocation.shared.findPlacemarkForCoordinates(CLLocationCoordinate2D(latitude: Double(latitudeTextField.text!)!, longitude: Double(longitudeTextField.text!)!), service: serviceType)
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
                addAnnotationOnLocationCoordinate((foundPlacemark.location?.coordinate)!, name: (foundPlacemark.addressDictionary!["FormattedAddressLines"])?.componentsJoinedByString(", "), info: nil)
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
}
