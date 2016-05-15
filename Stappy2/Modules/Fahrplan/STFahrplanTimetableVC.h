//
//  STFahrplanTimetableVC.h
//  Schwedt
//
//  Created by Andrej Albrecht on 09.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STFahrplanNearbyStopLocation;

@interface STFahrplanTimetableVC : UIViewController

@property(strong,nonatomic) STFahrplanNearbyStopLocation *location;

@end
