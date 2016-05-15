//
//  STParkingDetailsViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 12/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STNewsAndEventsDetailViewController.h"

@class STParkHausModel;

@interface STParkingDetailsViewController : STNewsAndEventsDetailViewController
@property (weak, nonatomic) IBOutlet UIImageView *parkingImge;
@property (weak, nonatomic) IBOutlet UIWebView *openinHoursWebView;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDataModel:(STParkHausModel *)dataModel;
@end
