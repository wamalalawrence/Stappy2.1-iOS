//
//  STMittagsAngeboteViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 08/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STMittagsAngeboteViewController.h"
#import "STRequestsHandler.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface STMittagsAngeboteViewController ()

@end

@implementation STMittagsAngeboteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadNews
{
    [self.refreshControl beginRefreshing];
    __weak typeof(self) weakSelf = self;
    [[STRequestsHandler sharedInstance] allAngetboteWithUrl:@"/mittagsangebote-v2"
                                                     params:self.parameters
                                                       type:@"MittagsAngebote"
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
    [[STRequestsHandler sharedInstance] allAngetboteWithUrl:@"/mittagsangebote-v2"
                                                     params:self.parameters
                                                       type:@"MittagsAngebote"
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

                                              }];}

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
    [[STRequestsHandler sharedInstance] allAngetboteWithUrl:@"/mittagsangebote-v2"
                                                     params:self.parameters
                                                       type:@"MittagsAngebote"
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
