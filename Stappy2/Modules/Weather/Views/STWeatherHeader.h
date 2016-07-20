//
//  WeatherCustomHeaderView.h
//  Stappy2
//
//  Created by Cynthia Codrea on 11/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STWeatherHeader : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIView *headerBackgroundView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weatherChangeSegmentedControl;

@end
