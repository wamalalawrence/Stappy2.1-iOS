//
//  STStartModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 17/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STMainModel.h"

@interface STStartModel : STMainModel <MTLJSONSerializing, Favoritable>

@property(nonatomic, assign)BOOL isOffer;
@property(nonatomic,assign)NSInteger angebotItemID;
@property (nonatomic, assign, getter=isFavorite) BOOL favorite;

@end
