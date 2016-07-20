//
//  OpeningHoursHeaderView.swift
//  Stappy2
//
//  Created by Denis Grebennicov on 09/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

import Foundation

class OpeningHoursHeaderView: UITableViewHeaderFooterView {
    @IBOutlet private weak var openingHoursLabel: UILabel!
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    
    var titlePrefix = "Öffnungszeiten" {
        didSet {
            openingHoursLabel.text = title
        }
    }
    var openingHoursViewTitle = "" {
        didSet {
            openingHoursLabel.text = title
        }
    }
    var title: String {
        get {
            if (openingHoursViewTitle == "main") {
                return titlePrefix
            }
            return titlePrefix + " " + openingHoursViewTitle
        }
    }
    
    override func awakeFromNib() {
        // set fonts
        let labelFont = STAppSettingsManager.sharedSettingsManager().customFontForKey("openingHours.cellLabelTop.font")
            
        if labelFont != nil {
            mondayLabel.font = labelFont
            tuesdayLabel.font = labelFont
            wednesdayLabel.font = labelFont
            thursdayLabel.font = labelFont
            fridayLabel.font = labelFont
            saturdayLabel.font = labelFont
            sundayLabel.font = labelFont
        }
        
        let titleFont = STAppSettingsManager.sharedSettingsManager().customFontForKey("openingHours.titleLabel.font")
        
        if titleFont != nil {
            openingHoursLabel.font = titleFont
        }
    }
}