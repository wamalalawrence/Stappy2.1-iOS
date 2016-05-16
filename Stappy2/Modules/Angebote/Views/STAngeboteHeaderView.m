//
//  STAngeboteHeaderView.m
//  Schwedt
//
//  Created by Denis Grebennicov on 09/02/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STAngeboteHeaderView.h"
#import "STAppSettingsManager.h"

@implementation STAngeboteHeaderView

- (void)awakeFromNib {
    // Initialization code
    [self initLayout];
}

-(void)initLayout
{
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *categoryLabelFont = [settings customFontForKey:@"angebote.header_view.category.font"];
    if (categoryLabelFont) {
        [self.categoryLabel setFont:categoryLabelFont];
    }
}
@end
