//
//  STActionCollectionViewCell.m
//  Stappy2
//
//  Created by Pavel Nemecek on 21/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STDetailActionCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation STDetailActionCollectionViewCell

-(void)setupWithIconImage:(UIImage*)iconImage assiciatedObject:(id)assiciatedObject{
    self.imageView.image = iconImage;
    self.associatedObject = assiciatedObject;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
