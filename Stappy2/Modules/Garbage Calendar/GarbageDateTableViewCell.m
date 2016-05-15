//
//  GarbageDateTableViewCell.m
//  Stappy2
//
//  Created by Denis Grebennicov on 16/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "GarbageDateTableViewCell.h"

#import <DKHelper/DKHelper.h>

@interface GarbageDateTableViewCell ()
@property (nonatomic, strong) UIView *circle;
@end

@implementation GarbageDateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (UIColor *)circleColorForData:(NSDictionary *)data
{
    NSString *garbageEnum = data[@"type"];
    
    if ([garbageEnum isEqualToString:@"SONDER"]) return [UIColor colorFromHexString:@"#e58700"];
    else if ([garbageEnum isEqualToString:@"GSACK"]) return [UIColor colorFromHexString:@"#ffc600"];
    else if ([garbageEnum isEqualToString:@"PAPIER"]) return [UIColor colorFromHexString:@"#0060cc"];
    else if ([garbageEnum isEqualToString:@"BIO"]) return [UIColor colorFromHexString:@"#007e32"];
    else if ([garbageEnum isEqualToString:@"REST"]) return [UIColor colorFromHexString:@"#000000"];
    else return nil;
}

- (void)cornerRadiusForCorners:(UIRectCorner)rectCorner
{
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_dataView.frame
//                                                   byRoundingCorners:rectCorner
//                                                         cornerRadii:CGSizeMake(3.0, 3.0)];
//
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = _dataView.frame;
//    maskLayer.path = maskPath.CGPath;
//    _dataView.layer.mask = maskLayer;
    _dataView.layer.cornerRadius = 3.0;
}

- (UIView *)circle
{
    if (!_circle)
    {
        CGRect circleFrame = _garbageImageView.frame;
        circleFrame.origin.x -= 2;
        circleFrame.origin.y -= 2;
        circleFrame.size.width  += 4;
        circleFrame.size.height += 4;
        
        _circle = [[UIView alloc] initWithFrame:circleFrame];
        [_dataView addSubview:_circle];
        [_dataView sendSubviewToBack:_circle];
    }
    
    return _circle;
}

@end
