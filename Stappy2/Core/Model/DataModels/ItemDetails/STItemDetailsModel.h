//
//  STItemDetailsModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 07/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "STMainModel.h"
#import "OpeningClosingTimesModel.h"

@interface STItemDetailsModel : MTLModel <MTLJSONSerializing, Favoritable>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *background;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *contactUrl;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *openinghours;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic, copy) NSString *type;
@property(nonatomic, assign)BOOL menuOrientationLeft;

@property (nonatomic, strong) NSNumber *itemId;
@property (nonatomic, strong) NSArray<NSString *> *images;
@property (nonatomic, strong) NSArray<OpeningClosingTimesModel *> *openinghours2;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, assign, getter=isFavorite) BOOL favorite;

@property(nonatomic, assign)BOOL isOpen;

@end
