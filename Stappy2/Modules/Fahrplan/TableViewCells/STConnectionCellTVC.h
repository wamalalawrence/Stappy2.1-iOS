//
//  STConnectionCellTVC.h
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STFahrplanTripModel;

@interface STConnectionCellTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startStationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetStationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *departureTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeNumberLabel;
@property (weak, nonatomic) STFahrplanTripModel *connection;

@end
