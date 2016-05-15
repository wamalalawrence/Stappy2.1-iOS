//
//  DepartureAndArrivalDatetimeChooserView.m
//  Schwedt
//
//  Created by Andrej Albrecht on 01.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanDatetimeChooserView.h"
#import "UIColor+STColor.h"
#import "STAppSettingsManager.h"

@interface STFahrplanDatetimeChooserView ()
@property (strong, nonatomic) NSString *departureOrArrival;
@property (strong, nonatomic) NSDate *changedDate;
@end

@implementation STFahrplanDatetimeChooserView

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
    
    //[self.datePicker setDate:[NSDate date]];
    self.departureOrArrival = @"departure";
}


#pragma mark - Layout

-(void)initStadtwerkLayout
{
    //Color
    //[self.timeLabel setTextColor:[UIColor partnerColor]];
    
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *cellPrimaryFont = [settings customFontForKey:@"fahrplan.datetime_chooser.primary.font"];

    if (cellPrimaryFont) {
        [self.departureButton.titleLabel setFont:cellPrimaryFont];
        [self.arrivalButton.titleLabel setFont:cellPrimaryFont];
    }
}


#pragma mark - Properties

-(void)setToDeparture
{
    if (![self.departureOrArrival isEqualToString:@"departure"]) {
        [self changeButtonAlpha];
    }
    _departureOrArrival = @"departure";
}

-(void)setToArrival
{
    if (![self.departureOrArrival isEqualToString:@"arrival"]) {
        [self changeButtonAlpha];
    }
    _departureOrArrival = @"arrival";
}

#pragma mark - Actions

- (IBAction)actionSetToDeparture:(id)sender {
    NSLog(@"actionSetToDeparture");
    
    if (![self.departureOrArrival isEqualToString:@"departure"]) {
        [self setToDeparture];
        //[self.delegate departureAndArrivalDateTime:self departureDatetimeChangedTo:self.datePicker.date];
    }
}

- (IBAction)actionSetToArrival:(id)sender {
    NSLog(@"actionSetToArrival");
    
    if (![self.departureOrArrival isEqualToString:@"arrival"]) {
        [self setToArrival];
        //[self.delegate departureAndArrivalDateTime:self arrivalDatetimeChangedTo:self.datePicker.date];
    }
}

- (IBAction)actionAbort:(id)sender {
    NSLog(@"actionAbort");
    
    self.changedDate = nil;
    
    [self.delegate departureAndArrivalDateTime:self departureAndArrivalDateTimeOnClose:NO];
}

- (IBAction)actionSave:(id)sender {
    NSLog(@"actionSave");
    
    if (self.departureOrArrival && [self.departureOrArrival isEqualToString:@"arrival"]) {
        [self.delegate departureAndArrivalDateTime:self arrivalDatetimeChangedTo:self.datePicker.date];
    }else{
        [self.delegate departureAndArrivalDateTime:self departureDatetimeChangedTo:self.datePicker.date];
    }
    
    [self.delegate departureAndArrivalDateTime:self departureAndArrivalDateTimeOnClose:YES];
}

- (IBAction)datePickerValueChanged:(id)sender {
    NSLog(@"datePickerValueChanged:%@", self.datePicker.date);
    
    self.changedDate = self.datePicker.date;
}

- (IBAction)actionAdd5Min:(id)sender {
    self.datePicker.date = [self.datePicker.date dateByAddingTimeInterval:60*5];
}

- (IBAction)actionAdd15Min:(id)sender {
    self.datePicker.date = [self.datePicker.date dateByAddingTimeInterval:60*15];
}

- (IBAction)actionAdd30Min:(id)sender {
    self.datePicker.date = [self.datePicker.date dateByAddingTimeInterval:60*30];
}


#pragma mark - Logic

-(void)changeButtonAlpha
{
    UIColor *oldDepButtonBackground = self.departureButton.backgroundColor;
    [self.departureButton setBackgroundColor:self.arrivalButton.backgroundColor];
    [self.arrivalButton setBackgroundColor:oldDepButtonBackground];
}

@end
