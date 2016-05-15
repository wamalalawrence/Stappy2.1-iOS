//
//  STFahrplanConnectionsVC.h
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STFahrplanLocationNameFinderOverlayVC.h"
#import "STFahrplanNearbyStopLocation.h"
#import "STFahrplanJourneyPlannerService.h"

@interface STFahrplanConnectionsVC : UIViewController<STFahrplanLocationNameFinderDelegate, STFahrplanJourneyPlannerServiceDelegate>


@end
