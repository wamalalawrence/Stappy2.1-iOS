//
//  STFahrplanLocation.h
//  Stappy2
//
//  Created by Cynthia Codrea on 20/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface STFahrplanLocation : MTLModel <MTLJSONSerializing>

@property(nonatomic, copy)NSString* locationID;
@property(nonatomic, copy)NSString* locationName;
@property(nonatomic, assign)double latitude;
@property(nonatomic, assign)double longitude;
@property(nonatomic, assign)int distance;

- (NSString *)autocompleteString;

@end
