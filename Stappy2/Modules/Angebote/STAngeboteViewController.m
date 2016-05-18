//
//  STAngeboteViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 09/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STAngeboteViewController.h"
#import "STRequestsHandler.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "STNewsModel.h"
#import "STTableMainKeyObject.h"
#import "STTableSecondaryKeyObject.h"
#import "STAngeboteHeaderView.h"
#import "STAnnotationsMapViewController.h"
#import "STAppSettingsManager.h"

@interface STAngeboteViewController ()

@end

@implementation STAngeboteViewController

- (NSString *)filterType { return @"angebote"; }

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"STAngeboteHeaderView" bundle:nil];
    [self.lokalNewsTable registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:kAngeboteTableViewHeaderIdentifier];
}

- (void)loadNews
{
    [self loadWerbung];
    [self.refreshControl beginRefreshing];
    __weak typeof(self) weakSelf = self;
    [[STRequestsHandler sharedInstance] allAngetboteWithUrl:@"/angebote-v2"
                                                params:self.parameters
                                                  type:@"Angebote"
                                         andCompletion:^(NSArray *news, NSArray *originalNews, NSUInteger pageCount, NSError *error) {
                                             __strong typeof(weakSelf) strongSelf = weakSelf;
                                             [strongSelf.refreshControl endRefreshing];
                                             strongSelf.newsTableDataArray = news;
                                             strongSelf.pageCount = pageCount;
                                             if (!strongSelf.originalFetchedNews.count) {
                                                 strongSelf.originalFetchedNews = [NSMutableArray array];
                                             }
                                             [strongSelf.originalFetchedNews addObjectsFromArray:originalNews];
                                             strongSelf.expandableTableDataArray = [NSMutableArray arrayWithArray:news];
                                             [strongSelf.lokalNewsTable reloadData];
                                             [self updateHeaders];

                                              [self addInfititeScrolling];

                                         }];
}

-(void)loadMoreNews
{
    //if we reached the end of data stop indicator and return
    if (self.currentPage == self.pageCount) {
        [self.lokalNewsTable.infiniteScrollingView stopAnimating];
        return;
    }
    self.currentPage += 1;
    self.parameters[@"page"] = @(self.currentPage);
    //request data for the next page
    __weak  typeof(self) weakSelf = self;
    [[STRequestsHandler sharedInstance] allAngetboteWithUrl:@"/angebote-v2"
                                                params:self.parameters
                                                  type:@"Angebote"
                                         andCompletion:^(NSArray *news, NSArray * originalNews, NSUInteger pageCount, NSError *error) {
                                             __strong typeof(weakSelf) strongSelf = weakSelf;
                                             [strongSelf.originalFetchedNews addObjectsFromArray:originalNews];
                                             //call method to group the data and reload the table
                                             [strongSelf populateWithNextPageWithPageElements:self.originalFetchedNews];
                                         }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)onTap:(STMainModel *)detailData {
    if ([[STAppSettingsManager sharedSettingsManager] showCoupons]) {
        if ([[STAppSettingsManager sharedSettingsManager] activeCoupon].length > 0) {
            [super onTap:detailData];
        } else {
            // Show alert
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Kundennummer Error" message:@"Die eingegebene Kundennummer ist leider ungültig." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] ;
            [alert show];
        }
    } else {
        [super onTap:detailData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[STAppSettingsManager sharedSettingsManager] showCoupons]) {
        if ([[STAppSettingsManager sharedSettingsManager] activeCoupon].length > 0) {
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        } else {
            // Show alert
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Kundennummer Error" message:@"Die eingegebene Kundennummer ist leider ungültig." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] ;
            [alert show];
        }
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STAngeboteHeaderView *sectionHeaderView = (STAngeboteHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kAngeboteTableViewHeaderIdentifier];
    //set frame
    sectionHeaderView.frame = CGRectMake(CGRectGetMinX(sectionHeaderView.frame), CGRectGetMinY(sectionHeaderView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(sectionHeaderView.frame));
    
    STTableSecondaryKeyObject *secondaryKeyObject = ((STTableMainKeyObject *)self.expandableTableDataArray[section]).mainKeyArray[0];
    STNewsModel * firstNewsModel = secondaryKeyObject.secondaryKeyArray[0];
    sectionHeaderView.categoryLabel.text = firstNewsModel.mainKey;
    sectionHeaderView.mapButton.tag = section;
    sectionHeaderView.backgroundContent.backgroundColor = [UIColor clearColor];
    [sectionHeaderView.mapButton addTarget:self action:@selector(mapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return sectionHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0f;
}

#pragma mark - Scroll view delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateHeaders];
}

//-(void)updateHeaders {
//    //get the top most visible table section
//    NSArray *visibleCells = [self.lokalNewsTable indexPathsForVisibleRows];
//    if (visibleCells.count > 0) {
//        NSInteger topSection = [[self.lokalNewsTable indexPathsForVisibleRows].firstObject section];
//        NSInteger sectionYOffset = [self.lokalNewsTable rectForHeaderInSection:topSection].origin.y;
//        STAngeboteHeaderView *pinnedHeader = (STAngeboteHeaderView *)[self.lokalNewsTable headerViewForSection:topSection];
//        if ((self.lokalNewsTable.contentOffset.y - sectionYOffset) > 0 || self.lokalNewsTable.contentOffset.y < 5) {
//            if (![pinnedHeader isKindOfClass:[STAngeboteHeaderView class]]) {
//                return;
//            }
//            pinnedHeader.backgroundContent.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
//        } else {
//            pinnedHeader.backgroundContent.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
//        }
//        if (1 < visibleCells.count) {
//            NSInteger secondSection = [[[self.lokalNewsTable indexPathsForVisibleRows] objectAtIndex:1] section];
//            if (secondSection != topSection) {
//                STAngeboteHeaderView *secondHeader = (STAngeboteHeaderView *)[self.lokalNewsTable headerViewForSection:secondSection];
//                if (pinnedHeader != secondHeader) {
//                    secondHeader.backgroundContent.backgroundColor = [UIColor clearColor];
//                }
//            }
//        }
//    }
//}

-(void)updateHeaders {
    //get the top most visible table section
    NSArray *visibleCells = [self.lokalNewsTable indexPathsForVisibleRows];
    if (visibleCells.count > 0) {
        NSInteger topSection = [[self.lokalNewsTable indexPathsForVisibleRows].firstObject section];
        NSInteger sectionYOffset = [self.lokalNewsTable rectForHeaderInSection:topSection].origin.y;
        STAngeboteHeaderView *pinnedHeader = (STAngeboteHeaderView *)[self.lokalNewsTable headerViewForSection:topSection];
                
        if ((self.lokalNewsTable.contentOffset.y - sectionYOffset) > 0 || self.lokalNewsTable.contentOffset.y < 5) {
            if (![pinnedHeader isKindOfClass:[STAngeboteHeaderView class]]) {
                return;
            }
            pinnedHeader.backgroundContent.backgroundColor =    [UIColor colorWithWhite:0 alpha:0.7];
        } else {
            pinnedHeader.backgroundContent.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        }
        if (1 < visibleCells.count && self.lokalNewsTable.contentOffset.y != 0) {
            NSInteger secondSection = [[[self.lokalNewsTable indexPathsForVisibleRows] objectAtIndex:1] section];
            if (secondSection != topSection) {
                STAngeboteHeaderView *secondHeader = (STAngeboteHeaderView *)[self.lokalNewsTable headerViewForSection:secondSection];
                if (pinnedHeader != secondHeader) {
                    secondHeader.backgroundContent.backgroundColor = [UIColor clearColor];
                }
            }
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
