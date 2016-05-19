//
//  STFahrplanRouteCellTVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanRouteCellTVC.h"
#import "STFahrplanSubTripModel.h"
#import "UIColor+STColor.h"
#import "STAppSettingsManager.h"
#import "STFahrplanTransportationTypeHelper.h"

@interface STFahrplanRouteCellTVC ()
@property (weak, nonatomic) IBOutlet UIImageView *transportTypeImageView;


@end

@implementation STFahrplanRouteCellTVC

- (void)awakeFromNib {
    [self initStadtwerkLayout];
}

-(void)initStadtwerkLayout
{
    //Color
    [self.startTimeLabel setTextColor:[UIColor partnerColor]];
    [self.targetTimeLabel setTextColor:[UIColor partnerColor]];
    
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *cellPrimaryFont = [settings customFontForKey:@"fahrplan.route.cell_primary.font"];
    UIFont *cellSecondaryFont = [settings customFontForKey:@"fahrplan.route.cell_secondary.font"];
    if (cellPrimaryFont) {
        [self.startTimeLabel setFont:cellPrimaryFont];
        [self.startStationNameLabel setFont:cellPrimaryFont];
        
        [self.targetTimeLabel setFont:cellPrimaryFont];
        [self.targetStationNameLabel setFont:cellPrimaryFont];
  
    }
    if (cellSecondaryFont) {
        [self.targetStationPlatformLabel setFont:cellSecondaryFont];
        [self.startStationPlatform setFont:cellSecondaryFont];
        [self.directionNameLabel setFont:cellSecondaryFont];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTrip:(STFahrplanSubTripModel *)trip
{
    _trip = trip;
    
    [self.startTimeLabel setText:trip.startPointTimeFormatted];
    [self.startStationNameLabel setText:trip.startPointName];
    
    if (trip.startTrack && ![trip.startTrack isEqualToString:@""]) {
        NSString *startStationPlatform = @"";
        
        if ([STFahrplanTransportationTypeHelper isTrain:trip.transportationType]) {
            startStationPlatform = [startStationPlatform stringByAppendingString:@"Gl."];
        } else if ([STFahrplanTransportationTypeHelper isBus:trip.transportationType]) {
            startStationPlatform = [startStationPlatform stringByAppendingString:@"St."];
        }
        
        startStationPlatform = [startStationPlatform stringByAppendingString:[NSString stringWithFormat:@"%@",trip.startTrack]];
        
        [self.startStationPlatform setText:startStationPlatform];//Gl. %@
    }else{
        [self.startStationPlatform setText:@""];
    }
    
    NSString *directionNameValue = @"";
    if (trip.transportationName && ![trip.transportationName isEqualToString:@""]) {
        directionNameValue = [[NSString stringWithFormat:@"%@ ", trip.transportationName] stringByReplacingOccurrencesOfString:@" " withString:@""];
        //[trip.transportationName stringByReplacingOccurrencesOfString:@" " withString:@""]
    }
    if (trip.direction && ![trip.direction isEqualToString:@""]) {
        directionNameValue = [NSString stringWithFormat:@"%@ Richtung %@", directionNameValue, trip.direction];
    }else if ([STFahrplanTransportationTypeHelper isPedestrian:trip.transportationType]) {
        NSString *string = [NSString stringWithFormat:@"%@Fußweg",@""];
        
        directionNameValue = string;
    }
    [self.directionNameLabel setText:directionNameValue];
    
    [self.targetTimeLabel setText:trip.endPointTimeFormatted];
    [self.targetStationNameLabel setText:trip.endPointName];
    
    if (trip.endTrack && ![trip.endTrack isEqualToString:@""]) {
        NSString *targetStationPlatform = @"";
        if ([STFahrplanTransportationTypeHelper isTrain:trip.transportationType]) {
            targetStationPlatform = [targetStationPlatform stringByAppendingString:@"Gl."];
        } else if ([STFahrplanTransportationTypeHelper isBus:trip.transportationType]) {
            targetStationPlatform = [targetStationPlatform stringByAppendingString:@"St."];
        }
        
        targetStationPlatform = [targetStationPlatform stringByAppendingString:[NSString stringWithFormat:@"%@",trip.endTrack]];
        
        [self.targetStationPlatformLabel setText:targetStationPlatform];//Gl. %@
    }else{
        [self.targetStationPlatformLabel setText:@""];
    }
    
    [self setTransportType:trip];
}

-(void)setTransportType:(STFahrplanSubTripModel *)trip
{
    //NSString *tp = trip.transportationType;
    //_transportType = tp;
    
    //tp = [tp lowercaseString];
    
    //tp = [[tp componentsSeparatedByCharactersInSet:
    //                  [[NSCharacterSet letterCharacterSet] invertedSet]]
    //                 componentsJoinedByString:@""];
    
    if ([STFahrplanTransportationTypeHelper isPedestrian:trip.transportationType]) {
        //_transportType = @"";
        [self.transportTypeImageView setImage:[UIImage imageNamed:@"icon_content_oepnv_fussweg"]];
    }else if ([STFahrplanTransportationTypeHelper isBus:trip.transportationType]) {
        //_transportType = @"bus";
        [self.transportTypeImageView setImage:[UIImage imageNamed:@"icon_content_oepnv_bus"]];
    }else if ([STFahrplanTransportationTypeHelper isTrain:trip.transportationType]) {
        //_transportType = @"train";
        [self.transportTypeImageView setImage:[UIImage imageNamed:@"icon_content_oepnv_bahn"]];
    }else{
        //_transportType = @"";
        NSLog(@"TransportationType not inserted:%@", trip.transportationType);
        
        [self.transportTypeImageView setImage:nil];
    }
    
}

@end
