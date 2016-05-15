//
//  Filters.swift
//  Schwedt
//
//  Created by Denis Grebennicov on 18/02/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

import Foundation

enum FilterError: ErrorType {
    case InvalidStringFilterType
    case NilStringFilterType
    case ObjectToDeleteNotFound
}

@objc enum FilterType: Int {
    case Ticker
    case Lokalnews
    case Events
    case Angebote
    case Vereinsnews
    
    static func filterTypeFromString(filterType: NSString?) throws -> FilterType {
        guard let filterType = filterType else { // if nil Optional is passed to the function
            throw FilterError.NilStringFilterType
        }
        
        if (filterType.isEqualToString("ticker") || filterType.isEqualToString("news") || filterType.isEqualToString("nachrichten")) {
            return .Ticker
        } else if (filterType.isEqualToString("lokalnews")) {
            return .Lokalnews
        } else if (filterType.isEqualToString("events")) {
            return .Events
        } else if (filterType.isEqualToString("angebote")) {
            return .Angebote
        } else if (filterType.isEqualToString("vereinsnews") || filterType.isEqualToString("vereine")) {
            return .Vereinsnews
        } else {
            throw FilterError.InvalidStringFilterType
        }
    }
    
    func toString() -> String {
        switch self {
            case .Ticker: return "ticker"
            case .Lokalnews: return "lokalnews"
            case .Events: return "events"
            case .Angebote: return "angebote"
            case .Vereinsnews: return "vereinsnews"
        }
    }
    
    static func totalFilterTypesCount() -> Int {
        return 5
    }
}

@objc class Filters: NSObject {
    static let sharedInstance = Filters()
    private var filters = [[Int]]()
    
    private override init() {
        super.init()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let isFirstLaunch = defaults.objectForKey("isFirstAppLaunch")
        
        if (isFirstLaunch == nil) {
            loadDefaultFilters()
            defaults.setBool(true, forKey: "isFirstAppLaunch")
        } else {
            // load the filters from NSUserDefaults
            if let savedFilters = defaults.objectForKey("filters") {
                filters = savedFilters as! [[Int]]
            } else {
                loadDefaultFilters()
            }
        }
    }

    private func loadDefaultFilters() {
        filters = [[Int]](count: FilterType.totalFilterTypesCount(), repeatedValue: []);

        // load default filters
        let defaultFilters = STAppSettingsManager.sharedSettingsManager().defaultFilters
        if defaultFilters != nil {
            for (filterStringType, defaultFiltersFromConfig) in defaultFilters {
                let index = try! FilterType.filterTypeFromString(filterStringType as? NSString)
                filters[index.rawValue] = defaultFiltersFromConfig as! [Int]
            }
        }
    }
    
    func filtersForType(filterType: FilterType) -> [Int] {
        return filters[filterType.rawValue]
    }

    func filtersForType(stringFilterType: NSString) throws -> [Int] {
        let index = try FilterType.filterTypeFromString(stringFilterType)
        return filtersForType(index)
    }
    
//MARK: - save methods
    
    func saveFilters() {
        NSUserDefaults.standardUserDefaults().setObject(filters, forKey: "filters")
    }
    
    func saveFilter(filterIds filterIds: [Int], forEnumFilterType filterType: FilterType, notification: Bool = true) {
        for filterId in filterIds {
            if (!filters[filterType.rawValue].contains(filterId)) {
                filters[filterType.rawValue].append(filterId)
            }
        }
        
        if (notification) {
            postNotification(filterType)
        }
    }
    
    @available (*, deprecated=1.0, message="use the safe method with filter types instead")
    func saveFilter(filterIds filterIds: [Int], forStringFilterType filterType: NSString) throws {
        let type = try FilterType.filterTypeFromString(filterType)
        saveFilter(filterIds: filterIds, forEnumFilterType: type)
    }
    
    @available (*, deprecated=1.0, message="use the safe method with filter types instead")
    func saveFilter(filterIds filterIds: [Int], forStringFilterType filterType: NSString, notification: Bool) throws {
        let type = try FilterType.filterTypeFromString(filterType)
        saveFilter(filterIds: filterIds, forEnumFilterType: type, notification: notification)
    }
    
//MARK: - delete methods
    
    func deleteFilter(filterIds filterIds: [Int], forEnumFilterType filterType: FilterType) throws {
        for filterId in filterIds {
            let filtersOfSpecificType = filters[filterType.rawValue]
            let index = filtersOfSpecificType.indexOf(filterId)
            
            if (index == nil) {
                throw FilterError.ObjectToDeleteNotFound
            }

            filters[filterType.rawValue].removeAtIndex(index!)
        }
        postNotification(filterType)
    }
    
    @available (*, deprecated=1.0, message="use the safe method with filter types instead")
    func deleteFilter(filterIds filterIds: [Int], forStringFilterType filterType: NSString) throws {
        let type = try FilterType.filterTypeFromString(filterType)
        try deleteFilter(filterIds: filterIds, forEnumFilterType: type)
    }
    
//MARK: - notification methods

    private func postNotification(filterType: FilterType) {
        NSNotificationCenter.defaultCenter().postNotificationName("filtersUpdate_" + filterType.toString(), object: self)
    }
}







