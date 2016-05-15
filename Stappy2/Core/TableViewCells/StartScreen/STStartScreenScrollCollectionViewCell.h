//
//  STStartScreenScrollCollectionViewCell.h
//  Stappy2
//
//  Created by Cynthia Codrea on 09/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STStartBaseCollectionCell.h"

@interface STStartScreenScrollCollectionViewCell : STStartBaseCollectionCell<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *startCollectionIsideCell;

@end
