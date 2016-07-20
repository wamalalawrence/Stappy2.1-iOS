//
//  GarbageCalendarService.swift
//  Stappy2
//
//  Created by Denis Grebennicov on 16/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

import Foundation
import AFNetworking

@objc
enum GarbageCalendarServiceError: Int {
    case DataIsInWrongFormat
    case FailedToLoadData
    
    static let domain = "GarbageCalendarServiceError"
    static func createNSError(code: GarbageCalendarServiceError, data: AnyObject) -> NSError {
        return createNSError(code, userInfo: ["data": data])
    }
    
    static func createNSError(code: GarbageCalendarServiceError, userInfo: [NSObject: AnyObject]?) -> NSError {
        return NSError.init(domain: domain, code: code.rawValue, userInfo: userInfo)
    }
}

@objc
class GarbageCalenderService: NSObject {
    static let sharedInstance = GarbageCalenderService()
    private override init() { super.init() }
    
    func garbageTypes(block: ([[String: AnyObject]]?, NSError?) -> Void) {
        let url = STRequestsHandler.sharedInstance().buildUrl("/garbage-calendar-filter")
        
        AFHTTPSessionManager.init().GET(url, parameters: nil, success: { (sessionTask, responseObject) in
            guard let data = responseObject!["data"] as? [String:AnyObject] else {
                block(nil, GarbageCalendarServiceError.createNSError(.DataIsInWrongFormat, data: responseObject!))
                return
            }
            
            if let enums = data["enums"] as? [[String: AnyObject]] {
                block(enums, nil)
            }
            
            }) { (sessionTask, error) in
                block(nil, GarbageCalendarServiceError.createNSError(.FailedToLoadData, userInfo: ["error": error]))
        };
    }
    
    func garbageData(ForZip zip: String, street:String, completion:([[String: AnyObject]], NSError?) -> ()) {
        let url = STRequestsHandler.sharedInstance().buildUrl("/garbage-calendar-dates")
        
        
        let typesArray = GarbageCalendarManager.sharedInstance.enabledGarbageTypes
        var types: [String] = []
        for i in 0..<typesArray.count {
            if let t = typesArray[i]["enum"] as? String {
                types.append(t)
            }
        }

        AFHTTPSessionManager.init().GET(url, parameters: ["postalcode": zip, "street": street, "types": types.joinWithSeparator(",")], success: { (sessionTask, responseObject) in
            if let data = responseObject!["data"] as? [[String: AnyObject]] {
                if data == [] {
                    completion([], GarbageCalendarServiceError.createNSError(.FailedToLoadData, data: data))
                    return
                }
                completion(data, nil)
            } else {
                completion([], GarbageCalendarServiceError.createNSError(.DataIsInWrongFormat, data: responseObject!))
            }
        }) { (sessionTask, error) in
            completion([], GarbageCalendarServiceError.createNSError(.FailedToLoadData, userInfo: ["error": error]))
        };
    }
    
//MARK: - Methods for autocompletion
    func possibleZips(zip: String, completion:([String]) -> ()) {
        let url = STRequestsHandler.sharedInstance().buildUrl("/garbage-calendar-search-postalcode")
        
        AFHTTPSessionManager.init().GET(url, parameters: ["search": zip], success: { (sessionTask, responseObject) in
            if let data = responseObject!["data"] as? [String] {
                completion(data)
            } else {
                completion([])
            }
            
        }, failure: { (sessionTask, error) in completion([])})
    }
    
    func possibleStreets(ForZip zip: String, street: String, completion:([String]) -> ()) {
        let url: String
        let parameters: [String: String]
        
        if (street == "") {
            url = STRequestsHandler.sharedInstance().buildUrl("/garbage-calendar-streets")
            parameters = ["postalcode":zip]
        } else {
            url = STRequestsHandler.sharedInstance().buildUrl("/garbage-calendar-search-street")
            parameters = ["search": street, "postalcode": zip]
        }
        
        AFHTTPSessionManager.init().GET(url, parameters: parameters, success: { (sessionTask, responseObject) in
            if let data = responseObject!["data"] as? [String] {
                completion(data)
            } else if let data = responseObject!["content"] as? [[String:String]] {
                var streets = [String]()
                for streetDict in data {
                    for street in streetDict.values {
                        streets.append(street)
                    }
                }
                completion(streets)
            } else {
                completion([])
            }
            
        }, failure: { (sessionTask, error) in completion([])})
    }
}