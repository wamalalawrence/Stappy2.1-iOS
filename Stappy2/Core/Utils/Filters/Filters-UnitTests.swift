//
//  Filters-UnitTests.swift
//  Schwedt
//
//  Created by Denis Grebennicov on 18/02/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

//import XCTest
//@testable import Schwedt
//
//class Filters_UnitTests: XCTestCase {
//    func testIfNewsFilterIs84847OnStart() {
//        XCTAssertTrue(Filters.sharedInstance.filtersForType(.Ticker) == [84847])
//        Filters.sharedInstance.saveFilters()
//    }
//    
//    func testIfNewsFilterIsAlways84847() {
//        XCTAssertTrue(Filters.sharedInstance.filtersForType(.Ticker) == [84847])
//    }
//    
//    func testIfSaveAndDeletionWorks() {
//        let filters = Filters.sharedInstance
//        
//        filters.saveFilter(filterIds: [100], forEnumFilterType: .Vereinsnews)
//        XCTAssertTrue(filters.filtersForType(.Vereinsnews).contains(100))
//        
//        try! filters.deleteFilter(filterIds: [100], forEnumFilterType: .Vereinsnews)
//        XCTAssertFalse(filters.filtersForType(.Vereinsnews).contains(100))
//    }
//    
//    func testIfSaveAndDeletionWorksOnStringParameters() {
//        let filters = Filters.sharedInstance
//        
//        try! filters.saveFilter(filterIds: [100], forStringFilterType: "vereinsnews")
//        XCTAssertTrue(filters.filtersForType(.Vereinsnews).contains(100))
//        
//        try! filters.deleteFilter(filterIds: [100], forStringFilterType: "vereinsnews")
//        XCTAssertFalse(filters.filtersForType(.Vereinsnews).contains(100))
//    }
//    
//    func testIfInvalidStringFilterTypeThrows() {
//        do {
//            try Filters.sharedInstance.saveFilter(filterIds: [-100], forStringFilterType: "blablabla")
//            XCTAssertTrue(false, "save filter method should throw an error")
//        } catch {}
//    }
//}
