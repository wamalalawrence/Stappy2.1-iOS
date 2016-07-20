//
//  STTickerViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 10/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STTickerViewController.h"
#import "STRequestsHandler.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "STTableMainKeyObject.h"
#import "STTableSecondaryKeyObject.h"
#import "STNewsBaseExpandedTableViewCell.h"
#import "STTickerModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "STExpandedTableTopObject.h"
#import "STExpandedTableBottomObject.h"

@interface STTickerViewController ()

@end

@implementation STTickerViewController

- (NSString *)filterType { return @"ticker"; }

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadNews
{

    [self.refreshControl beginRefreshing];
    __weak typeof(self) weakSelf = self;
    [[STRequestsHandler sharedInstance] allTickerNewsWithUrl:@"/news"
                                                     params:self.parameters
                                                       type:@"Ticker"
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
    [[STRequestsHandler sharedInstance] allTickerNewsWithUrl:@"/news"
                                                      params:self.parameters
                                                        type:@"Ticker"
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
                                                   strongSelf.originalFetchedNews = [NSMutableArray arrayWithArray:originalNews];
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
    [[STRequestsHandler sharedInstance] allTickerNewsWithUrl:@"/news"
                                                     params:self.parameters
                                                       type:@"Ticker"
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
                                              }];
}


@end
