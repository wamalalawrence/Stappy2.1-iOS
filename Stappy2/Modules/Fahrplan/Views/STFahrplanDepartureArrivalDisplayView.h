//
//  STFahrplanOriginDestinationWithTimeView.h
//  Schwedt
//
//  Created by Andrej Albrecht on 02.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STFahrplanDepartureArrivalDisplayView;

@protocol STFahrplanDepartureArrivalDisplayDelegate <NSObject>
@optional
-(void)departureArrivalDisplayViewOnTimeClick:(STFahrplanDepartureArrivalDisplayView *)container;
-(void)departureArrivalDisplayViewOnOriginAddressClick:(STFahrplanDepartureArrivalDisplayView *)container;
-(void)departureArrivalDisplayViewOnDestinationAddressClick:(STFahrplanDepartureArrivalDisplayView *)container;
@end


@interface STFahrplanDepartureArrivalDisplayView : UIView

@property (weak, nonatomic) IBOutlet UILabel *originAddress;
@property (weak, nonatomic) IBOutlet UILabel *destinationAddress;
@property (weak, nonatomic) IBOutlet UILabel *departureArrivalLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) id<STFahrplanDepartureArrivalDisplayDelegate> delegate;


@end
