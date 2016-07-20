//
//  STStadtInfoTableViewCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 25/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STParkHausTableViewCell.h"
#import "STAppSettingsManager.h"
#import "NSDate+DKHelper.h"
#import "NSDate+Utils.h"
#import "UIImage+tintImage.h"
#import "UIColor+STColor.h"
#import "OpeningClosingTimeModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "STRequestsHandler.h"
@implementation STParkHausTableViewCell

- (void)awakeFromNib {
    // Initialization code

    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *tileFont = [settings customFontForKey:@"stadtinfos.cell.font"];
    UIFont *headerFont = [settings customFontForKey:@"stadtinfos.cell.headerFont"];
    if (tileFont) [self.titleLabel setFont:tileFont];
    if (headerFont) {
        [self.openingTimeLabel setFont:headerFont];
        self.freeLabel.font = headerFont;
    }
    [self.openingTimeLabel setTextColor:[UIColor partnerColor]];
}

-(void)setupWithParkHaus:(STGeneralParkhausModel*)parkHaus location:(CLLocation*)location{
    
    //calculate distance from location
    CLLocation *current = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    
    CLLocation *itemLoc = [[CLLocation alloc] initWithLatitude:parkHaus.latitude longitude:parkHaus.longitude];
    
    //get distance from current position in km
    CLLocationDistance itemDist = [itemLoc distanceFromLocation:current] / 1000.0;
    NSString *distanceString = [[NSString alloc] initWithFormat: @"%.01f km", itemDist];
    self.distanceLabel.text = [distanceString stringByReplacingOccurrencesOfString:@"." withString:@","];
    
    
    //calculate remaining opening time
    if (parkHaus.openinghours2 != nil) {
        //get day of the week
        NSInteger day = [[NSDate date] dayOfTheWeek];
        OpeningClosingTimesModel* closingTimes = (OpeningClosingTimesModel*)(parkHaus.openinghours2[0]);
        NSArray<OpeningClosingTimeModel *> *remainingTimeModelArray = [closingTimes openingHoursForDay:day];
        
        BOOL isOpened = NO;
        for (OpeningClosingTimeModel *timeModel in remainingTimeModelArray) {
            if (timeModel.remainingOpeningHours > 0) {
                self.openingTimeLabel.text = [NSString stringWithFormat:@"%ld Std %ld min", (long)timeModel.remainingOpeningHours,
                                         (long)timeModel.remainingOpeningMinutes];
                isOpened = YES;
            } else if (timeModel.remainingOpeningHours == 0 && timeModel.remainingOpeningMinutes > 0) {
                self.openingTimeLabel.text = [NSString stringWithFormat:@"%ld min", (long)timeModel.remainingOpeningMinutes];
                isOpened = YES;
            }
        }
        
        parkHaus.isOpen = isOpened;
        
        if (isOpened) {
            UIImage* openingImage = [[UIImage imageNamed:@"OpeningIcon"] imageTintedWithColor:[UIColor partnerColor]];
            self.closingOpeningImageView.image = openingImage;
            self.openingTimeLabel.textColor = [UIColor partnerColor];
        } else {
            self.closingOpeningImageView.image = [UIImage imageNamed:@"ClosingIcon"];
            self.openingTimeLabel.text = @"Geschlossen";
            self.openingTimeLabel.textColor = [UIColor whiteColor];
        }
    } else {
        /**
         * reset the icon and openingTimeLabel. This will be needed when we use VonZBisA-Sort
         * we reload the tableView after reordering, but the data in the cell won't be reseted
         * so the cell will contain the data, from the previous model, what is no good
         */
        self.closingOpeningImageView = nil;
        self.openingTimeLabel.text = @"";
    }
    
    self.titleLabel.text = parkHaus.title;
    NSURL *imageUrl;
    if (parkHaus.image != nil && parkHaus.image.length > 0) {
        if ([[parkHaus.image substringToIndex:1] isEqualToString:@"/"]) {
            //build image url
            imageUrl = [[STRequestsHandler sharedInstance] buildImageUrl:parkHaus.image];
        }
        else {
            imageUrl = [NSURL URLWithString:parkHaus.image];
        }
    }
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.coverImageView sd_setImageWithURL:imageUrl  placeholderImage:[UIImage imageNamed:@"image_content_article_default_thumb"]];
    self.freeLabel.text = [NSString stringWithFormat:@"freie Plätze: %ld/%ld",parkHaus.freePlaces,parkHaus.capacity];
    

}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.coverImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
