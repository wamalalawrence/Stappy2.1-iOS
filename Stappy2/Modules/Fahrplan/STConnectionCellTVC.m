//
//  STConnectionCellTVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STConnectionCellTVC.h"
#import "STFahrplanTripModel.h"
#import "STFahrplanSubTripModel.h"
#import "UIColor+STColor.h"
#import "STAppSettingsManager.h"
#import "NSDate+Utils.h"
#import "STFahrplanTransportationTypeHelper.h"

@interface STConnectionCellTVC ()
@property (weak, nonatomic) IBOutlet UIImageView *pedestrianImageView;
@property (weak, nonatomic) IBOutlet UIImageView *trainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *busImageView;
@property (weak, nonatomic) IBOutlet UIImageView *carImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bicycleImageView;

@end

@implementation STConnectionCellTVC



- (void)awakeFromNib {
    [self initStadtwerkLayout];
}

-(void)initStadtwerkLayout
{
    //Color
    [self.departureTimeLabel setTextColor:[UIColor partnerColor]];
    
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *cellPrimaryFont = [settings customFontForKey:@"fahrplan.connection.cell_primary.font"];
    UIFont *cellSecondaryFont = [settings customFontForKey:@"fahrplan.connection.cell_secondary.font"];
    UIFont *cellStationFont = [settings customFontForKey:@"fahrplan.connection.cell_secondary.stationname.font"];
    
    if (cellPrimaryFont) {
        [self.startTimeLabel setFont:cellPrimaryFont];
        [self.targetTimeLabel setFont:cellPrimaryFont];
    }
    if (cellSecondaryFont) {
        [self.durationTimeLabel setFont:cellSecondaryFont];
        [self.departureTimeLabel setFont:cellSecondaryFont];
        [self.changeNumberLabel setFont:cellSecondaryFont];
    }
    if (cellStationFont) {
        [self.startStationNameLabel setFont:cellStationFont];
        [self.targetStationNameLabel setFont:cellStationFont];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setConnection:(STFahrplanTripModel *)connection
{
    //Cleanup
    [self.departureTimeLabel setText:@""];
    [self.changeNumberLabel setText:@""];
    [self.startTimeLabel setText:@""];
    [self.durationTimeLabel setText:@""];
    [self.targetTimeLabel setText:@""];
    [self.startStationNameLabel setText:@""];
    [self.targetStationNameLabel setText:@""];
    
    
    NSString *changeNumber = @"";
    NSUInteger changes = connection.changeNumber; //cache: cacheNumber -> changes
    if (changes > 0) {
        changeNumber = [NSString stringWithFormat:@"%lu x Umsteigen", (unsigned long)changes];
    }else{
        changeNumber = @"Kein Umsteigen";
    }
    
    NSString *durationTime = connection.duration;
    
    [self setTransportationTypes:connection];
    [self.changeNumberLabel setText:changeNumber];
    [self.durationTimeLabel setText:durationTime];
    
    if ([connection.tripStations count] > 0) {
        @try {
            STFahrplanSubTripModel *subtripFirst = connection.tripStations[0];
            STFahrplanSubTripModel *subtripLast = connection.tripStations[[connection.tripStations count]-1];
            
            NSString *startTime = subtripFirst.startPointTimeFormatted;
            
            /*
            NSString *startStationName = subtripFirst.startPointName;
            
            if ([startStationName isEqualToString:@""]) {
                startStationName = @"Abfahrt";
            }*/
            NSString *startStationName = @"Abfahrt";
            
            NSString *targetTime = subtripLast.endPointTimeFormatted;
            
            /*
            NSString *targetStationName = subtripLast.endPointName;
            
            if ([targetStationName isEqualToString:@""]) {
                targetStationName = @"Ankunft";
            }*/
            NSString *targetStationName = @"Ankunft";
            
            [self.startStationNameLabel setText:startStationName];
            [self.startTimeLabel setText:startTime];
            
            [self.targetTimeLabel setText:targetTime];
            [self.targetStationNameLabel setText:targetStationName];
            
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                                       fromDate:[[NSDate date] dateWithZeroSeconds]
                                                         toDate:[subtripFirst.startDate dateWithZeroSeconds]
                                                        options:0];
            
            //day;
            //@property NSInteger hour;
            //@property NSInteger minute;
            
            //NSLog(@"");
            
            //NSLog(@"Difference in date components: %i/%i/%i %ih %im", components.day, components.month, components.year, components.hour, components.minute);
            NSString *departureTime = @"in ";
            
            if (components.month>0) {
                departureTime = [departureTime stringByAppendingString:[NSString stringWithFormat:@"%luM ", components.month]];
            }
            
            if (components.day>0) {
                departureTime = [departureTime stringByAppendingString:[NSString stringWithFormat:@"%lud ", components.day]];
            }
            
            if (components.hour>0) {
                departureTime = [departureTime stringByAppendingString:[NSString stringWithFormat:@"%luh ", components.hour]];
            }
            
            //unsigned int minutes = 0;
            if (components.minute>0) {
                //minutes += components.minute;
                
                if (components.hour>0) {
                   departureTime = [departureTime stringByAppendingString:[NSString stringWithFormat:@"%lum ", components.minute]];
                }else{
                    departureTime = [departureTime stringByAppendingString:[NSString stringWithFormat:@"%lu min ", components.minute]];
                }
                
            }
            if (components.second>0) {
                departureTime = [departureTime stringByAppendingString:[NSString stringWithFormat:@"%lus ", components.second]];
            }
            
            
            [self.departureTimeLabel setText:departureTime];
        }
        @catch (NSException *exception) {
            NSLog(@"EXCEPTION %@", exception.description);
        }
        @finally {
            
        }
    }else{
        NSLog(@"ERROR");
    }
}

-(void)setTransportationTypes:(STFahrplanTripModel *)connection
{
    BOOL tpPedestrianFound = NO;
    BOOL tpBusFound = NO;
    BOOL tpTrainFound = NO;
    BOOL tpCarFound = NO;
    BOOL tpBicycleFound = NO;
    
    
    for (int i=0; i < [[connection tripStations] count]; i++){
        STFahrplanSubTripModel *trip = [[connection tripStations] objectAtIndex:i];
        NSString *transportType = [trip.transportationType lowercaseString];
        
        transportType = [[transportType componentsSeparatedByCharactersInSet:
                                [[NSCharacterSet letterCharacterSet] invertedSet]]
                               componentsJoinedByString:@""];
        
        if ([STFahrplanTransportationTypeHelper isPedestrian:trip.transportationType]) {
            tpPedestrianFound = YES;
            
        }else if ([STFahrplanTransportationTypeHelper isBus:trip.transportationType]) {
            tpBusFound = YES;
            
        }else if ([STFahrplanTransportationTypeHelper isTrain:trip.transportationType]) {
            tpTrainFound = YES;
            
        }
        /*
        else if ([trip isCar]) {
            tpCarFound = YES;
            
        }
        */
    }
    
    if (!tpPedestrianFound) {
        self.pedestrianImageView.hidden = YES;
        [self.pedestrianImageView removeFromSuperview];
    }
    if (!tpBusFound) {
        self.busImageView.hidden = YES;
        [self.busImageView removeFromSuperview];
    }
    if (!tpTrainFound) {
        self.trainImageView.hidden = YES;
        [self.trainImageView removeFromSuperview];
    }
    if (!tpCarFound) {
        self.carImageView.hidden = YES;
        [self.carImageView removeFromSuperview];
    }
    if (!tpBicycleFound) {
        self.bicycleImageView.hidden = YES;
        [self.bicycleImageView removeFromSuperview];
    }
}

@end
