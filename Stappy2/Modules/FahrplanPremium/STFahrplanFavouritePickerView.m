//
//  STFahrplanFavouritePicker.m
//  Stappy2
//
//  Created by Andrej Albrecht on 14.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanFavouritePickerView.h"

@implementation STFahrplanFavouritePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviewFromNib];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSubviewFromNib];
    }
    return self;
}

- (UIView *)viewFromNib
{
    Class class = [self class];
    NSString *nibName = NSStringFromClass(class);
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    UIView *view = [nibViews objectAtIndex:0];
    return view;
}

- (void)addSubviewFromNib
{
    UIView *view = [self viewFromNib];
    view.frame = self.bounds;
    [self addSubview:view];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
