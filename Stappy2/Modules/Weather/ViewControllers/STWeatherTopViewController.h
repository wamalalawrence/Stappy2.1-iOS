//
//  STWeatherTopViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 07/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STWeatherCurrentObservation;
@class STWeatherHeader;

@interface STWeatherTopViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView *weatherTable;
@property (weak, nonatomic) IBOutlet UIView *currentObservationContainer;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;
@property (weak, nonatomic) IBOutlet UIImageView *currentWeatherIcon;
@property (weak, nonatomic) IBOutlet UILabel *currentTemperature;
@property (weak, nonatomic) IBOutlet UILabel *currentCondition;
@property (weak, nonatomic) IBOutlet UILabel *currentRainCondition;
@property (weak, nonatomic) IBOutlet UILabel *currentWindCondition;
@property (strong, nonatomic) STWeatherHeader *weatherHeader;
@property (nonatomic, assign) BOOL showHeader;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hourlyData:(NSArray*)hourlyData nextDAysData:(NSArray*)nextDaysData andObservation:(STWeatherCurrentObservation*)observation;
@end
