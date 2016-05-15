//
//  RandomImageView.h
//  Stappy2
//
//  Created by Andrei Neag on 07.05.2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kSessionImage;
extern NSString *const kSessionImagesArray;

@interface RandomImageView : UIImageView

@property(nonatomic, assign)BOOL needsBlur;

@property(retain, nonatomic) UIVisualEffectView *visualEffectView;

@end
