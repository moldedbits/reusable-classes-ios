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
        var APIURLString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(address)" as NSString?
        APIURLString = APIURLString?.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        let APIURL = NSURL(string: APIURLString as! String)
        let APIURLRequest = NSURLRequest(URL: APIURL!)
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(APIURLRequest) { data, response, error -> Void in
//            if error != nil {
//                self.delegate?.geoLocationDidFindPlacemarks?(nil, withError: error, forAddressString: address, inRegion: nil)
//            } else {
//                if data != nil {
//                    let jsonResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
//                    let (errorJSON, noResults) = self.validateGoogleJSONResponse(jsonResult)
//                    if noResults == true { // request is ok but not results are returned
//                        let errorNoResult = NSError(domain: "No results found", code: 0, userInfo: nil)
//                        self.delegate?.geoLocationDidFindPlacemarks?(nil, withError: errorNoResult, forAddressString: address, inRegion: nil)
//                    } else if (errorJSON != nil) { // something went wrong with request
//                        self.delegate?.geoLocationDidFindPlacemarks?(nil, withError: error, forAddressString: address, inRegion: nil)
//                    } else { // we have some good results to show
//                        let address1 = SwiftLocationParser()
//                        address1.parseGoogleLocationData(jsonResult)
//                        let placemark = address1.getPlacemark()
//                        self.delegate?.geoLocationDidFindPlacemarks?([placemark], withError: nil, forAddressString: address, inRegion: nil)
//                    }
//                }
//            }
//        }
//        task.resume()

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
                        let address1 = SwiftLocationParser()
                        address1.parseGoogleLocationData(jsonResult)
                        let placemark = address1.getPlacemark()
                        self.delegate?.geoLocationDidFindPlacemarks?([placemark], withError: nil, forAddressString: address, inRegion: nil)
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
        var APIURLString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinates.latitude),\(coordinates.longitude)" as NSString?
        APIURLString = APIURLString?.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        let APIURL = NSURL(string: APIURLString as! String)
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
                        let address = SwiftLocationParser()
                        address.parseGoogleLocationData(jsonResult)
                        let placemark = address.getPlacemark()
                        self.delegate?.geoLocationDidFindPlacemarks?([placemark], withError: nil, forCoordinates: coordinates)
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


private class SwiftLocationParser: NSObject {
    private var latitude = NSString()
    private var longitude  = NSString()
    private var streetNumber = NSString()
    private var route = NSString()
    private var locality = NSString()
    private var subLocality = NSString()
    private var formattedAddress = NSString()
    private var administrativeArea = NSString()
    private var administrativeAreaCode = NSString()
    private var subAdministrativeArea = NSString()
    private var postalCode = NSString()
    private var country = NSString()
    private var subThoroughfare = NSString()
    private var thoroughfare = NSString()
    private var ISOcountryCode = NSString()
    private var state = NSString()
    
    override init() {
        super.init()
    }
    
    private func parseIPLocationData(JSON: NSDictionary) -> Bool {
        let status = JSON["status"] as? String
        if status != "success" {
            return false
        }
        self.country = JSON["country"] as! NSString
        self.ISOcountryCode = JSON["countryCode"] as! NSString
        if let lat = JSON["lat"] as? NSNumber, lon = JSON["lon"] as? NSNumber {
            self.longitude = lat.description
            self.latitude = lon.description
        }
        self.postalCode = JSON["zip"] as! NSString
        return true
    }
    
    private func parseAppleLocationData(placemark:CLPlacemark) {
        let addressLines = placemark.addressDictionary?["FormattedAddressLines"] as! NSArray
        
        //self.streetNumber = placemark.subThoroughfare ? placemark.subThoroughfare : ""
        self.streetNumber = placemark.thoroughfare ?? ""
        self.locality = placemark.locality ?? ""
        self.postalCode = placemark.postalCode ?? ""
        self.subLocality = placemark.subLocality ?? ""
        self.administrativeArea = placemark.administrativeArea ?? ""
        self.country = placemark.country ?? ""
        if let location = placemark.location {
            self.longitude = location.coordinate.longitude.description;
            self.latitude = location.coordinate.latitude.description
        }
        if addressLines.count>0 {
            self.formattedAddress = addressLines.componentsJoinedByString(", ")
        } else {
            self.formattedAddress = ""
        }
    }
    
    private func parseGoogleLocationData(resultDict:NSDictionary) {
        let locationDict = (resultDict.valueForKey("results") as! NSArray).firstObject as! NSDictionary
        let formattedAddrs = locationDict.objectForKey("formatted_address") as! NSString
        
        let geometry = locationDict.objectForKey("geometry") as! NSDictionary
        let location = geometry.objectForKey("location") as! NSDictionary
        let lat = location.objectForKey("lat") as! Double
        let lng = location.objectForKey("lng") as! Double
        
        self.latitude = lat.description
        self.longitude = lng.description
        
        let addressComponents = locationDict.objectForKey("address_components") as! NSArray
        self.subThoroughfare = component("street_number", inArray: addressComponents, ofType: "long_name")
        self.thoroughfare = component("route", inArray: addressComponents, ofType: "long_name")
        self.streetNumber = self.subThoroughfare
        self.locality = component("locality", inArray: addressComponents, ofType: "long_name")
        self.postalCode = component("postal_code", inArray: addressComponents, ofType: "long_name")
        self.route = component("route", inArray: addressComponents, ofType: "long_name")
        self.subLocality = component("subLocality", inArray: addressComponents, ofType: "long_name")
        self.administrativeArea = component("administrative_area_level_1", inArray: addressComponents, ofType: "long_name")
        self.administrativeAreaCode = component("administrative_area_level_1", inArray: addressComponents, ofType: "short_name")
        self.subAdministrativeArea = component("administrative_area_level_2", inArray: addressComponents, ofType: "long_name")
        self.country =  component("country", inArray: addressComponents, ofType: "long_name")
        self.ISOcountryCode =  component("country", inArray: addressComponents, ofType: "short_name")
        self.formattedAddress = formattedAddrs;
    }
    
    private func getPlacemark() -> CLPlacemark {
        var addressDict = [String:AnyObject]()
        let formattedAddressArray = self.formattedAddress.componentsSeparatedByString(", ") as Array
        
        let kSubAdministrativeArea = "SubAdministrativeArea"
        let kSubLocality           = "SubLocality"
        let kState                 = "State"
        let kStreet                = "Street"
        let kThoroughfare          = "Thoroughfare"
        let kFormattedAddressLines = "FormattedAddressLines"
        let kSubThoroughfare       = "SubThoroughfare"
        let kPostCodeExtension     = "PostCodeExtension"
        let kCity                  = "City"
        let kZIP                   = "ZIP"
        let kCountry               = "Country"
        let kCountryCode           = "CountryCode"
        
        addressDict[kSubAdministrativeArea] = self.subAdministrativeArea
        addressDict[kSubLocality] = self.subLocality
        addressDict[kState] = self.administrativeAreaCode
        addressDict[kStreet] = formattedAddressArray.first! as NSString
        addressDict[kThoroughfare] = self.thoroughfare
        addressDict[kFormattedAddressLines] = formattedAddressArray
        addressDict[kSubThoroughfare] = self.subThoroughfare
        addressDict[kPostCodeExtension] = ""
        addressDict[kCity] = self.locality
        addressDict[kZIP] = self.postalCode
        addressDict[kCountry] = self.country
        addressDict[kCountryCode] = self.ISOcountryCode
        
        let lat = self.latitude.doubleValue
        let lng = self.longitude.doubleValue
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)

        return (placemark as CLPlacemark)
    }
    
    private func component(component:NSString,inArray:NSArray,ofType:NSString) -> NSString {
        let index:NSInteger = inArray.indexOfObjectPassingTest { (obj, idx, stop) -> Bool in
            
            let objDict:NSDictionary = obj as! NSDictionary
            let types:NSArray = objDict.objectForKey("types") as! NSArray
            let type = types.firstObject as! NSString
            return type.isEqualToString(component as String)
        }
        
        if index == NSNotFound {
            return ""
        }
        
        if index >= inArray.count {
            return ""
        }
        
        let type = ((inArray.objectAtIndex(index) as! NSDictionary).valueForKey(ofType as String)!) as! NSString
        
        if type.length > 0 {
            
            return type
        }
        return ""
    }
}