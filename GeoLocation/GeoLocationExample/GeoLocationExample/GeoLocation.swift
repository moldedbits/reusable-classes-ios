//
//  GeoLocation.swift
//  GeoLocationExample
//
//  Created by vishal singh on 31/12/15.
//  Copyright © 2015 moldedbits. All rights reserved.
//


import UIKit
import CoreLocation
import MapKit

enum MapService: Int {
    case Apple, Google
}

class GeoLocation: NSObject, CLLocationManagerDelegate, UIAlertViewDelegate {
    
    static let shared = GeoLocation()
    
    private var manager: CLLocationManager!
    private var locations = [CLLocation]()
    private let geocoder = CLGeocoder()
    
    var accuracy = kCLLocationAccuracyThreeKilometers

    var delegate: GeoLocationDelegate?
    
    override private init() {
        manager = CLLocationManager()
        
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = self.accuracy
        manager.stopUpdatingLocation()
    }
    
    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }
    
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    func getCurrentLocation() {
        manager.requestLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        manager.startMonitoringSignificantLocationChanges()
    }
    
    private func checkLocationServices() {
        if !CLLocationManager.locationServicesEnabled() {
            requestToEnableLocationServices()
        } else {
            if (CLLocationManager.authorizationStatus() == .AuthorizedAlways) || (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse) {

            } else if (CLLocationManager.authorizationStatus() == .Denied) || (CLLocationManager.authorizationStatus() == .NotDetermined){
                askToChangeSettings()
            }
        }
    }
    
    private func requestToEnableLocationServices() {
        let locationServicesAlert = UIAlertView(title: "Location Service Is Off!", message: "Would you like to turn on location services?", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "Go to Settings")
        locationServicesAlert.tag = 1
        locationServicesAlert.show()
    }
    
    private func askToChangeSettings() {
        let permissionAlert = UIAlertView(title: "Location Permission Denied!", message: "Would you like to change the settings now?", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "Yes, go to Settings")
        permissionAlert.tag = 2
        permissionAlert.show()
    }
    
    // MARK: - AlertView Delegates
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex > 0 {
            gotoPhoneSettings()
        }
        alertView.dismissWithClickedButtonIndex(0, animated: true)
    }
    
    private func gotoPhoneSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    // MARK: - Location Manager Delegates
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        locations.append(newLocation)
        delegate?.geoLocationDidUpdateCurrentLocations?(locations, withError: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations.append(locations.last!)
        delegate?.geoLocationDidUpdateCurrentLocations?(locations, withError: nil)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        delegate?.geoLocationDidUpdateCurrentLocations?(nil, withError: error)
    }
}

extension GeoLocation {

    //MARK: - Forward Geocoding
    func findPlacemarksForAddress(address: String, inRegion region: CLRegion?, service: MapService) {
        switch service {
            case .Apple: return applePlacemarkForAddress(address, inRegion: region)
            case .Google: return googlePlacemarkForAddress(address)
        }
    }
    
    private func applePlacemarkForAddress(address: String, inRegion region: CLRegion?) {
        geocoder.geocodeAddressString(address, inRegion: region, completionHandler: { (placemarks, error) in
                self.delegate?.geoLocationDidFindPlacemarks?(placemarks, withError: error, forAddressString: address, inRegion: region)
        })
    }
    
    private func googlePlacemarkForAddress(address: String) {
        
    }
}

extension GeoLocation {
    
    //MARK:- Reverse Geocoding
    func findPlacemarkForCoordinates(coordinates: CLLocationCoordinate2D, service: MapService) {
        switch service {
            case .Apple: applePlacemarkForCoordinates(coordinates)
            case .Google: googlePlacemarkForCoordinates(coordinates)
        }
    }
    
    private func applePlacemarkForCoordinates(coordinates: CLLocationCoordinate2D) {
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude), completionHandler: { (placemarks, error) in
            self.delegate?.geoLocationDidFindPlacemarks?(placemarks, withError: error, forCoordinates: coordinates)
        })
    }
    
    private func googlePlacemarkForCoordinates(coordinates: CLLocationCoordinate2D) {
        
    }
}

@objc public protocol GeoLocationDelegate: NSObjectProtocol {
    optional func geoLocationDidUpdateCurrentLocations(locations: [CLLocation]?, withError error: NSError?)
    optional func geoLocationDidFindPlacemarks(placemarks: [CLPlacemark]?, withError error: NSError?, forAddressString address: String, inRegion region: CLRegion?)
    optional func geoLocationDidFindPlacemarks(placemarks: [CLPlacemark]?, withError error: NSError?, forCoordinates coordinates: CLLocationCoordinate2D)
}
