//
//  STDetailGenericModel.h
//  Schwedt
//
//  Created by Cynthia Codrea on 03/02/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STMainModel.h"
#import "OpeningClosingTimesModel.h"

@interface STDetailGenericModel : STMainModel <MTLJSONSerializing>
@property (nonatomic, strong) NSArray<OpeningClosingTimesModel *> *openinghours2;
@property (nonatomic, assign) BOOL isOffer;
@end
