//
//  STRegionPickerSettingsView.m
//  Stappy2
//
//  Created by Denis Grebennicov on 21/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STRegionPickerSettingsView.h"
#import "STAppSettingsManager.h"
@implementation STRegionPickerSettingsView

#pragma mark - Initializers

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self setup];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    
    return self;
}

- (void)setup
{
    
    
    UIView *view = [[NSBundle mainBundle] loadNibNamed:@"STRegionPickerSettingsView" owner:self options:nil].firstObject;
    view.frame = self.bounds;
    [self addSubview:view];
    
    _selectRegionsButton.layer.borderWidth = 1;
    _selectRegionsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UIFont* buttonTextFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.buttonText.font"];

    if (buttonTextFont) {
        _settingsLabel.font = buttonTextFont;
        _selectRegionsButton.titleLabel.font = buttonTextFont;
    }
    
}

#pragma mark -

- (IBAction)selectRegionsButtonPressed:(id)sender
{
    [_delegate regionsButtonWasPressed];
}

@end
