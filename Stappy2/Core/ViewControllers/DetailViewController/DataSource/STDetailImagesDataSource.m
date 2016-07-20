//
//  STDetailImagesDataSource.m
//  Stappy2
//
//  Created by Pavel Nemecek on 22/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STDetailImagesDataSource.h"
#import "STDetailImageCollectionViewCell.h"

@interface STDetailImagesDataSource()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) NSString *cellIdentifier;

@end

@implementation STDetailImagesDataSource

- (id)init
{
    return nil;
}

- (id)initWithItems:(NSArray *)items
     cellIdentifier:(NSString *)cellIdentifier
{
    self = [super init];
    if (self) {
        self.items = items;
        self.cellIdentifier = cellIdentifier;
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.items[indexPath.row];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   
    STDetailImageCollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    NSURL* imageUrl = [[NSURL alloc] initWithString:self.items[indexPath.row]];
    [cell setupWithImageUrl:imageUrl];
    return cell;
}




@end
