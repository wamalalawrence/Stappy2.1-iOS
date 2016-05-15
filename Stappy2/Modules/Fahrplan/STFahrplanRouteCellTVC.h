//
//  STFahrplanRouteCellTVC.h
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STFahrplanSubTripModel;

@interface STFahrplanRouteCellTVC : UITableViewCell

@property (weak,nonatomic) STFahrplanSubTripModel *trip;

@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startStationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *startStationPlatform;
@property (weak, nonatomic) IBOutlet UILabel *directionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetStationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetStationPlatformLabel;


@end
