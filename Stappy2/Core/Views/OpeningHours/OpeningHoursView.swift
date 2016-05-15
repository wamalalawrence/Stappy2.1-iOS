//
//  OpeningHoursView.swift
//  Stappy2
//
//  Created by Denis Grebennicov on 09/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

import Foundation

class OpeningHoursView: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    private static let headerCellReuseIdentifier = "openingHoursHeaderCell"
    private static let cellReuseIdentifier = "openingHoursCell"

    var openingHoursData = OpeningClosingTimesModel() {
        didSet {
            openingHoursViewAdapter.data = openingHoursData
            openingHoursTableView.reloadData()
        }
    }
    var openingHoursViewAdapter = OpeningHoursViewAdapter()
    
    @IBOutlet private weak var openingHoursTableView: UITableView!
    
    override func awakeFromNib() {
        openingHoursTableView.dataSource = self
        openingHoursTableView.delegate = self
        
        // register the cells
        openingHoursTableView.registerNib(UINib.init(nibName: "OpeningHoursHeaderView", bundle: NSBundle.mainBundle()),
                                          forHeaderFooterViewReuseIdentifier: OpeningHoursView.headerCellReuseIdentifier)
        openingHoursTableView.registerNib(UINib.init(nibName: "OpeningHoursViewCell", bundle: NSBundle.mainBundle()),
                                          forCellReuseIdentifier: OpeningHoursView.cellReuseIdentifier)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openingHoursViewAdapter.maxNumberOfOpeningHours()
    }
    
    class func heightForData(data: OpeningClosingTimesModel) -> CGFloat {
        var adapter = OpeningHoursViewAdapter()
        adapter.data = data
        return CGFloat(adapter.maxNumberOfOpeningHours()) * 55 + 95
    }

//Mark: cell methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(OpeningHoursView.cellReuseIdentifier,
                                                               forIndexPath: indexPath) as! OpeningHoursViewCell
        
        setCellTextForCell(cell, indexPath: indexPath)
        setCellTextColourForCell(cell, indexPath: indexPath)
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    func setCellTextForCell(cell: OpeningHoursViewCell, indexPath: NSIndexPath) {
        let cellText = openingHoursViewAdapter.cellTextForIndex(indexPath.row)
        cell.mondayLabel.text = cellText[0]
        cell.tuesdayLabel.text = cellText[1]
        cell.wednesdayLabel.text = cellText[2]
        cell.thursdayLabel.text = cellText[3]
        cell.fridayLabel.text = cellText[4]
        cell.saturdayLabel.text = cellText[5]
        cell.sundayLabel.text = cellText[6]
    }
    
    func setCellTextColourForCell(cell: OpeningHoursViewCell, indexPath: NSIndexPath) {
        let cellColor = openingHoursViewAdapter.cellTextColorForIndex(indexPath.row)
        cell.mondayLabel.textColor = cellColor[0]
        cell.tuesdayLabel.textColor = cellColor[1]
        cell.wednesdayLabel.textColor = cellColor[2]
        cell.thursdayLabel.textColor = cellColor[3]
        cell.fridayLabel.textColor = cellColor[4]
        cell.saturdayLabel.textColor = cellColor[5]
        cell.sundayLabel.textColor = cellColor[6]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }

//MARK: header methods
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(OpeningHoursView.headerCellReuseIdentifier) as! OpeningHoursHeaderView
        
        headerView.openingHoursViewTitle = openingHoursData.key
        
        let cellColor = openingHoursViewAdapter.cellTextColorForIndex(0)
        headerView.mondayLabel.textColor = cellColor[0]
        headerView.tuesdayLabel.textColor = cellColor[1]
        headerView.wednesdayLabel.textColor = cellColor[2]
        headerView.thursdayLabel.textColor = cellColor[3]
        headerView.fridayLabel.textColor = cellColor[4]
        headerView.saturdayLabel.textColor = cellColor[5]
        headerView.sundayLabel.textColor = cellColor[6]
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
}