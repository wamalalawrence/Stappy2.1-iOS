//
//  STStartScreenBottomCollectionViewCell.h
//  Stappy2
//
//  Created by Cynthia Codrea on 09/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STStartBaseCollectionCell.h"

@interface STStartScreenBottomCollectionViewCell : STStartBaseCollectionCell<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonnull, strong) NSArray* titles;

@end
