//
//  STLokalNewsViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 20/10/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STNewsBaseTableViewCell.h"
#import "RandomImageView.h"

static NSString* kBaseNewsTableCellIdentifier  = @"STNewsBaseTableViewCell";
static NSString* kBaseNewsTableExpandedBottomCellIdentifier = @"ExpandedBottomTableViewCell";
static NSString* kBaseNewsTableExpandedCellIdentifier= @"STNewsBaseExpandedTableViewCell";
static NSString* kBaseNewsTableExpandedHeaderID = @"ExpandedTopTableViewCell";
static NSString* kNewsTableViewHeaderID = @"STLokalNewsHeaderView";
static NSString* kSTWerbungTableViewCell = @"STWerbungTableViewCell";

@interface STLokalNewsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, STNewsBaseTableViewCellDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITableView *lokalNewsTable;

@property (nonatomic,strong) NSArray* newsTableDataArray;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (nonatomic,strong) NSMutableArray* expandableTableDataArray;
@property (weak, nonatomic) IBOutlet RandomImageView *backgroundBlured;

@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,strong) NSMutableArray *originalFetchedNews;
@property (nonatomic,assign) NSUInteger pageCount;
@property (nonatomic,strong) NSMutableDictionary *parameters;

/**
 * overwrite this property for new ViewController which have filters
 */
@property (nonatomic, copy, readonly) NSString *filterType;
@property (nonatomic, copy, readonly) NSString *notificationCenterFilterChangeKey;

-(void)loadWerbung;
-(void)populateWithNextPageWithPageElements:(NSArray*)elementsArray;
-(void)mapButtonPressed:(UIButton *)sender;

@end
