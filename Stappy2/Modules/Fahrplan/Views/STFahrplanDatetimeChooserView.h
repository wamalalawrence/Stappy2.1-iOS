//
//  DepartureAndArrivalDatetimeChooserView.h
//  Schwedt
//
//  Created by Andrej Albrecht on 01.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STFahrplanDatetimeChooserView;

@protocol STFahrplanDatetimeChooserDelegate <NSObject>
@optional
-(void)departureAndArrivalDateTime:(STFahrplanDatetimeChooserView *)container departureAndArrivalDateTimeOnClose:(BOOL)save;
-(void)departureAndArrivalDateTime:(STFahrplanDatetimeChooserView *)container departureDatetimeChangedTo:(NSDate *)date;
-(void)departureAndArrivalDateTime:(STFahrplanDatetimeChooserView *)container arrivalDatetimeChangedTo:(NSDate *)date;
@end

@interface STFahrplanDatetimeChooserView : UIView
@property (weak, nonatomic) IBOutlet UIButton *departureButton;
@property (weak, nonatomic) IBOutlet UIButton *arrivalButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) id<STFahrplanDatetimeChooserDelegate> delegate;

-(void)setToDeparture;
-(void)setToArrival;

@end

