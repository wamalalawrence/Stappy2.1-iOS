//
//  OpeningHoursMultipleViews.swift
//  Stappy2
//
//  Created by Denis Grebennicov on 09/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

import Foundation

@objc class OpeningHoursMultipleViews: UIView, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private weak var openingHoursTableView: UITableView!
    private static let cellReuseIdentifier = "openingHoursCell"
    var openingHoursData = [OpeningClosingTimesModel]() {
        didSet {
            openingHoursTableView.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        guard let view = NSBundle.mainBundle().loadNibNamed("OpeningHoursMultipleViews", owner: self, options: nil).first as? UIView else { return; }
        view.frame = bounds
        addSubview(view)

        openingHoursTableView.delegate = self
        openingHoursTableView.dataSource = self
        
        // register the cell
        openingHoursTableView.registerNib(UINib.init(nibName: "OpeningHoursView", bundle: NSBundle.mainBundle()),
                                          forCellReuseIdentifier: OpeningHoursMultipleViews.cellReuseIdentifier)
    }
    
    internal class func heightForData(data: [OpeningClosingTimesModel]) -> CGFloat {
        var sum = CGFloat(0)
        for d in data {
            sum += OpeningHoursView.heightForData(d)
        }
        
        // add offset between views
        let offset = CGFloat(15)
        sum += CGFloat(data.count - 1) * offset
        
        return sum
    }
    
//MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return openingHoursData.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(OpeningHoursMultipleViews.cellReuseIdentifier,
                                                               forIndexPath: indexPath) as! OpeningHoursView
        
        cell.openingHoursData = openingHoursData[indexPath.section]
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return OpeningHoursView.heightForData(openingHoursData[indexPath.row])
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
}