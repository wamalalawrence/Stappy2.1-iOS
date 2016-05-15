//
//  STLokalNewsHeaderView.m
//  Schwedt
//
//  Created by Andrei Neag on 01.02.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STLokalNewsHeaderView.h"
#import "STAppSettingsManager.h"

@implementation STLokalNewsHeaderView

- (void)awakeFromNib {
    // Initialization code
    
    [self initStadtwerkLayout];
}

-(void)initStadtwerkLayout
{
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *dateLabelFont = [settings customFontForKey:@"lokalnews.header_view.dateLabel.font"];
    UIFont *weekDayLabelFont = [settings customFontForKey:@"lokalnews.header_view.weekDayLabel.font"];
    UIFont *weatherLabelFont = [settings customFontForKey:@"lokalnews.header_view.weekDayLabel.font"];

    
    if (dateLabelFont) {
        [self.dateLabel setFont:dateLabelFont];
    }
    
    if (weekDayLabelFont) {
        [self.weekdayLabel setFont:weekDayLabelFont];
    }
    if (weatherLabelFont) {
        [self.weatherLabel setFont:weatherLabelFont];
    }
}

@end
