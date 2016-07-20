//
//  STStartScreenBottomCollectionViewCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 09/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STStartScreenBottomCollectionViewCell.h"
#import "STAppSettingsManager.h"
#import "STStartBottomCustomCollectionViewCell.h"
#import "Utils.h"
static NSString* kBottomCellIdentifier = @"bottomCellItedentifier";

@interface STStartScreenBottomCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *weatherButton;
@property (weak, nonatomic) IBOutlet UIButton *fahrplanButton;
@property (weak, nonatomic) IBOutlet UIButton *stadtinfoButton;
@property (weak, nonatomic) IBOutlet UICollectionView *bottomCollection;

@end

@implementation STStartScreenBottomCollectionViewCell

- (void)awakeFromNib {
    
    //register collection cell
    [self.bottomCollection registerNib:[UINib nibWithNibName:@"STStartBottomCustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kBottomCellIdentifier];
    //WORKAROUND SUEWAG
    if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"] isEqualToString:@"Frankfurt"]) {
        self.titles = @[@"Wetter",@"Ortsinformationen",@"Süwag-Services"];
    }
    else {
        self.titles = [[STAppSettingsManager sharedSettingsManager].startScreenBottomActions allValues];
    }
}
//
//-(void)showOverview:(id)sender {
//    //call delegate method
//    [self.startCellCollectionDelegate showOverviewForIndex:((UIButton*)sender).tag andCellType:3];
//}

#pragma mark - UICollectionview data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STStartBottomCustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBottomCellIdentifier forIndexPath:indexPath];
 
    
     NSString* text = self.titles[indexPath.row];
    
    if (![STAppSettingsManager sharedSettingsManager].shouldNotUseUppercase) {
        text = [text uppercaseString];
    }
 
    
   
    [cell.actionName setText:text];
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *font = [settings customFontForKey:@"startscreen.bottomcollectionview.cell.font"];
    if (font) {
        [cell.actionName setFont:font];
    }
    NSString* imageName = [Utils replaceSpecialCharactersFrom:[[NSString stringWithFormat:@"%@_icon",self.titles[indexPath.row]] lowercaseString]];
    // get custom icons if there are needed
    NSDictionary * otherIcons= [STAppSettingsManager sharedSettingsManager].startScreenBottomIcons;
    if (otherIcons.count) {
        NSString*name =[otherIcons valueForKey:self.titles[indexPath.row]];
        if (name) {
            imageName = name;
        }
    }
    cell.actionImage.image = [UIImage imageNamed:imageName];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger numberOfItemsPerPage = self.titles.count >= 3 ? 3 : self.titles.count;
    CGSize newSize = CGSizeMake((collectionView.frame.size.width - 2*(CGRectGetMinX(self.frame)))/ numberOfItemsPerPage, 50.f);
    return newSize;
}

#pragma mark - UICollectionview delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.startCellCollectionDelegate showOverviewForIndex:indexPath.row andCellType:3];
}
@end
