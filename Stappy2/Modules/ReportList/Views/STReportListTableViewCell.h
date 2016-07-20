//
//  XMLListTableViewCell.h
//  Stappy2
//
//  Created by Pavel Nemecek on 26/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  STReportListModel;
@interface STReportListTableViewCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel*titleLabel;
@property(nonatomic,weak) IBOutlet UILabel*descriptionLabel;
@property(nonatomic,weak) IBOutlet UILabel*dateLabel;

-(void)setupWithReportListModel:(STReportListModel*)reportListModel;
@end
