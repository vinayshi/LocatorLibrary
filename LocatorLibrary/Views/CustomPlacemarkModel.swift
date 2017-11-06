//
//  CustomPlacemarkModel.swift
//  LocatorLibrary
//
//  Created by Vinay Shivanna on 10/29/17.
//  Copyright © 2017 Vinay Shivanna. All rights reserved.
//

import Foundation
import CoreLocation
/**
 The purpose of the `CustomPlacemarkModel` is used to place the Placemark on the maps with the model data
 */
class CustomPlacemarkModel: NSObject {
    /// location is used to have the location on the map
    var location: CLLocation?
    /// display the postal code on the placemark
    var postalCode: String?
    /// display the country on the placemark
    var country: String?
    /// display the state on the placemark
    var state: String?
    /// display the city on the placemark
    var city: String?
    /// display the locality on the placemark
    var locality: String?
    /// display the sub locality on the placemark
    var subLocality: String?
}
