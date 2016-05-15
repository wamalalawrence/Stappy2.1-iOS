//
//  GarbageDateTableViewCell.h
//  Stappy2
//
//  Created by Denis Grebennicov on 16/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GarbageDateTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *garbageImageView;
@property (weak, nonatomic) IBOutlet UILabel *garbageLabel;

@property (weak, nonatomic) IBOutlet UIView *dataView;

- (void)cornerRadiusForCorners:(UIRectCorner)rectCorner;
- (UIColor *)circleColorForData:(NSDictionary *)data;

- (UIView *)circle;

@end
