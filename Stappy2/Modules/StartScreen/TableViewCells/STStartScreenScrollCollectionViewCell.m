//
//  STStartScreenScrollCollectionViewCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 09/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STStartScreenScrollCollectionViewCell.h"
#import "STAppSettingsManager.h"
#import "STStartScrollCustomCollectionCell.h"

static NSString* kCollectionViewCellId = @"customScroll";
@interface STStartScreenScrollCollectionViewCell ()
@property(nonatomic,strong)NSDictionary* sourceArray;

@end

@implementation STStartScreenScrollCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    if (self) {
        UINib * nibScroll = [UINib nibWithNibName:@"STStartScrollCustomCollectionCell" bundle:nil];
        [self.startCollectionIsideCell registerNib:nibScroll forCellWithReuseIdentifier:kCollectionViewCellId];
        self.sourceArray = [STAppSettingsManager sharedSettingsManager].startScreenScrollActions;
    }
}

#pragma mark - UICollectionView delegate - data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.sourceArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STStartScrollCustomCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellId forIndexPath:indexPath];
    NSString* imageName = [self.sourceArray allKeys][indexPath.row];
    // get custom icons if there are needed
    NSDictionary * otherIcons= [STAppSettingsManager sharedSettingsManager].startScreenOtherIcons;
    if (otherIcons.count) {
        NSString *name =[otherIcons valueForKey:imageName];
        if (name) {
            imageName = name;
        }
    }

    cell.actionImage.image = [UIImage imageNamed:imageName];
    if (!cell.actionImage.image) {
        cell.actionImage.image = [UIImage imageNamed:[imageName capitalizedString]];
    }
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    // Add inset to the collection view if there are not enough cells to fill the width.
    CGFloat cellSpacing = ((UICollectionViewFlowLayout *) collectionViewLayout).minimumLineSpacing;
    CGFloat cellWidth = ((UICollectionViewFlowLayout *) collectionViewLayout).itemSize.width;
    NSInteger cellCount = [collectionView numberOfItemsInSection:section];
    CGFloat inset = (collectionView.bounds.size.width - (cellCount * (cellWidth + cellSpacing))) * 0.5;
    inset = MAX(inset, 0.0);
    return UIEdgeInsetsMake(0.0, inset, 0.0, 0.0);
}


#pragma mark - collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showOverviewForId:indexPath.row];
}

-(void)showOverviewForId:(NSUInteger)controllerId {
    //call delegate method
    [self.startCellCollectionDelegate showOverviewForIndex:controllerId andCellType:2];
}
@end
