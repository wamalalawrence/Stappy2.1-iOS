//
//  STFahrplanTimetableSectionCellTVC.h
//  Schwedt
//
//  Created by Andrej Albrecht on 09.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STFahrplanDeparture;

@interface STFahrplanTimetableSectionCellTVC : UITableViewCell

@property (nonatomic,strong) STFahrplanDeparture *departure;

@end
