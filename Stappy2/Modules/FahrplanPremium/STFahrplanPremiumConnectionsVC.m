//
//  STFahrplanConnectionsVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 10.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanPremiumConnectionsVC.h"

//Cells
#import "STFahrplanTimeDisplayWithFavouriteButtonViewTVC.h"
#import "STFahrplanFavouritePickerCellTVC.h"
#import "STFahrplanDatetimeChooserSmallCellTVC.h"
#import "STFahrplanTransportationTypePickerCellTVC.h"
#import "STFahrplanTransportationProgressIndicatorBarCellTVC.h"
#import "STConnectionCellTVC.h"

static NSString *timeDisplayIdentifier = @"STFahrplanTimeDisplayWithFavouriteButtonViewTVC.identifier";
static NSString *favouritePickerIdentifier = @"STFahrplanFavouritePickerCellTVC.identifier";
static NSString *datetimeChooserSmallIdentifier = @"STFahrplanDatetimeChooserSmallCellTVC.identifier";
static NSString *transportationTypePickerIdentifier = @"STFahrplanTransportationTypePickerCellTVC.identifier";
static NSString *transportationProgressIndicatorBarIdentifier = @"STFahrplanTransportationProgressIndicatorBarCellTVC.identifier";
static NSString *connectionCellIdentifier = @"STConnectionCellTVC.Identifier";

static NSString *timeDisplayNibName = @"STFahrplanTimeDisplayWithFavouriteButtonViewTVC";
static NSString *favouritePickerNibName = @"STFahrplanFavouritePickerCellTVC";
static NSString *datetimeChooserSmallNibName = @"STFahrplanDatetimeChooserSmallCellTVC";
static NSString *transportationTypePickerNibName = @"STFahrplanTransportationTypePickerCellTVC";
static NSString *transportationProgressIndicatorBarNibName = @"STFahrplanTransportationProgressIndicatorBarCellTVC";
static NSString *connectionCellNibName = @"STConnectionCellTVC";


@interface STFahrplanPremiumConnectionsVC ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation STFahrplanPremiumConnectionsVC


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCells];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Layout

-(void)initCells
{
    [self.tableView registerNib:[UINib nibWithNibName:timeDisplayNibName bundle:nil] forCellReuseIdentifier:timeDisplayIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:favouritePickerNibName bundle:nil] forCellReuseIdentifier:favouritePickerIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:datetimeChooserSmallNibName bundle:nil] forCellReuseIdentifier:datetimeChooserSmallIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:transportationTypePickerNibName bundle:nil] forCellReuseIdentifier:transportationTypePickerIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:transportationProgressIndicatorBarNibName bundle:nil] forCellReuseIdentifier:transportationProgressIndicatorBarIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:connectionCellNibName bundle:nil] forCellReuseIdentifier:connectionCellIdentifier];
}


#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row==0) {
        STFahrplanTimeDisplayWithFavouriteButtonViewTVC *timeDisplayCell = (STFahrplanTimeDisplayWithFavouriteButtonViewTVC *)[self.tableView dequeueReusableCellWithIdentifier:timeDisplayIdentifier];
        cell = timeDisplayCell;
        
    } else if (indexPath.row==1) {
        STFahrplanFavouritePickerCellTVC *favouritePickerCell = (STFahrplanFavouritePickerCellTVC *)[self.tableView dequeueReusableCellWithIdentifier:favouritePickerIdentifier];
        //enteredCell.delegate = self;
        cell = favouritePickerCell;
        
    } else if (indexPath.row==2) {
        cell = (STFahrplanDatetimeChooserSmallCellTVC *)[self.tableView dequeueReusableCellWithIdentifier:datetimeChooserSmallIdentifier];
        
    } else if (indexPath.row==3) {
        cell = (STFahrplanTransportationTypePickerCellTVC *)[self.tableView dequeueReusableCellWithIdentifier:transportationTypePickerIdentifier];
        
    } else if (indexPath.row==4) {
        cell = (STFahrplanTransportationProgressIndicatorBarCellTVC *)[self.tableView dequeueReusableCellWithIdentifier:transportationProgressIndicatorBarIdentifier];
        
    }else if (indexPath.row>=5) {
        cell = (STConnectionCellTVC *)[self.tableView dequeueReusableCellWithIdentifier:connectionCellIdentifier];
        
    } else {
        NSLog(@"No cell defined");
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"click on row:%lu", indexPath.row);
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return [[[[NSBundle mainBundle] loadNibNamed:timeDisplayNibName owner:self options:nil] objectAtIndex:0] bounds].size.height;
        
        //return UITableViewAutomaticDimension;
        
    } else if (indexPath.row==1) {
        return [[[[NSBundle mainBundle] loadNibNamed:favouritePickerNibName owner:self options:nil] objectAtIndex:0] bounds].size.height;
        
    } else if (indexPath.row==2) {
        return [[[[NSBundle mainBundle] loadNibNamed:datetimeChooserSmallNibName owner:self options:nil] objectAtIndex:0] bounds].size.height;
        
    } else if (indexPath.row==3) {
        return [[[[NSBundle mainBundle] loadNibNamed:transportationTypePickerNibName owner:self options:nil] objectAtIndex:0] bounds].size.height;
        
    } else if (indexPath.row==4) {
        return [[[[NSBundle mainBundle] loadNibNamed:transportationProgressIndicatorBarNibName owner:self options:nil] objectAtIndex:0] bounds].size.height;
        
    } else if (indexPath.row>=4) {
        return [[[[NSBundle mainBundle] loadNibNamed:connectionCellNibName owner:self options:nil] objectAtIndex:0] bounds].size.height;
        
    } else {
        return 0;
    }
}


# pragma mark - 


# pragma mark -


# pragma mark -


# pragma mark -


# pragma mark -



@end
