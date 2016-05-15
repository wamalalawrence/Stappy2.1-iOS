//
//  STStartScreenCollectionViewCell.h
//  Stappy2
//
//  Created by Cynthia Codrea on 09/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STStartBaseCollectionCell.h"
#import "Indicators.h"

@interface STStartScreenCollectionViewCell : STStartBaseCollectionCell <UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *categoryItemsCollection;
@property (weak, nonatomic) IBOutlet Indicators *itemScrollPageControl;
@property (strong, nonatomic) NSIndexPath * cellIndexPath;
@property (nonatomic, strong)NSArray* dataForItemsTable;
@property (weak, nonatomic) IBOutlet UIButton *overviewButton;

- (IBAction)showOverview:(id)sender;
@end
