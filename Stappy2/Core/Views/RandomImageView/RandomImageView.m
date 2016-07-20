
//
//  RandomImageView.m
//  Stappy2
//
//  Created by Andrei Neag on 07.05.2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "RandomImageView.h"
#import "Defines.h"

NSString *const kSessionImage = @"currentSessionImage";
NSString *const kSessionImagesArray = @"sessionIamgesArray";

@implementation RandomImageView

-(void)setNeedsBlur:(BOOL)needsBlur {
    _needsBlur = needsBlur;
    [self setRandomImage];
}

-(instancetype)init {
    self = [super init];
    if (self) {
            [self setRandomImage];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRandomImage) name:kRegionChagedNotification object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setRandomImage {
    //check if all regions are selected and for that case keep the existing image
    BOOL allRegionsAreSelected = [[NSUserDefaults standardUserDefaults] boolForKey:@"allRegionsSelected"];
    NSString * sessionImageName = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionImage];
    if (sessionImageName == nil) {
        NSArray * imagesArray = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionImagesArray];
        if (imagesArray) {
            if (imagesArray.count > 0) {
                NSUInteger randomIndex = arc4random_uniform([imagesArray count]);
                sessionImageName = [imagesArray objectAtIndex: randomIndex];
                
                [[NSUserDefaults standardUserDefaults] setObject:sessionImageName forKey:kSessionImage];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    if (self.needsBlur) {
        sessionImageName =[sessionImageName stringByAppendingString:@"_blur"];
    }

    UIImage * sessionImage = [UIImage imageNamed:sessionImageName];
    
    if (!sessionImage || allRegionsAreSelected) {
        if (self.needsBlur) {
            sessionImage = [UIImage imageNamed:@"background_blurred"];
        }
        else {
            sessionImage = [UIImage imageNamed:@"image_content_bg_logo"];
        }
    }
    
    self.image = sessionImage;
}

-(void)awakeFromNib{
    
    [self setNeedsBlur:YES];
}

@end
