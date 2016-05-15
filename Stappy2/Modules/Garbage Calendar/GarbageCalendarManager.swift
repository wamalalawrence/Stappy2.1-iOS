//
//  GarbageCalendarManager.swift
//  Stappy2
//
//  Created by Denis Grebennicov on 16/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

import Foundation
import MCDateExtensions
import NSDate_Calendar

extension NSUserDefaults {
    func valueForKey(key: String, defaultValue: AnyObject) -> AnyObject {
        if let x = self.valueForKey(key) {
            return x
        } else {
            return defaultValue
        }
    }
}

@objc
enum ReminderType: Int {
    case Never
    case EveningBefore
    case Morning
}

@objc
class GarbageCalendarManager: NSObject {
    static let sharedInstance = GarbageCalendarManager()
    
    
    var zip = ""
    var street = ""
    var reminderType = ReminderType.Never
    var results = [[String: AnyObject]]()
    var garbageTypes = [[String: AnyObject]]()
    var enabledGarbageTypes = [[String: AnyObject]]()
    
//MARK: - Notification
    var lastReload: NSDate!
    var _notification: UILocalNotification?
    var notification: UILocalNotification? {
        get {
            
            if _notification == nil {
                guard let notifications = UIApplication.sharedApplication().scheduledLocalNotifications else { return nil }
                
                for n in notifications {
                    if let userInfo = n.userInfo {
                        let type = userInfo["type"] as! String
                        if type == "abfallkalender" {
                            _notification = n
                            break
                        }
                    }
                }
            }
            
            return _notification
        } set {
            _notification = newValue
        }
    }
    
    func setupNotification() {
        if let n = notification {
            UIApplication.sharedApplication().cancelLocalNotification(n)
        }
        
        if reminderType == .Never { return }
        
        func nextNotification() -> [String: AnyObject]? {
            if results.count > 0 {
                return self.results[0]
            } else {
                return nil
            }
        }
        
        guard let next = nextNotification() else { return }
        
        let inputDateFormatter = NSDateFormatter()
        inputDateFormatter.dateFormat = "dd.MM.yyy";
        
        guard let nextGarbageDate = next["date"] as? String else { return }
        guard let date = inputDateFormatter.dateFromString(nextGarbageDate) else { return }
        
        var reminderDate = NSDate()
        
        switch reminderType {
            case .Morning: reminderDate = date.dateBySettingHour(7)
            case .EveningBefore: reminderDate = date.dateByAddingDays(-1).dateBySettingHour(21)
            case .Never: break // never happens
        }
        
        if reminderDate.timeIntervalSince1970 < NSDate().timeIntervalSince1970 {
            print("Reminder date already over, ignoring")
        }
        
        let n = UILocalNotification()
        n.fireDate = reminderDate;
        n.alertBody = "Denken Sie daran, Ihr Müll wird abgeholt";
        n.timeZone = NSTimeZone.defaultTimeZone()
        n.userInfo = ["type": "abfallkalender"]
        
        notification = n
        
        print(NSDate())
        print("Next Garbage Pickup at: \(date)")
        print("Next Garbage Notification at: \(reminderDate)")
        
        UIApplication.sharedApplication().scheduleLocalNotification(n)
    }
    
//MARK: -
    
    private var _configured = false
    var configured: Bool {
        @objc(isConfigured)
        get {
            return self._configured
        } set {
            _configured = newValue
        }
    }
    
    override private init() {
        super.init()
        
        load()
        
        if garbageTypes == [] {
            GarbageCalenderService.sharedInstance.garbageTypes({ (data, error) in
                if data != nil {
                    self.garbageTypes = data!
                    self.enabledGarbageTypes = data!
                } else {
                    debugPrint(error)
                }
            })
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            // reload data if necessary
            if self.configured && (self.lastReload == nil || !self.lastReload.isToday()) {
                self.configure(WithZip: self.zip, street: self.street, completion: nil)
            }
        }
        
        setupNotification()
    }
    
    func configure(WithZip zip: String, street: String, completion: (([[String: AnyObject]], NSError?) -> ())?) {
        GarbageCalenderService.sharedInstance.garbageData(ForZip: zip, street: street, completion: { (data, error) in
            self.configured = error == nil
            self.results = data
            self.lastReload = NSDate()
            
            if completion != nil {
                completion!(data, error)
            }
            
            self.setupNotification()
        })
    }
    
//MARK: - Load/Save methods for NSUserDefaults
    
    func load() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        zip = defaults.valueForKey("abfall_zip", defaultValue: "") as! String
        street = defaults.valueForKey("abfall_street", defaultValue: "") as! String
        reminderType = ReminderType(rawValue: defaults.integerForKey("abfall_reminder_type"))!
        results = defaults.valueForKey("abfall_results", defaultValue: []) as! [[String : AnyObject]]
        garbageTypes = defaults.valueForKey("abfall_garbage_types", defaultValue: []) as! [[String: AnyObject]]
        enabledGarbageTypes = defaults.valueForKey("abfall_enabled_garbage_types", defaultValue: []) as! [[String: AnyObject]]
        configured = defaults.valueForKey("abfall_configured", defaultValue: false) as! Bool
    }
    
    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setValue(zip, forKey: "abfall_zip")
        defaults.setValue(street, forKey: "abfall_street")
        defaults.setInteger(reminderType.rawValue, forKey: "abfall_reminder_type")
        defaults.setValue(results, forKey: "abfall_results")
        defaults.setValue(garbageTypes, forKey: "abfall_garbage_types")
        defaults.setValue(enabledGarbageTypes, forKey: "abfall_enabled_garbage_types")
        defaults.setValue(configured, forKey: "abfall_configured")
    }
}