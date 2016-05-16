//
//  STFahrplanTimetableJourneyStopCellTVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 17.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanTimetableJourneyStopCellTVC.h"
#import "STAppSettingsManager.h"
#import "UIColor+STColor.h"
#import "STFahrplanJourneyStop.h"

@interface STFahrplanTimetableJourneyStopCellTVC()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation STFahrplanTimetableJourneyStopCellTVC

- (void)awakeFromNib {
    // Initialization code
    [self initStadtwerkLayout];
}

-(void)initStadtwerkLayout
{
    //Color
    [self.timeLabel setTextColor:[UIColor partnerColor]];
    
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *titleFont = [settings customFontForKey:@"fahrplan.timetable_view.cell.title.font"];
    UIFont *timeFont = [settings customFontForKey:@"fahrplan.timetable_view.cell.time.font"];
    
    if (titleFont) {
        [self.titleLabel setFont:titleFont];
    }
    if (timeFont) {
        [self.timeLabel setFont:timeFont];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setJourneyStop:(STFahrplanJourneyStop *)journeyStop
{
    _journeyStop = journeyStop;
    
    [self.titleLabel setText:journeyStop.name];
    [self.timeLabel setText:[NSString stringWithFormat:@"%@", journeyStop.depTime]];
}

@end
