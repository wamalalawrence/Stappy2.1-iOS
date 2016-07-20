//
//  STNewsTableCollectionExpandedFooter.m
//  Stappy2
//
//  Created by Cynthia Codrea on 03/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STNewsTableCollectionExpandedFooter.h"

@implementation STNewsTableCollectionExpandedFooter

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:[self initializeSubviews]];
        //        [self setup];
    }
    return self;
}
- (instancetype)initializeSubviews
{
    id view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    return view;
}

@end
