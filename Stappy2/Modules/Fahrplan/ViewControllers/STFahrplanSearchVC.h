//
//  STFahrplanSearchVC.h
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STFahrplanLocationNameFinderOverlayVC.h"
#import "STFahrplanJourneyPlannerService.h"
#import "STViewController.h"

@class MKMapView;
//STViewController
@interface STFahrplanSearchVC : UIViewController <STFahrplanLocationNameFinderDelegate, STFahrplanJourneyPlannerServiceDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightbarButton;
@property (weak, nonatomic) IBOutlet UILabel *startAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetAddressLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)nextAction:(id)sender;

@end
