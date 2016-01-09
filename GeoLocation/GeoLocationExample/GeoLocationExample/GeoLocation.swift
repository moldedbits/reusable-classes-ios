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

public enum MapService: Int {
    case Apple, Google
}

class GeoLocation: NSObject, CLLocationManagerDelegate, UIAlertViewDelegate {
    
    static let shared = GeoLocation()
    
    private var manager: CLLocationManager!
    private let geocoder = CLGeocoder()
    private let blocksDispatchQueue = dispatch_queue_create("SynchronizedArrayAccess", DISPATCH_QUEUE_SERIAL)
    
    var accuracy = kCLLocationAccuracyBest
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
    
    func getCurrentLocation() {
        manager.requestLocation()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        manager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        manager.stopMonitoringSignificantLocationChanges()
    }
    
    func startMonitoringForRegion(region: CLRegion) {
        manager.startMonitoringForRegion(region)
    }
    
    func stopMonitoringForRegion(region: CLRegion) {
        manager.stopMonitoringForRegion(region)
    }
    
    func startMonitoringVisits() {
        manager.startMonitoringVisits()
    }
    
    func stopMonitoringVisits() {
        manager.stopMonitoringVisits()
    }
    
    func startRangingBeaconsInRegion(region: CLBeaconRegion) {
        manager.startRangingBeaconsInRegion(region)
    }
    
    func stopRangingBeaconsInRegion(region: CLBeaconRegion) {
        manager.stopRangingBeaconsInRegion(region)
    }

    func startUpdatingHeading() {
        manager.startUpdatingHeading()
    }
    
    func stopUpdatingHeading() {
        manager.stopUpdatingHeading()
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
        delegate?.geoLocationDidUpdateCurrentLocations?([newLocation], withError: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.geoLocationDidUpdateCurrentLocations?(locations, withError: nil)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        delegate?.geoLocationDidUpdateCurrentLocations?(nil, withError: error)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
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
        var APIURLString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)" as NSString
        APIURLString = APIURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let APIURL = NSURL(string: APIURLString as String)
        let APIURLRequest = NSURLRequest(URL: APIURL!)
        NSURLConnection.sendAsynchronousRequest(APIURLRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) in
            if error != nil {
                self.delegate?.geoLocationDidFindPlacemarks?(nil, withError: error, forAddressString: address, inRegion: nil)
            } else {
                if data != nil {
                    let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                    let (error,noResults) = self.validateGoogleJSONResponse(jsonResult)
                    if noResults == true { // request is ok but not results are returned
                        let errorNoResult = NSError(domain: "No results found", code: 0, userInfo: nil)
                        self.delegate?.geoLocationDidFindPlacemarks?(nil, withError: errorNoResult, forAddressString: address, inRegion: nil)
                    } else if (error != nil) { // something went wrong with request
                        self.delegate?.geoLocationDidFindPlacemarks?(nil, withError: error, forAddressString: address, inRegion: nil)
                    } else { // we have some good results to show
                        print(jsonResult)
                    }
                }
            }
        }
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
        var APIURLString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinates.latitude),\(coordinates.longitude)" as NSString
        APIURLString = APIURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let APIURL = NSURL(string: APIURLString as String)
        let APIURLRequest = NSURLRequest(URL: APIURL!)
        NSURLConnection.sendAsynchronousRequest(APIURLRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) in
            if error != nil {
                self.delegate?.geoLocationDidFindPlacemarks?(nil, withError: error, forCoordinates: coordinates)
            } else {
                if data != nil {
                    let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                    let (error,noResults) = self.validateGoogleJSONResponse(jsonResult)
                    if noResults == true { // request is ok but not results are returned
                        let errorNoResult = NSError(domain: "No results found", code: 0, userInfo: nil)
                        self.delegate?.geoLocationDidFindPlacemarks?(nil, withError: errorNoResult, forCoordinates: coordinates)
                    } else if (error != nil) { // something went wrong with request
                        self.delegate?.geoLocationDidFindPlacemarks?(nil, withError: error, forCoordinates: coordinates)
                    } else { // we have some good results to show
                        print(jsonResult)
                    }
                }
            }
        }

    }
    
    private func validateGoogleJSONResponse(jsonResult: NSDictionary!) -> (error: NSError?, noResults: Bool!) {
        var status = jsonResult.valueForKey("status") as! NSString
        status = status.lowercaseString
        if status.isEqualToString("ok") == true { // everything is fine, the sun is shining and we have results!
            return (nil,false)
        } else if status.isEqualToString("zero_results") == true { // No results error
            return (nil,true)
        } else if status.isEqualToString("over_query_limit") == true { // Quota limit was excedeed
            let message	= "Query quota limit was exceeded"
            return (NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : message]),false)
        } else if status.isEqualToString("request_denied") == true { // Request was denied
            let message	= "Request denied"
            return (NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : message]),false)
        } else if status.isEqualToString("invalid_request") == true { // Invalid parameters
            let message	= "Invalid input sent"
            return (NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : message]),false)
        }
        return (nil,false) // okay!
    }

}

@objc public protocol GeoLocationDelegate: NSObjectProtocol {
    optional func geoLocationDidUpdateCurrentLocations(locations: [CLLocation]?, withError error: NSError?)
    optional func geoLocationDidFindPlacemarks(placemarks: [CLPlacemark]?, withError error: NSError?, forAddressString address: String, inRegion region: CLRegion?)
    optional func geoLocationDidFindPlacemarks(placemarks: [CLPlacemark]?, withError error: NSError?, forCoordinates coordinates: CLLocationCoordinate2D)
}
