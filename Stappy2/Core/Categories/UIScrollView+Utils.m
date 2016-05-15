//
//  UIScrollView+Utils.m
//  Stappy2
//
//  Created by Andrei Neag on 26.04.2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "UIScrollView+Utils.h"

@implementation UIScrollView (Utils)

- (int)currentPage {
    int retVal = 0;
    if (self.frame.size.width > 0) {
        retVal = (self.contentOffset.x + (0.5 * self.frame.size.width)) / self.frame.size.width;
    }
    return retVal;
}

@end
