//
//  STActionCollectionViewCell.h
//  Stappy2
//
//  Created by Pavel Nemecek on 21/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+AssociatedObject.h"

@interface STDetailActionCollectionViewCell : UICollectionViewCell
@property(weak, nonatomic) IBOutlet UIImageView* imageView;
-(void)setupWithIconImage:(UIImage*)iconImage assiciatedObject:(id)assiciatedObject;
@end
