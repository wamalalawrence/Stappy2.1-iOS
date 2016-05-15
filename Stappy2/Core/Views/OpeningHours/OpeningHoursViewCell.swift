//
//  OpeningHoursViewCell.swift
//  Stappy2
//
//  Created by Denis Grebennicov on 10/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

import Foundation

class OpeningHoursViewCell: UITableViewCell {
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    
    override func awakeFromNib() {
        // set font
        let labelFont = STAppSettingsManager.sharedSettingsManager().customFontForKey("openingHours.cellLabel.font")
        
        if labelFont != nil {
            mondayLabel.font = labelFont
            tuesdayLabel.font = labelFont
            wednesdayLabel.font = labelFont
            thursdayLabel.font = labelFont
            fridayLabel.font = labelFont
            saturdayLabel.font = labelFont
            sundayLabel.font = labelFont
        }
    }
}
