//
//  STEventsModel.h
//  Stappy2
//
//  Created by Cynthia Codrea on 30/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STMainModel.h"

@interface STEventsModel : STMainModel <MTLJSONSerializing, Favoritable>
@property (nonatomic, assign, getter=isFavorite) BOOL favorite;

@end
