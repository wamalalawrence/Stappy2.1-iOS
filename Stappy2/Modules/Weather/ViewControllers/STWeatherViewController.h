//
//  STWeatherViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 06/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTGlassScrollView.h"

@interface STWeatherViewController : UIViewController <UIScrollViewDelegate,BTGlassScrollViewDelegate>

@property (nonatomic, strong) NSString *region;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet UIView *topDateContainer;
@property (weak, nonatomic) IBOutlet UILabel *dateContainerLabel;
@property (weak, nonatomic) IBOutlet RandomImageView *backgroundBlurrImageView;

@end
