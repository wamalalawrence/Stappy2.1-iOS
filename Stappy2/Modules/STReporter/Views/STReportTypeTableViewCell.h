//
//  STReportTypeTableViewCell.h
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STReportType.h"
@interface STReportTypeTableViewCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel*nameLabel;
@property(nonatomic,weak) IBOutlet UIImageView*selectionIcon;
-(void)setupWithReportType:(STReportType*)reportType;
@end
