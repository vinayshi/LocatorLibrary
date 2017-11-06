//
//  BaseService.swift
//  Branch Locator
//
//  Created by Vinay Shivanna on 10/28/17.
//  Copyright © 2017 Vinay Shivanna. All rights reserved.
//
/**
 The purpose of the `BaseService` is Service Manager to h=handle the network calls from the VC's
 */
import Foundation
/// Serialize thte data with Codable
public protocol Serializable: Codable {
    func serialize() -> Data?
}
/// Extending the Serializable protocol with serializing the data with encoder
public extension Serializable {
    func serialize() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
}
/// BaseServiceProtocol is when the network service finishes its connection and have delegates for Resposne and Error
public protocol BaseServiceProtocol: class {
    func didRecieveResponseWithCompletion(serviceIdentifier:ServiceIdentifierEnum, responseData:Data)
    func didFailWithError(serviceIdentifier:ServiceIdentifierEnum, error:Error)
}

open class BaseService: NSObject {
    /// BaseServiceProtocol when service connection have the Http Response or Http error
    weak var delegate: BaseServiceProtocol?
    /// Service Identifer to recognize which type of the services
    var serviceIdentifier: ServiceIdentifierEnum!
    /// Type og HTTP Rest service
    var serviceType: ServiceTypeEnum!
    /// Request Body with the parameters to be sent to server in HTTP body content
    var requestBody: [String:AnyObject] = ["":"" as AnyObject]
    /// Service URL to make an HTTP Connection
    var serviceURL:String = ""
    /// Initializer to set the default properities which are being set
    public convenience init(serviceIdentifier: ServiceIdentifierEnum, serviceType:ServiceTypeEnum, serviceURL: String, requestData: Data? = nil, delegate:BaseServiceProtocol) {
        self.init()
        self.serviceIdentifier = serviceIdentifier
        self.serviceType = serviceType
        if let requestData = requestData, let requestBody = Utilities.convertToDictionary(data: requestData) {
            self.requestBody = requestBody
        }
        self.delegate = delegate
        self.serviceURL = serviceURL
    }
    /// This method will make an Service call with all the Http url, headers, body and session
    open func start() {
        let baseUrl = "" //get base url based on environment
        let url:String = baseUrl + serviceURL
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        
        let session :Foundation.URLSession = URLSession(configuration: configuration, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
        // Add headers to the request
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = serviceType.rawValue
        if serviceType != .GET {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        print("request : \(request)")
        
        let dataTask = session.dataTask(with: request, completionHandler: {
            data, response, error -> Void in
            if let error = error {
                print("error \(String(describing: error))")
                self.delegate?.didFailWithError(serviceIdentifier: self.serviceIdentifier, error: error)
            }
            else{
                self.delegate?.didRecieveResponseWithCompletion(serviceIdentifier: self.serviceIdentifier, responseData: data! as Data)
            }
        })
        dataTask.resume()
    }
}
