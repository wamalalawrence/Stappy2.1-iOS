//
//  GarbageTypesTableViewCell.h
//  Stappy2
//
//  Created by Denis Grebennicov on 16/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GarbageTypesTableViewCell;

@protocol GarbageTypesTableViewCellDelegate <NSObject>
- (void)garbageTypesTableViewCell:(GarbageTypesTableViewCell *)cell toggleSwitch:(UISwitch *)sender;
@end

@interface GarbageTypesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *garbageTypeSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *garbageTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *garbageTypeLabel;

@property (nonatomic, weak) id<GarbageTypesTableViewCellDelegate> delegate;

- (UIColor *)circleColorForData:(NSDictionary *)data;

- (IBAction)toggleSwitch:(id)sender;
@end
