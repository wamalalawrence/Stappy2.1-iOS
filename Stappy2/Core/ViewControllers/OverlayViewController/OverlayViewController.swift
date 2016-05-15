//
//  OverlayViewController.swift
//  Stappy2
//
//  Created by Denis Grebennicov on 26/02/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

import Foundation

protocol OverlayViewControllerDelegate: NSObjectProtocol {
    func didPressDismissButton(onViewController viewController: OverlayViewController)
}

@objc class OverlayViewController: UIViewController {
    var overlayImage: UIImage?
    var key: String?
    var delegate: OverlayViewControllerDelegate?
    
    init(imageName: String) {
        overlayImage = UIImage(named: imageName)
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(imageName: String, associatedKey: String) {
        self.init(imageName: imageName)
        key = associatedKey
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.clearColor()
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        
        if #available(iOS 8.0, *) {
            self.modalPresentationStyle = .OverCurrentContext
        } else {
            // Fallback on earlier versions
        }
        
        let overlayImageView = UIImageView.init(image: overlayImage)
        overlayImageView.frame = self.view.bounds
        self.view.addSubview(overlayImageView)
        overlayImageView.contentMode = .ScaleAspectFit

        let closeButton = UIButton.init(type: .Custom)
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.whiteColor().CGColor
        closeButton.layer.cornerRadius = 3
        closeButton.frame = CGRectMake(20, CGRectGetHeight(UIScreen.mainScreen().bounds) - 68, CGRectGetWidth(UIScreen.mainScreen().bounds) - 40, 48)
        self.view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: "dismissButtonPressed", forControlEvents: .TouchDown)
        closeButton.setTitle("Ok, verstanden!", forState: .Normal)
        closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        closeButton.titleLabel?.font = STAppSettingsManager.sharedSettingsManager().customFontForKey("overlayScreen.button.font")
        
        self.view.alpha = 0.9
    }
    
    func dismissButtonPressed() {
        delegate?.didPressDismissButton(onViewController: self)
    }
}