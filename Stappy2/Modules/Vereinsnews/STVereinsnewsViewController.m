//
//  STVereinsnewsViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 10/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STVereinsnewsViewController.h"
#import "STRequestsHandler.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "SWRevealViewController.h"
#import "STMainModel.h"
#import "STDetailViewController.h"
#import "STWebViewDetailViewController.h"

@interface STVereinsnewsViewController ()

@end

@implementation STVereinsnewsViewController

- (NSString *)filterType { return @"vereinsnews"; }

- (void)loadNews
{
    [self.refreshControl beginRefreshing];
    __weak typeof(self) weakSelf = self;
    [[STRequestsHandler sharedInstance] allVereinsnewsWithUrl:@"/vereinsnews-v2"
                                                     params:self.parameters
                                                       type:@"Vereinsnews"
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
                                                   [self addInfititeScrolling];
                                              }];
}

- (void)refreshNews {
    [self.refreshControl beginRefreshing];
    self.currentPage = 1;
    self.parameters[@"page"] = @(self.currentPage);
    __weak typeof(self) weakSelf = self;
    [[STRequestsHandler sharedInstance] allVereinsnewsWithUrl:@"/vereinsnews-v2"
                                                       params:self.parameters
                                                         type:@"Vereinsnews"
                                                andCompletion:^(NSArray *news, NSArray *originalNews, NSUInteger pageCount, NSError *error) {
                                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                                    [strongSelf.refreshControl endRefreshing];
                                                    strongSelf.newsTableDataArray = news;
                                                    strongSelf.pageCount = pageCount;
                                                    if (!strongSelf.originalFetchedNews.count) {
                                                        strongSelf.originalFetchedNews = [NSMutableArray array];
                                                    }
                                                    
                                                    // don't duplicate existing items
                                                    for (id obj in originalNews) {
                                                        if (![strongSelf.originalFetchedNews containsObject:obj]) {
                                                            [strongSelf.originalFetchedNews addObject:obj];
                                                        }
                                                    }
                                                    strongSelf.expandableTableDataArray = [NSMutableArray arrayWithArray:news];
                                                    [strongSelf.lokalNewsTable reloadData];
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
    [[STRequestsHandler sharedInstance] allVereinsnewsWithUrl:@"/vereinsnews-v2"
                                                     params:self.parameters
                                                       type:@"Vereinsnews"
                                              andCompletion:^(NSArray *news, NSArray * originalNews, NSUInteger pageCount, NSError *error) {
                                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                                  
                                                  // don't duplicate existing items
                                                  for (id obj in originalNews) {
                                                      if (![strongSelf.originalFetchedNews containsObject:obj]) {
                                                          [strongSelf.originalFetchedNews addObject:obj];
                                                      }
                                                  }
                                                  //call method to group the data and reload the table
                                                  [strongSelf populateWithNextPageWithPageElements:self.originalFetchedNews];
                                              }];}

-(void)onTap:(STMainModel *)detailData {
    if ([detailData.type isEqualToString:@"website"]) {
        STWebViewDetailViewController *webPage = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:detailData.url];
        [self.navigationController pushViewController:webPage animated:YES];
    } else {
        [[STRequestsHandler sharedInstance] itemDetailsForURL:detailData.url completion:^(STDetailGenericModel *itemDetails,NSDictionary* itemResponseDict, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                STDetailViewController *detailView = [[STDetailViewController alloc] initWithNibName:@"STDetailViewController"
                                                                                                                        bundle:nil
                                                                                                                  andDataModel:itemDetails];
                [self.navigationController pushViewController:detailView animated:YES];
            });
        }];
    }
}

@end
