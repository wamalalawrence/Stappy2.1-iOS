//
//  OverlayManager.swift
//  
//
//  Created by Denis Grebennicov on 25/02/16.
//
//

import UIKit

@objc class OverlayManager: NSObject, OverlayViewControllerDelegate {
    static let sharedInstance = OverlayManager()
    
    var animationDelay = CGFloat(0)
    private var _viewController: UIViewController!
    private var _overlayQueue = [OverlayViewController]()
    private var _isOverlayScreenShownNow = false
    
    private override init() {
        super.init()
    }
    
    func showOverlayScreenIfNeededForViewController(viewController: UIViewController, afterDelay delay: CGFloat) {
        let viewControllerName = NSStringFromClass(object_getClass(viewController))
       
        // check for view controller in overlayScreens dictionary of STAppSettingsManager
        guard let overlayScreensDictionary = STAppSettingsManager.sharedSettingsManager().overlayScreens as? [String:[String:AnyObject]] else {
            return
        }
        
        for (overlayKey, overlayMetaData) in overlayScreensDictionary {
            if (NSUserDefaults.standardUserDefaults().objectForKey(overlayKey) == nil) {
                guard let overlayViewControllers = overlayMetaData["viewControllers"] as? [String], let imageName = overlayMetaData["image"] as? String else {
                    continue
                }
                
                if (overlayViewControllers.contains({ $0 == viewControllerName })) {
                    // save viewController and delay variables
                    _viewController = viewController
                    animationDelay = delay
                    
                    let overlayViewController = OverlayViewController(imageName: imageName, associatedKey: overlayKey)
                    overlayViewController.delegate = self;
                    _overlayQueue.append(overlayViewController)
                    
                    showNextOverlayScreen()
                    return
                }
            }
        }
    }
    
    private func showNextOverlayScreen() {
        if _overlayQueue.count > 0 {
            if _isOverlayScreenShownNow == false {
                let overlayViewController = _overlayQueue.removeFirst()
                let delayInNano = Double(animationDelay) * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInNano))

                dispatch_after(time, dispatch_get_main_queue()) {
                    //lets find current viewcontroller
                    if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }
                        topController.presentViewController(overlayViewController, animated: true, completion: nil)
                    }
                }
 
            }
        } else {
            showOverlayScreenIfNeededForViewController(_viewController, afterDelay: animationDelay)
        }
    }
    
//MARK: OverlayViewControllerDelegate Methods
    
    // show next overlay, when the delegate method is called, that the overlayViewController is dismissed
    func didPressDismissButton(onViewController viewController: OverlayViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        _isOverlayScreenShownNow = false
        if let overlayKey = viewController.key {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: overlayKey)
            showNextOverlayScreen()
        }
    }
}