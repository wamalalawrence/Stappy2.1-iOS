//
//  STImageCollectionViewCell.m
//  Stappy2
//
//  Created by Pavel Nemecek on 21/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STDetailImageCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation STDetailImageCollectionViewCell

-(void)setupWithImageUrl:(NSURL*)imageUrl{
    [self.imageView sd_setImageWithURL:imageUrl];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
