//
//  STFahrplanApiResponseMapper.h
//  Stappy2
//
//  Created by Andrej Albrecht on 15.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STFahrplanJourneyDetail;

@interface STFahrplanApiResponseMapper : NSObject

-(NSArray*)nearbyLocationsOfResponse:(id)response error:(NSError*)error;

-(NSArray*)connectionsWithRouteOfResponse:(id)responseObject error:(NSError**)error;

-(NSArray*)departureBoardFromResponse:(id)responseObject error:(NSError**)error;

-(NSArray*)nearbyStopsOfResponse:(id)responseObject error:(NSError**)error;

-(STFahrplanJourneyDetail*)journeyDetailsOfResponse:(id)responseObject error:(NSError**)error;

@end
