//
//  STReportAddressTableViewCell.h
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPrediction.h"
@interface STReportAddressTableViewCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel*addressLabel;

-(void)setupWithPrediction:(STPrediction*)predition;

@end
