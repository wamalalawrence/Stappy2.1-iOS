//
//  STStadtInfoTableViewCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 25/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STParkHausTableViewCell.h"
#import "STAppSettingsManager.h"
#import "UIColor+STColor.h"

@implementation STParkHausTableViewCell

- (void)awakeFromNib {
    // Initialization code

    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *tileFont = [settings customFontForKey:@"stadtinfos.cell.font"];
    UIFont *headerFont = [settings customFontForKey:@"stadtinfos.cell.headerFont"];
    if (tileFont) [self.titleLabel setFont:tileFont];
    if (headerFont) {
        [self.openingTimeLabel setFont:headerFont];
    }
    [self.openingTimeLabel setTextColor:[UIColor partnerColor]];
}

-(void)setupWithParkHaus:(STGeneralParkhausModel*)parkHaus location:(CLLocation*)location{
    
    //calculate distance from location
    CLLocation *current = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    
    CLLocation *itemLoc = [[CLLocation alloc] initWithLatitude:parkHaus.latitude longitude:parkHaus.longitude];
    
    //get distance from current position in km
    CLLocationDistance itemDist = [itemLoc distanceFromLocation:current] / 1000.0;
    NSString *distanceString = [[NSString alloc] initWithFormat: @"%.01f km", itemDist];
    self.distanceLabel.text = [distanceString stringByReplacingOccurrencesOfString:@"." withString:@","];


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
