//
//  STFahrplanOriginDestinationWithTimeView.m
//  Schwedt
//
//  Created by Andrej Albrecht on 02.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanDepartureArrivalDisplayView.h"
#import "UIColor+STColor.h"
#import "STAppSettingsManager.h"

@implementation STFahrplanDepartureArrivalDisplayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviewFromNib];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSubviewFromNib];
    }
    return self;
}

- (UIView *)viewFromNib
{
    Class class = [self class];
    NSString *nibName = NSStringFromClass(class);
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    UIView *view = [nibViews objectAtIndex:0];
    return view;
}

- (void)addSubviewFromNib
{
    UIView *view = [self viewFromNib];
    view.frame = self.bounds;
    [self addSubview:view];
    
    [self initStadtwerkLayout];
    
}

#pragma mark - Layout

-(void)initStadtwerkLayout
{
    //Color
    [self.timeLabel setTextColor:[UIColor partnerColor]];
    
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *cellTextInputPrimaryFont = [settings customFontForKey:@"fahrplan.departure_arrival_display.textinput.primary.font"];
    UIFont *cellTimePrimaryFont = [settings customFontForKey:@"fahrplan.departure_arrival_display.time.primary.font"];
    UIFont *cellDatePrimaryFont = [settings customFontForKey:@"fahrplan.departure_arrival_display.date.primary.font"];
    UIFont *cellDepartureArrivalPrimaryFont = [settings customFontForKey:@"fahrplan.departure_arrival_display.departurearrival.primary.font"];
    
    if (cellTextInputPrimaryFont) {
        [self.originAddress setFont:cellTextInputPrimaryFont];
        [self.destinationAddress setFont:cellTextInputPrimaryFont];
    }
    if (cellTimePrimaryFont) {
        [self.timeLabel setFont:cellTimePrimaryFont];
    }
    if (cellDatePrimaryFont) {
        [self.dateLabel setFont:cellDatePrimaryFont];
    }
    if (cellDepartureArrivalPrimaryFont) {
        [self.departureArrivalLabel setFont:cellDepartureArrivalPrimaryFont];
    }
}

#pragma mark - Actions

- (IBAction)timeClickAction:(id)sender {
    [self.delegate departureArrivalDisplayViewOnTimeClick:self];
}

- (IBAction)originAddressAction:(id)sender {
    [self.delegate departureArrivalDisplayViewOnOriginAddressClick:self];
}

- (IBAction)destinationAddressAction:(id)sender {
    [self.delegate departureArrivalDisplayViewOnDestinationAddressClick:self];
}

#pragma mark - Logic



@end
