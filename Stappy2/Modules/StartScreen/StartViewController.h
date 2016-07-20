//
//  StartViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 09/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SidebarViewController.h"
#import "STStartScreenCollectionViewCell.h"

@interface StartViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,STStartScreenCollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *startCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *startLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTemperatureLabel;
@property (weak, nonatomic) id<SideMenuViewControllerDelegate> sideMenuDelegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startMenuColectionViewHeight;
@property(nonatomic, strong)NSArray* startCollectionDataArray;

-(void)loadStartData;
-(void)showDetailScreenForItem:(STStartModel *)item;

@end
