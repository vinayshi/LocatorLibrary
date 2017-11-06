//
//  LocationManager.swift
//  Branch Locator
//
//  Created by Vinay Shivanna on 10/28/17.
//  Copyright © 2017 Vinay Shivanna. All rights reserved.
//
/**
 The purpose of the `LocationManager` is used to get the location, update locations.Can enable and disable locations
 */
import Foundation
import CoreLocation
import MapKit
import Contacts
/**
 The purpose of the `Notification` is when Location has been changed
 */
extension Notification.Name {
    public static let LocationServiceAuthorizationChanged = Notification.Name("LocationServiceAuthorizationChanged")
}

open class LocationManager: NSObject, CLLocationManagerDelegate {
    /// LocationClosure is used when location gets changed as a completion closure
    public typealias LocationClosure = ((_ location:CLLocation?,_ error: NSError?)->Void)
    /// GeoLocationClosure is used when we place the markers in the map
    typealias GeoLocationClosure = ((_ location:CLLocation?, _ placemark:CLPlacemark?,_ error: Error?)->Void)
    /// GeoLocationGoogleClosure is used when we get the custom places from Google API's
    typealias GeoLocationGoogleClosure = ((_ placemark:CustomPlacemarkModel?,_ error: Error?)->Void)
    /// LocationErrors enum to define the set of Location errors
    enum LocationErrors: String {
        case denied = "Locations are turned off. Please turn it on in Settings"
        case restricted = "Locations are restricted"
        case notDetermined = "Locations are not determined yet"
        case notFetched = "Unable to fetch location"
        case invalidLocation = "Invalid Location"
        case reverseGeocodingFailed = "Reverse Geocoding Failed"
        case geoCodingFailed = "GeoCoding Failed"
    }
    /// locationCompletionHandler is used when location is updated as a completion handler
    private var locationCompletionHandler: LocationClosure?
    /// currentLocation is used to get the current location based on the user location
    var currentLocation:CLLocation?
    /// locationManager is used to manage the location when the location changes
    var locationManager:CLLocationManager?
    /// sharedInstance is used to get same LocationManager instance in the other classes
    open static let sharedInstance: LocationManager = LocationManager()
    /// Only private initialization as we are using as a sharedInstance
    private override init() {
        // private initialization
    }
    /// Deinit will be called when Life cylce completes
    deinit {
        destroyLocationManager()
    }
    /// locationManager will be instansitiated and delegate will be set
    func setupLocationManager() {
        locationManager = nil
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    /// locationManager is instansiated
    func showTheAuthorizationAlertIfNotAuthorized() {
        locationManager = nil
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
    }
    ///locationManager will be set to nil when all operations are done
    private func destroyLocationManager() {
        locationManager?.delegate = nil
        locationManager = nil
    }
    /// didCompleteFindLocation is used when user gets the location from locationmanger
    private func didCompleteFindLocation(location: CLLocation?,error: NSError?) {
        //disableLocationManager()
        locationCompletionHandler?(location,error)
    }
    /// get curretn location and set up the location manager for the current location
    open func getCurrentLocation(completionHandler:@escaping LocationClosure) {
        locationCompletionHandler = completionHandler
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        setupLocationManager()
    }
    /// Check for the location is enabled in the device
    func isLocationEnabledInDevice()-> Bool {
        return CLLocationManager.locationServicesEnabled() && isAuthorizedToUse()
    }
    /// Check for location manager is authorized to use in the app
    func isAuthorizedToUse()->Bool{
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        }
    }
    /// Enablong the location manager to get the updated location
    open func enableLocationManager() {
        locationManager?.startUpdatingLocation()
    }
    /// disbale the location manager when location is updated
    private func disableLocationManager() {
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        locationManager = nil
    }
    /// didUpdateLocations : when location get updated
    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        didCompleteFindLocation(location: currentLocation, error: nil)
        disableLocationManager()
    }
    /// didChangeAuthorization : when location manager authorization changes
    open func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse,.authorizedAlways:
            enableLocationManager()
        case .denied:
            didCompleteFindLocation(location: nil,error: NSError(
                domain: classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo: nil))
        case .restricted:
            didCompleteFindLocation(location: nil,error: NSError(
                domain: classForCoder.description(),
                code:Int(CLAuthorizationStatus.restricted.rawValue),
                userInfo: nil))
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        }
        NotificationCenter.default.post(name: .LocationServiceAuthorizationChanged, object: nil)
    }
    /// didFailWithError: when location manager fail to get the location
    open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didCompleteFindLocation(location: nil, error: error as NSError?)
    }
    /// getGeoCodeForAddress: Geocoding is used to get the address fro mthe place using the GeoLocation
    func getGeoCodeForAddress(_ address:String, completionHandler:@escaping GeoLocationClosure){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) -> Void in
            if error != nil {
                completionHandler(nil,nil,error)
            } else{
                if let placemark = placemarks?.first {
                    completionHandler(placemark.location,placemark,nil)
                } else {
                    completionHandler(nil,nil,NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue, NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue, NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                }
            }
        } )
    }
    /// GeoCode based on zip code is fetched from the Google Api's
    func getGeoCodeForZipcode(_ zipcode:String, country:String = "US",completionHandler:@escaping GeoLocationClosure){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressDictionary([String(CNPostalAddressPostalCodeKey):zipcode, String(CNPostalAddressCountryKey): country]) { (placemarks: [CLPlacemark]?, error: Error?) in
            if error != nil {
                completionHandler(nil,nil,error)
            } else{
                if let placemark = placemarks?.first {
                    completionHandler(placemark.location,placemark,nil)
                } else {
                    completionHandler(nil,nil,NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue, NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue, NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                }
            }
        }
    }
    ///  Calculate the destination distance from the source location
    func getDistanceFromCurrentLocation(location:CLLocation)->Float?{
        if let currentLocation = currentLocation {
            let distanceInMeters = currentLocation.distance(from: location)
            let distanceInMiles = distanceInMeters * 0.000621371
            return Float(distanceInMiles)
        }
        return nil
    }
    /// getGeoCodeForAddressWithGoogleMaps - Geo Location based on the addrress, based on the Google Api's
    func getGeoCodeForAddressWithGoogleMaps(_ address:String,completionHandler:@escaping GeoLocationGoogleClosure){
        let geoCodeURL = Utilities.getURLWith(key: "googleGeoCode") ?? ""
        let urlString = "\(geoCodeURL)\(address)"
        let charactersSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        charactersSet.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: charactersSet as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        do{
                            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                            if let status = jsonObject["status"] as? String, status == "OK", let results = jsonObject["results"] as? NSArray, results.count > 0, let firstResult = results[0] as? [String:AnyObject]{
                                DispatchQueue.main.async(execute: { () -> Void in
                                    let placemark = self.parseGoogleAPIResponseWith(result: firstResult)
                                    completionHandler(placemark,nil)
                                })
                            }else{
                                DispatchQueue.main.async(execute: { () -> Void in
                                    completionHandler(nil,NSError(
                                        domain: self.classForCoder.description(),
                                        code:Int(CLAuthorizationStatus.denied.rawValue),
                                        userInfo:
                                        [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue, NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue, NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                                })
                            }
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                            DispatchQueue.main.async(execute: { () -> Void in
                                completionHandler(nil,NSError(
                                    domain: self.classForCoder.description(),
                                    code:Int(CLAuthorizationStatus.denied.rawValue),
                                    userInfo:
                                    [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue, NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue, NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                            })
                        }
                    }
                })
                dataTask.resume()
            }
        }
    }
    /// Get the Distance from the current location with distance matrix
    func getDistanceFromCurrentLocationWithDistanceMatrixFor(location:CLLocation, onGetDistance: @escaping (_ distance: Double, _ success: Bool) -> ()) {
        if currentLocation == nil {
            onGetDistance(0, false)
            return
        }
        let distanceMatricURL = Utilities.getURLWith(key: "googleDistanceMatrix") ?? ""
        let urlString = "\(distanceMatricURL)origins=\(location.coordinate.latitude),\(location.coordinate.longitude)&destinations=\(currentLocation!.coordinate.latitude),\(currentLocation!.coordinate.longitude)"
        let charactersSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        charactersSet.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: charactersSet as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                            if let status = result["status"] as? String, status == "OK"{
                                if let rows = result["rows"] as? NSArray, rows.count > 0, let firstRow = rows[0] as? [String:Array<[String:AnyObject]>], let elements = firstRow["elements"], elements.count > 0, let distanceObject = elements[0]["distance"] as? [String:AnyObject], let distanceValue = distanceObject["value"] as? Double{
                                    let distanceInMiles = distanceValue * 0.000621371
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        onGetDistance(distanceInMiles, true)
                                    })
                                    return
                                }else{
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        onGetDistance(0, false)
                                    })
                                }
                            }else{
                                DispatchQueue.main.async(execute: { () -> Void in
                                    onGetDistance(0, false)
                                })
                            }
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                            DispatchQueue.main.async(execute: { () -> Void in
                                onGetDistance(0, false)
                            })
                        }
                    }
                })
                dataTask.resume()
            }
        }
    }
    /// Parsing the Google APi's respponse  and returning the palcemarker model object to place it on the map
    private func parseGoogleAPIResponseWith(result: [String:AnyObject]) -> CustomPlacemarkModel?{
        let placemark = CustomPlacemarkModel()
        if let addressRows = result["address_components"] as? Array<[String:AnyObject]>{
            for row in addressRows {
                if let types = row["types"] as? Array<String> {
                    if types.contains("postal_code"){
                        placemark.postalCode = row["short_name"] as? String
                    }else if types.contains("sublocality"){
                        placemark.subLocality = row["short_name"] as? String
                    }else if types.contains("locality"){
                        placemark.locality = row["short_name"] as? String
                    }else if types.contains("administrative_area_level_1"){
                        placemark.state = row["short_name"] as? String
                    }else if types.contains("country"){
                        placemark.country = row["short_name"] as? String
                    }
                }
            }
        }
        if let geometryObject = result["geometry"] as? [String:AnyObject], let locationObject = geometryObject["location"] as? [String:Double], let latitude = locationObject["lat"], let longitude = locationObject["lng"] {
            placemark.location = CLLocation(latitude: latitude, longitude: longitude)
        }
        return placemark
    }
}
