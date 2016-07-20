//
//  STFahrplanNearbyStopLocation.h
//  Schwedt
//
//  Created by Andrej Albrecht on 09.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STFahrplanNearbyStopLocation : MTLModel <MTLJSONSerializing>

@property(nonatomic, copy)NSString* locationID;
@property(nonatomic, copy)NSString* locationName;
@property(nonatomic, assign)double latitude;
@property(nonatomic, assign)double longitude;
@property(nonatomic, assign)int distance;

- (NSString *)autocompleteString;

@end
