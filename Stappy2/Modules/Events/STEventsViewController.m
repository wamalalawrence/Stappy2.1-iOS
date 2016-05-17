//
//  STEventsViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 02/12/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STEventsViewController.h"
#import "STRequestsHandler.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "STLokalNewsHeaderView.h"

#import "STWeatherCurrentObservation.h"

@interface STEventsViewController ()

@end

@implementation STEventsViewController

- (NSString *)filterType { return @"events"; }

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundImage.image = [UIImage imageNamed:@"background"];
    // Do any additional setup after loading the view.
}

- (void)loadNews
{
    [self loadWerbung];
    [self.refreshControl beginRefreshing];
    __weak typeof(self) weakSelf = self;
    [[STRequestsHandler sharedInstance] allEventsWithUrl:@"/events-v2"
                                                     params:self.parameters
                                                       type:@"Events"
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
    [[STRequestsHandler sharedInstance] allEventsWithUrl:@"/events-v2"
                                                     params:self.parameters
                                                       type:@"Events"
                                              andCompletion:^(NSArray *news, NSArray * originalNews, NSUInteger pageCount, NSError *error) {
                                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                                  [strongSelf.originalFetchedNews addObjectsFromArray:originalNews];
                                                  //call method to group the data and reload the table
                                                  [strongSelf populateWithNextPageWithPageElements:self.originalFetchedNews];
                                              }];}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    STLokalNewsHeaderView *sectionHeaderView = (STLokalNewsHeaderView *)[super tableView:tableView viewForHeaderInSection:section];
    sectionHeaderView.mapButton.hidden = false;
    sectionHeaderView.mapButton.tag = section;
    [sectionHeaderView.mapButton addTarget:self action:@selector(mapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    CGRect headerFrame = sectionHeaderView.frame;
    headerFrame.size.width = tableView.frame.size.width;
    sectionHeaderView.frame = headerFrame;
    
    return sectionHeaderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
