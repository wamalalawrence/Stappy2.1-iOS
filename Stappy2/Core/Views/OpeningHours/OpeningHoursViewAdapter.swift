//
//  OpeningHoursDataSource.swift
//  Stappy2
//
//  Created by Denis Grebennicov on 09/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

import Foundation

class OpeningHoursViewAdapter {
    var data = OpeningClosingTimesModel() {
        didSet {
            adaptedData.adaptData(data)
        }
    }
    
    class OpeningClosingAdaptedTimesModel {
        var _nonAdaptedData = OpeningClosingTimesModel()
        var _adaptedData = [[OpeningClosingTimeModel?]]()
        
        func adaptData(data: OpeningClosingTimesModel) {
            _nonAdaptedData = data
            _adaptedData = Array<Array<OpeningClosingTimeModel?>>(count: maxNumberOfOpeningHours(data),
                                                                 repeatedValue: Array<OpeningClosingTimeModel?>(count: 7, repeatedValue: nil))
            
            var lastDayOfWeek = -1
            var adaptedDataIndex = 0
            for timeModel in data.openingHours as NSArray as! [OpeningClosingTimeModel] {
                if timeModel.dayOfWeek.integerValue == lastDayOfWeek {
                    adaptedDataIndex += 1
                } else {
                    adaptedDataIndex = 0
                }
                
                if timeModel.openingTime != nil && timeModel.closingTime != nil {
                    _adaptedData[adaptedDataIndex][timeModel.dayOfWeek.integerValue - 1] = timeModel
                }
                
                lastDayOfWeek = timeModel.dayOfWeek.integerValue
            }
        }
        
        subscript(index: Int) -> [OpeningClosingTimeModel?] {
            get {
                var dataForRow = Array<OpeningClosingTimeModel?>(count: 7, repeatedValue: nil)
                let temp = _adaptedData[index]
                
                for index in 0..<7 {
                    if temp.count > index {
                        dataForRow[index] = temp[index]
                    }
                }
                return dataForRow
            }
        }
        
        var maxNumberOfOpeningHours: Int {
            get {
                return maxNumberOfOpeningHours(_nonAdaptedData)
            }
        }
        
        func maxNumberOfOpeningHours(data: OpeningClosingTimesModel) -> Int {
            var maxNumberOfOpeningHours = 0
            
            let days = 1...7
            for day in days {
                let numberOfOpeningHours = data.openingHoursForDay(day).count
                maxNumberOfOpeningHours = max(maxNumberOfOpeningHours, numberOfOpeningHours)
            }
            
            return maxNumberOfOpeningHours
        }
    }
    
    private var adaptedData = OpeningClosingAdaptedTimesModel()
    
    func maxNumberOfOpeningHours() -> Int {
        return adaptedData.maxNumberOfOpeningHours
    }
    
    func cellTextForIndex(index: Int) -> [String] {
        let dataForRow = adaptedData[index]
        var text = Array<String>(count: 7, repeatedValue: "--:--\n-\n--:--")
        
        var index = 0
        for data in dataForRow {
            guard let timeModel = data else { index += 1; continue }
            
            text[index] = "\(timeModel.openingTime)\n-\n\(timeModel.closingTime)"
            
            index += 1
        }
        
        return text
    }
    
    func cellTextColorForIndex(index: Int) -> [UIColor] {
        let noOpeningHoursColor = UIColor.lightGrayColor()
        let openingHoursColor = UIColor.whiteColor()
        let todaysOpeningHoursColor = UIColor.partnerColor()
        
        let dataForRow = adaptedData[index]
        
        var colours = Array<UIColor>(count: 7, repeatedValue: noOpeningHoursColor)
        
        var index = 0
        for data in dataForRow {
            if data != nil {
                colours[index] = openingHoursColor
            }

            if NSDate().dayOfTheWeek() - 1 == index {
                colours[index] = todaysOpeningHoursColor
            }
            
            index += 1
        }
        
        
        return colours
    }

    func headerTextColorForIndex(index: Int) -> [UIColor] {
        let noOpeningHoursColor = UIColor.lightGrayColor()
        let openingHoursColor = UIColor.whiteColor()
        let todaysOpeningHoursColor = UIColor.partnerColor()
        
        var colours = Array<UIColor>(count: 7, repeatedValue: noOpeningHoursColor)

        for dataForRow in adaptedData._adaptedData {

            var index = 0
            for data in dataForRow {
                if data != nil {
                    colours[index] = openingHoursColor
                }
                
                if NSDate().dayOfTheWeek() - 1 == index {
                    colours[index] = todaysOpeningHoursColor
                }
                
                index += 1
            }
        }
        
        return colours
    }
}