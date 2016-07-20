//
//  XMLListTableViewCell.h
//  Stappy2
//
//  Created by Pavel Nemecek on 26/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  STXMLFeedModel;
@interface STXMLListTableViewCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel*titleLabel;
@property(nonatomic,weak) IBOutlet UILabel*descriptionLabel;
@property(nonatomic,weak) IBOutlet UILabel*dateLabel;

-(void)setupWithFeedModel:(STXMLFeedModel*)feedModel;
@end
