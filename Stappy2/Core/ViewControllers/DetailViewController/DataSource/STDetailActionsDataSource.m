//
//  STDetailActionsDataSource.m
//  Stappy2
//
//  Created by Pavel Nemecek on 22/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STDetailActionsDataSource.h"
#import "STDetailActionCollectionViewCell.h"
#import "NSObject+AssociatedObject.h"
#import "STMainModel.h"
#import "UIColor+STColor.h"
#import "UIImage+tintImage.h"

typedef NS_ENUM(NSInteger, STCollectionViewAnimationDirection) {
    STCollectionViewAnimationDirectionForward,
    STCollectionViewAnimationDirectionBackward
};

@interface STDetailActionsDataSource()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) id dataModel;

@end

@implementation STDetailActionsDataSource

- (id)init
{
    return nil;
}

- (id)initWithItems:(NSArray *)items
     cellIdentifier:(NSString *)cellIdentifier dataModel:(id)dataModel
{
    self = [super init];
    if (self) {
        self.items = items;
        self.cellIdentifier = cellIdentifier;
        self.dataModel = dataModel;
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.items[indexPath.row];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.items.count > 5){
        return ceil((double)self.items.count / 3) * 5;
    }
    
    else {
        return self.items.count;
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STDetailActionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
        
    if (indexPath.row > 4 && indexPath.row % 5 == 0) {
        [cell setupWithIconImage:[UIImage imageNamed:@"action_options_arrow_left"] assiciatedObject:@(STCollectionViewAnimationDirectionBackward)];
    }
    else if (self.items.count > 5 && indexPath.row % 5 == 4 && indexPath.row - 1 < self.items.count) {
        [cell setupWithIconImage:[UIImage imageNamed:@"action_options_arrow_right"] assiciatedObject:@(STCollectionViewAnimationDirectionForward)];
    }
    else {
        NSInteger dataIndex = indexPath.row;
        if (indexPath.row > 4 && self.items.count > 5) {
            dataIndex -= dataIndex / 5 * 2;
        }
        if (dataIndex < self.items.count) {
            id icon = self.items[dataIndex][@"icon"];
            UIImage*iconImage;
            if ([icon isKindOfClass:[NSString class]]) {
                iconImage = [UIImage imageNamed:icon];
            }
            else {
                if ([self.dataModel conformsToProtocol:@protocol(Favoritable)]) {
                    BOOL favorite = NO;
                    favorite = ((STMainModel<Favoritable> *)self.dataModel).favorite;
                    NSString *favoriteKey = favorite ? @"on" : @"off";
                    if ([favoriteKey isEqualToString:@"on"]) {
                        iconImage = [[UIImage imageNamed:icon[favoriteKey]] imageTintedWithColor:[UIColor partnerColor]];
                    }
                    else{
                        iconImage= [UIImage imageNamed:icon[favoriteKey]];
                    }
                }
            }
            [cell setupWithIconImage:iconImage assiciatedObject:self.items[dataIndex][@"SEL"]];
        }
        else {
            [cell setupWithIconImage:nil assiciatedObject:nil];
        }
    }
    return cell;
}

@end
