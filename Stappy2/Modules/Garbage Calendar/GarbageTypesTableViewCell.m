//
//  GarbageTypesTableViewCell.m
//  Stappy2
//
//  Created by Denis Grebennicov on 16/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "GarbageTypesTableViewCell.h"

#import <DKHelper/DKHelper.h>

#import "Stappy2-Swift.h"

@implementation GarbageTypesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (UIColor *)circleColorForData:(NSDictionary *)data
{
    NSString *garbageEnum = data[@"enum"];
    
    if ([garbageEnum isEqualToString:@"SONDER"]) return [UIColor colorFromHexString:@"#e58700"];
    else if ([garbageEnum isEqualToString:@"GSACK"]) return [UIColor colorFromHexString:@"#ffc600"];
    else if ([garbageEnum isEqualToString:@"PAPIER"]) return [UIColor colorFromHexString:@"#0060cc"];
    else if ([garbageEnum isEqualToString:@"BIO"]) return [UIColor colorFromHexString:@"#007e32"];
    else if ([garbageEnum isEqualToString:@"REST"]) return [UIColor colorFromHexString:@"#000000"];
    else return nil;
}

- (IBAction)toggleSwitch:(id)sender
{
    [_delegate garbageTypesTableViewCell:self toggleSwitch:sender];
}

@end
