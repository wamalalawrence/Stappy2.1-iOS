//
//  XMLListTableViewController.m
//  Stappy2
//
//  Created by Pavel Nemecek on 26/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STXMLListTableViewController.h"
#import "STRequestsHandler.h"
#import "STXMLListTableViewCell.h"
#import "STXMLFeedModel.h"
#import "RandomImageView.h"
#import "SWRevealViewController.h"
#import "STWebViewDetailViewController.h"
static NSString * const STXMLListCellIdentifier = @"feedCell";

@interface STXMLListTableViewController ()
@property(nonatomic,strong) NSString*xmlFeedUrl;
@property(nonatomic,strong) NSArray*items;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@end

@implementation STXMLListTableViewController

-(void)setupWithXMLFeedUrl:(NSString*)xmlFeedUrl{
    self.xmlFeedUrl = xmlFeedUrl;
    [self reloadData];
}

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

    
}

-(void)reloadData{

    __weak typeof (self) _welf = self;
    [[STRequestsHandler sharedInstance] getXMLFeed:self.xmlFeedUrl completion:^(NSArray *items, NSError *error) {
        
        if (items) {
            _welf.items = items;
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
    STXMLListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:STXMLListCellIdentifier forIndexPath:indexPath];
    
    [cell setupWithFeedModel:self.items[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    STXMLFeedModel*model = self.items[indexPath.row];
  STWebViewDetailViewController *webPage = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:model.url];
    [self.navigationController pushViewController:webPage animated:YES];
}


@end
