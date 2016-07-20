//
//  STImageCollectionViewCell.h
//  Stappy2
//
//  Created by Pavel Nemecek on 21/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STDetailImageCollectionViewCell : UICollectionViewCell
@property(weak, nonatomic) IBOutlet UIImageView* imageView;
-(void)setupWithImageUrl:(NSURL*)imageUrl;
@end
