//
//  STStadtInfoOverviewModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 25/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "STMainModel.h"

@class OpeningClosingTimesModel;

@interface STStadtInfoOverviewModel : STMainModel <MTLJSONSerializing, Favoritable>

@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, copy) NSString *openinghours;

@property (nonatomic, strong) NSArray<OpeningClosingTimesModel *> *openinghours2;
@property (nonatomic, assign, getter=isFavorite) BOOL favorite;

@property(nonatomic, assign)BOOL isOpen;

@end
