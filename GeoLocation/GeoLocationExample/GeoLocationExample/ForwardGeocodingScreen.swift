//
//  ForwardGeocodingScreen.swift
//  GeoLocationExample
//
//  Created by vishal singh on 06/01/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit
import MapKit

class ForwardGeocodingScreen: UIViewController, UISearchBarDelegate, GeoLocationDelegate {

    private var map: MKMapView!
    private var screenHeight, screenWidth: CGFloat!

    private let searchBar = UISearchBar()
    private var serviceType: MapService!
    
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
        setupButtons()
        setupSearchBar()
        setupSwitch()
        let tap = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard:"))
        view.addGestureRecognizer(tap)
    }
    
    private func setupButtons() {
        let currentLocationButton = UIButton(type: .DetailDisclosure)
        currentLocationButton.frame = CGRectMake(screenWidth * 0.8, screenHeight * 0.8, 50, screenHeight * 0.1)
        currentLocationButton.backgroundColor = UIColor.clearColor()
        view.addSubview(currentLocationButton)
        currentLocationButton.addTarget(self, action: Selector("searchAddress"), forControlEvents: .TouchUpInside)
        
        let goBackButton = UIButton(type: .Custom)
        goBackButton.frame = CGRectMake(30, screenHeight * 0.8, 50, screenHeight * 0.1)
        goBackButton.backgroundColor = UIColor.lightGrayColor()
        view.addSubview(goBackButton)
        goBackButton.addTarget(self, action: Selector("dismissScreen"), forControlEvents: .TouchUpInside)
    }
    
    private func setupSearchBar() {
        searchBar.frame = CGRectMake(0, screenHeight / 2 + 10.0, screenWidth, 40)
        view.addSubview(searchBar)
        searchBar.placeholder = "Look for a place"
        searchBar.delegate = self
    }
    
    private func setupSwitch() {
        let serviceSwitch = UISwitch(frame: CGRectMake(screenWidth * 0.45, screenHeight * 0.7, screenWidth * 0.2, screenHeight * 0.2))
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
    
    func searchAddress() {
        GeoLocation.shared.findPlacemarksForAddress(searchBar.text!, inRegion: nil, service: serviceType)
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
    
    //MARK: - Search Bar delegates
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchAddress()
    }

    //MARK: - GeoLocation Delegate
    
    func geoLocationDidFindPlacemarks(placemarks: [CLPlacemark]?, withError error: NSError?, forAddressString address: String, inRegion region: CLRegion?) {
        if let foundPlacemarks = placemarks {
            for foundPlacemark in foundPlacemarks {
                addAnnotationOnLocationCoordinate((foundPlacemark.location?.coordinate)!, name: (foundPlacemark.addressDictionary!["FormattedAddressLines"])?.componentsJoinedByString(", "), info: nil)
            }
        } else if let errorOccured = error {
            displayError(errorOccured)
        }
    }
}
