//
//  XMLListTableViewController.m
//  Stappy2
//
//  Created by Pavel Nemecek on 26/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReportListTableViewController.h"
#import "STRequestsHandler.h"
#import "STReportListTableViewCell.h"
#import "STXMLFeedModel.h"
#import "RandomImageView.h"
#import "SWRevealViewController.h"

static NSString * const STReportListCellIdentifier = @"reportListCell";

@interface STReportListTableViewController ()
@property(nonatomic,strong) NSArray*items;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@end

@implementation STReportListTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    RandomImageView*randomImageView = [[RandomImageView alloc] init];
    [randomImageView setNeedsBlur:YES];
    self.tableView.backgroundView =randomImageView;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.leftBarButton setTarget: self.revealViewController];
        [self.leftBarButton setAction: @selector(revealToggle:)];
        [self.rightBarButton setTarget: self.revealViewController];
        [self.rightBarButton setAction: @selector(rightRevealToggle:)];
    }

    [self reloadData];
    
}

-(void)reloadData{

    __weak typeof (self) _welf = self;
    
    [[STRequestsHandler sharedInstance] getReportListWithcompletion:^(NSArray *results, NSError *error) {
        
        if (results) {
            _welf.items = results;
            [_welf.tableView reloadData];
        }

    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STReportListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:STReportListCellIdentifier forIndexPath:indexPath];
    [cell setupWithReportListModel:self.items[indexPath.row]];
    return cell;
}


@end
