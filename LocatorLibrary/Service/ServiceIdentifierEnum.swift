//
//  ServiceIdentifierEnum.swift
//  Branch Locator
//
//  Created by Vinay Shivanna on 10/28/17.
//  Copyright © 2017 Vinay Shivanna. All rights reserved.
//

import Foundation
/// Identify the Type of the service
public enum ServiceIdentifierEnum {
    case storeLocater
}
/// Identify yhe type of the HTTP Service Type
public enum ServiceTypeEnum: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}
