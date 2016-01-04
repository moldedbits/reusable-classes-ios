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

class GeoLocation: NSObject, CLLocationManagerDelegate, UIAlertViewDelegate {
    
    static let shared = GeoLocation()
    
    private var manager: CLLocationManager!
    private var locations: [CLLocation]
    
    override private init() {
        manager = CLLocationManager()
        locations = [CLLocation(latitude: 28.6139, longitude: 77.2090)]
        
        super.init()
        
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        checkLocationServices()
    }
    
    func startUpdatingLocation() {
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    func currentLocation() -> CLLocation {
        checkLocationServices()
        return locations.last!
    }
    
    private func checkLocationServices() {
        if !CLLocationManager.locationServicesEnabled() {
            requestToEnableLocationServices()
        } else {
            if (CLLocationManager.authorizationStatus() == .AuthorizedAlways) || (CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse) {
                startUpdatingLocation()
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
    }
}
