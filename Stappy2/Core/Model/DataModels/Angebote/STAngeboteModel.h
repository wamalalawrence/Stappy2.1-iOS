//
//  STAngeboteModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 09/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "STMainModel.h"

@interface STAngeboteModel : STMainModel <MTLJSONSerializing, Favoritable>
@property(nonatomic,copy)NSString *subtitle;
@property(nonatomic,assign)NSInteger angebotItemID;
@property (nonatomic, assign, getter=isFavorite) BOOL favorite;
@end
