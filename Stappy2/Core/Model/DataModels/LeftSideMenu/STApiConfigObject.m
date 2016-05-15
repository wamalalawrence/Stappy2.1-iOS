//
//  STApiConfigObject.m
//  Schwedt
//
//  Created by Andrei Neag on 31.01.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STApiConfigObject.h"
#import "Defines.h"
#import "NSDictionary+Default.h"

@implementation STApiConfigObject 

-(id)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        // Load values from dictionary
        self.baseUrlString = [dict valueForKey:kBaseUrlStringKey withDefault:kEmptyString];
        self.departureTimeUrl = [dict valueForKey:kDepartureTimeUrlStringKey withDefault:kEmptyString];
        self.autorizationHeader = [dict valueForKey:kAutorizationHeaderStringKey withDefault:[NSDictionary dictionary]];
    }
    
    return self;
}

#pragma - NSCoding methods
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.baseUrlString forKey:kBaseUrlStringKey];
    [aCoder encodeObject:self.departureTimeUrl forKey:kDepartureTimeUrlStringKey];
    [aCoder encodeObject:self.autorizationHeader forKey:kAutorizationHeaderStringKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self.baseUrlString = [aDecoder decodeObjectForKey:kBaseUrlStringKey];
    self.departureTimeUrl = [aDecoder decodeObjectForKey:kDepartureTimeUrlStringKey];
    self.autorizationHeader = [aDecoder decodeObjectForKey:kAutorizationHeaderStringKey];
    
    return self;
}


@end
