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
    case Regionen
    
    static func filterTypeFromString(filterType: NSString?) throws -> FilterType {
        guard let filterType = filterType else { // if nil Optional is passed to the function
            throw FilterError.NilStringFilterType
        }
        
        let ft = filterType as String
        if Utils.string(ft, equalsToAnyOfTheStringsInArrayOfString: ["ticker", "news", "nachrichten", "national-ticker"]) {
            return .Ticker
        } else if Utils.string(ft, equalsToAnyOfTheStringsInArrayOfString: ["lokalnews", "regional-ticker", "lokales"]) {
            return .Lokalnews
        } else if Utils.string(ft, equalsToAnyOfTheStringsInArrayOfString: ["events", "veranstaltungen"]) {
            return .Events
        } else if Utils.string(ft, equalsToAnyOfTheStringsInArrayOfString: ["angebote", "gutscheine"]) {
            return .Angebote
        } else if Utils.string(ft, equalsToAnyOfTheStringsInArrayOfString: ["vereinsnews", "vereine"]) {
            return .Vereinsnews
        } else if Utils.string(ft, equalsToAnyOfTheStringsInArrayOfString: ["regionen", "regions"]) {
            return .Regionen
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
            case .Regionen: return "regionen"
        }
    }
    
    static func totalFilterTypesCount() -> Int {
        return 6
    }
}

@objc class Filters: NSObject {
    static let sharedInstance = Filters()
    private var filters = Array<Array<Int>>(count: FilterType.totalFilterTypesCount(), repeatedValue: [])
    private var loadedFiltersFromServer = Array<Bool>(count: FilterType.totalFilterTypesCount(), repeatedValue: false)
    
    private override init() {
        super.init()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        func copyTheContentOfTheOldArrayAndResizeArrayIfNecessary<T>(from: Array<T>, to: Array<T>) -> Array<T> {
            var result = to
            
            let requiredFiltersArraySize = FilterType.totalFilterTypesCount()
            
            if from.count < requiredFiltersArraySize {
                for i in 0..<from.count {
                    result[i] = from[i]
                }
            } else {
                result = from
            }
            
            return result
        }
        
        let isFirstLaunch = defaults.objectForKey("isFirstAppLaunch")
        if (isFirstLaunch == nil) {
            loadDefaultFilters()
            defaults.setBool(true, forKey: "isFirstAppLaunch")
            defaults.synchronize();
        } else {
            // load the filters from NSUserDefaults
            if let savedFilters = defaults.objectForKey("filters") as? [[Int]] {
                // check if new filterTypes were added & the array was resized
                filters = copyTheContentOfTheOldArrayAndResizeArrayIfNecessary(savedFilters, to: filters)
            } else {
                loadDefaultFilters()
            }
            
            if let loadedFilterTypes = defaults.objectForKey("loadedFiltersFromServer") as? [Bool] {
                loadedFiltersFromServer = copyTheContentOfTheOldArrayAndResizeArrayIfNecessary(loadedFilterTypes, to: loadedFiltersFromServer)
            }
        }
    }

    func loadDefaultFilters() {
        // load default filters
        let defaultFilters = STAppSettingsManager.sharedSettingsManager().defaultFilters
        if defaultFilters != nil {
            for (filterStringType, defaultFiltersFromConfig) in defaultFilters {
                let index = try! FilterType.filterTypeFromString(filterStringType as? NSString)
                saveFilter(filterIds: defaultFiltersFromConfig as! [Int], forEnumFilterType: index, notification: false)
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
    
//MARK: - check if the filters were already loaded from server and stored
    func areFiltersAlreadyLoadedFromServerForType(filterType: FilterType) -> Bool {
        return loadedFiltersFromServer[filterType.rawValue]
    }
    
    func areFiltersAlreadyLoadedFromServerForStringFilterType(stringFilterType: NSString) -> Bool {
        do {
            let index = try FilterType.filterTypeFromString(stringFilterType)
            return areFiltersAlreadyLoadedFromServerForType(index)
        } catch {
            return false
        }
    }

    func filterTypeWasLoadedFromServer(filterType: FilterType) {
        loadedFiltersFromServer[filterType.rawValue] = true
    }
    
    func stringfilterTypeWasLoadedFromServer(stringFilterType: NSString) {
        do {
            let index = try FilterType.filterTypeFromString(stringFilterType)
            return filterTypeWasLoadedFromServer(index)
        } catch {}
    }
    
    func resetFilterTypesLoadedFromServer() {
        for i in 0..<loadedFiltersFromServer.count {
            loadedFiltersFromServer[i] = false
        }
    }
    
//MARK: - save methods
    
    func saveFilters() {
        NSUserDefaults.standardUserDefaults().setObject(filters, forKey: "filters")
        NSUserDefaults.standardUserDefaults().setObject(loadedFiltersFromServer, forKey: "loadedFiltersFromServer")
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    func saveFilter(filterIds filterIds: [Int], forEnumFilterType filterType: FilterType, notification: Bool = true) {
        for filterId in filterIds {
            if (!filters[filterType.rawValue].contains(filterId)) {
                filters[filterType.rawValue].append(filterId)
            }
        }
        saveFilters()
        if (notification) {
            postNotification(filterType)
        }
    }
    
    func saveRegionFilter(filterIds filterIds: [Int], forEnumFilterType filterType: FilterType, notification: Bool = true) {
        for filterId in filterIds {
            if (!filters[filterType.rawValue].contains(filterId)) {
                filters[filterType.rawValue].append(filterId)
            }
        }
        
        for filterId in filters[filterType.rawValue] {
            if (!filterIds.contains(filterId)) {
                filters[filterType.rawValue].removeAtIndex(filters[filterType.rawValue].indexOf(filterId)!)
            }
        }

        saveFilters()
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
    
    func deleteFilter(filterIds filterIds: [Int], forEnumFilterType filterType: FilterType, notification: Bool = true) throws {
        for filterId in filterIds {
            let filtersOfSpecificType = filters[filterType.rawValue]
            let index = filtersOfSpecificType.indexOf(filterId)
            
            if (index == nil) {
                throw FilterError.ObjectToDeleteNotFound
            }

            filters[filterType.rawValue].removeAtIndex(index!)
        }
        
        if notification {
            postNotification(filterType)
        }
    }
    
    @available (*, deprecated=1.0, message="use the safe method with filter types instead")
    func deleteFilter(filterIds filterIds: [Int], forStringFilterType filterType: NSString, notification: Bool = true) throws {
        let type = try FilterType.filterTypeFromString(filterType)
        try deleteFilter(filterIds: filterIds, forEnumFilterType: type, notification: notification)
    }
    
//MARK: - notification methods

    private func postNotification(filterType: FilterType) {
        NSNotificationCenter.defaultCenter().postNotificationName("filtersUpdate_" + filterType.toString(), object: self)
    }
}







