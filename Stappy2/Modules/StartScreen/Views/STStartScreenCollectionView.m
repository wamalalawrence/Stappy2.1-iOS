//
//  STStartScreenCollectionView.m
//  Stappy2
//
//  Created by Cynthia Codrea on 09/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STStartScreenCollectionView.h"
#import "STStartScreenCollectionViewCell.h"

@interface STStartScreenCollectionView ()

@property (weak, nonatomic) IBOutlet UICollectionView *mainScreenCollectionView;

@end

@implementation STStartScreenCollectionView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}

-(void)doInit
{
    UINib *cellNib = [UINib nibWithNibName:@"STStartScreenCollectionViewCell" bundle:nil];
    [self.mainScreenCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"startCell"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(200, 200)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.mainScreenCollectionView setCollectionViewLayout:flowLayout];
    self.mainScreenCollectionView.scrollEnabled = NO;
}

@end