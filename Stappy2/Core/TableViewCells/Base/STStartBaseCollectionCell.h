//
//  STStartBaseCollectionCell.h
//  Stappy2
//
//  Created by Cynthia Codrea on 04/03/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STStartModel;

@protocol STStartScreenCollectionViewCellDelegate <NSObject>

@optional

-(void)showDetailScreenForItem:(STStartModel*)item;
-(void)showOverviewForIndex:(NSInteger)index andCellType:(int)type;

@end

@interface STStartBaseCollectionCell : UICollectionViewCell

@property (weak, nonatomic) id<STStartScreenCollectionViewCellDelegate> startCellCollectionDelegate;

@end
