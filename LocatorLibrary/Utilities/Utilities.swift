//
//  Utilities.swift
//  Branch Locator
//
//  Created by Vinay Shivanna on 10/28/17.
//  Copyright © 2017 Vinay Shivanna. All rights reserved.
//

import Foundation
/**
 The purpose of the `Utilities` is used to have the common methods used throughout the Module
 */
open class Utilities {
    /// This Method will serialize the data and return dictionary
    open class func convertToDictionary(data: Data) -> [String: AnyObject]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    /// This Method will serialize the data and return Array
    open class func convertToArray(data: Data) -> [AnyObject]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [AnyObject]
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    /// This Method will read the URL's from the plist for the key
    open class func getURLWith(key: String) -> String? {
        let plistPath: String? = Bundle.main.path(forResource:"URIConfig", ofType: "plist")
        let uriConfigCache: NSDictionary? = plistPath != nil ? NSDictionary(contentsOfFile: plistPath!) : nil
        return uriConfigCache?.value(forKey: key) as? String
    }
}
