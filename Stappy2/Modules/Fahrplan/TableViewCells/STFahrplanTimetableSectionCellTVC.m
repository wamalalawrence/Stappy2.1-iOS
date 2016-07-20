//
//  STFahrplanTimetableSectionCellTVC.m
//  Schwedt
//
//  Created by Andrej Albrecht on 09.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanTimetableSectionCellTVC.h"
#import "STAppSettingsManager.h"
#import "STFahrplanDeparture.h"
#import "STFahrplanTransportationTypeHelper.h"
#import "UIColor+STColor.h"

@interface STFahrplanTimetableSectionCellTVC ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *transportTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *directoryOpenedIndicatorImageView;

@end

@implementation STFahrplanTimetableSectionCellTVC

- (void)awakeFromNib {
    [self initStadtwerkLayout];
}

-(void)initStadtwerkLayout
{
    //Color
    [self.timeLabel setTextColor:[UIColor partnerColor]];

    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *titleFont = [settings customFontForKey:@"fahrplan.timetable_view.section_cell.title.font"];
    UIFont *timeFont = [settings customFontForKey:@"fahrplan.timetable_view.section_cell.time.font"];
    
    
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

-(void)setDeparture:(STFahrplanDeparture *)departure
{
    _departure = departure;
    
    NSString *title = [NSString stringWithFormat:@"%@ bis %@", departure.name, departure.direction];
    
    [self.timeLabel setText:departure.timeFormatted];
    [self.titleLabel setText:title];
    
    [self setTransportType:departure];
    
    
    //NSLog(@"---");
    //NSLog(@"   -dir:%@ name:%@ type:%@ trainNumber:%@ stopid:%@ stop:%@ date:%@ time:%@ journeyDetailRef:%@", departure.direction, departure.name, departure.type, departure.trainNumber, departure.stopid, departure.stop, departure.date,  departure.time, departure.journeyDetailRef);
    
    /*
     direction;
     @property(nonatomic,strong) NSString *name;
     @property(nonatomic,strong) NSString *trainNumber;
     @property(nonatomic,strong) NSString *trainCategory;
     @property(nonatomic,strong) NSString *stopid;
     @property(nonatomic,strong) NSString *stop;
     @property(nonatomic,strong) NSString *date;
     @property(nonatomic,strong) NSString *time;
     @property(nonatomic,strong) NSDate *datetime;
     //@property(nonatomic,strong) NSString *track;
     @property(nonatomic,strong) NSString *journeyDetailRef;
     */
}

-(void)setTransportType:(STFahrplanDeparture *)departure
{
    if ([STFahrplanTransportationTypeHelper isPedestrian:departure.type]) {
        //_transportType = @"";
        [self.transportTypeImageView setImage:[UIImage imageNamed:@"icon_content_oepnv_fussweg"]];
    }else if ([STFahrplanTransportationTypeHelper isBus:departure.type]) {
        //_transportType = @"bus";
        [self.transportTypeImageView setImage:[UIImage imageNamed:@"icon_content_oepnv_bus"]];
    }else if ([STFahrplanTransportationTypeHelper isTrain:departure.type]) {
        //_transportType = @"train";
        [self.transportTypeImageView setImage:[UIImage imageNamed:@"icon_content_oepnv_bahn"]];
    }else{
        //_transportType = @"";
        NSLog(@"TransportationType not inserted:%@", departure.type);
        
        [self.transportTypeImageView setImage:nil];
    }
    
}

@end
