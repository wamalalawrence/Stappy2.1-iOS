//
//  STAdressSearchResultCellTVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STAdressSearchResultCellTVC.h"
#import "STAppSettingsManager.h"
#import "STFahrplanLocation.h"

@implementation STAdressSearchResultCellTVC

- (void)awakeFromNib {
    [self initStadtwerkLayout];
}

-(void)initStadtwerkLayout
{
    //Color
    //[self.title setTextColor:[UIColor partnerColor]];
    
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *cellPrimaryFont = [settings customFontForKey:@"fahrplan.location_finder_overlay.cell.primary.font"];

    if (cellPrimaryFont) {
        [self.title setFont:cellPrimaryFont];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setLocation:(STFahrplanLocation *)location
{
    _location = location;
    
    [self.title setText:location.locationName];
}

@end
