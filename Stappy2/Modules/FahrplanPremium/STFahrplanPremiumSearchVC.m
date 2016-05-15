//
//  STFahrplanPremiumSearchVC.m
//  Stappy2
//
//  Created by Andrej Albrecht on 10.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STFahrplanPremiumSearchVC.h"
#import "SWRevealViewController.h"

//Cells
#import "STFahrplanMapCellTVC.h"
#import "STFahrplanEnteredLocationDisplayCellTVC.h"
#import "STFahrplanFavouriteOriginWithDestinationCellTVC.h"
#import "STFahrplanFavouriteOneLocationCellTVC.h"

#import "STFahrplanLocationNameFinderOverlayVC.h"
#import "STFahrplanPremiumConnectionsVC.h"


static NSString *mapCellIdentifier = @"STFahrplanMapCellTVC.identifier";
static NSString *enteredLocationDisplayIdentifier = @"STFahrplanEnteredLocationDisplayCellTVC.identifier";
static NSString *favouriteOriginWithDestinationCellIdentifier = @"STFahrplanFavouriteOriginWithDestinationCellTVC.identifier";
static NSString *favouriteOneLocationCellIdentifier = @"STFahrplanFavouriteOneLocationCellTVC.identifier";

static NSString *mapCellNibName = @"STFahrplanMapCellTVC";
static NSString *enteredLocationDisplayNibName = @"STFahrplanEnteredLocationDisplayCellTVC";
static NSString *favouriteOriginWithDestinationCellNibName = @"STFahrplanFavouriteOriginWithDestinationCellTVC";
static NSString *favouriteOneLocationCellNibName = @"STFahrplanFavouriteOneLocationCellTVC";


@interface STFahrplanPremiumSearchVC () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, STFahrplanEnteredLocationDisplayDelegate, STFahrplanLocationNameFinderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageCenterYConstraint;

@end

@implementation STFahrplanPremiumSearchVC


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCells];
    [self initNavigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Layout

-(void)initCells
{
    [self.tableView registerNib:[UINib nibWithNibName:mapCellNibName bundle:nil] forCellReuseIdentifier:mapCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:enteredLocationDisplayNibName bundle:nil] forCellReuseIdentifier:enteredLocationDisplayIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:favouriteOriginWithDestinationCellNibName bundle:nil] forCellReuseIdentifier:favouriteOriginWithDestinationCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:favouriteOneLocationCellNibName bundle:nil] forCellReuseIdentifier:favouriteOneLocationCellIdentifier];
}

-(void)initNavigationController
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        
        self.navigationItem.leftBarButtonItem = self.sidebarButton;
        
        
        [self.rightbarButton setTarget: self.revealViewController];
        [self.rightbarButton setAction: @selector(rightRevealToggle:)];
        self.navigationItem.rightBarButtonItem = self.rightbarButton;
    }
}


#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row==0) {
        STFahrplanMapCellTVC *mapCell = (STFahrplanMapCellTVC *)[self.tableView dequeueReusableCellWithIdentifier:mapCellIdentifier];
        self.imageCenterYConstraint = mapCell.imageCenterYConstraint;
        cell = mapCell;
        
    } else if (indexPath.row==1) {
        STFahrplanEnteredLocationDisplayCellTVC *enteredCell = (STFahrplanEnteredLocationDisplayCellTVC *)[self.tableView dequeueReusableCellWithIdentifier:enteredLocationDisplayIdentifier];
        enteredCell.delegate = self;
        
        cell = enteredCell;
    } else if (indexPath.row==2) {
        cell = (STFahrplanFavouriteOriginWithDestinationCellTVC *)[self.tableView dequeueReusableCellWithIdentifier:favouriteOriginWithDestinationCellIdentifier];
        
    } else if (indexPath.row>=3) {
        cell = (STFahrplanFavouriteOneLocationCellTVC *)[self.tableView dequeueReusableCellWithIdentifier:favouriteOneLocationCellIdentifier];
        
    } else {
        NSLog(@"No cell defined");
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        //return [[[[NSBundle mainBundle] loadNibNamed:mapCellNibName owner:self options:nil] objectAtIndex:0] bounds].size.height;
        
        return UITableViewAutomaticDimension;
        
    } else if (indexPath.row==1) {
        return [[[[NSBundle mainBundle] loadNibNamed:enteredLocationDisplayNibName owner:self options:nil] objectAtIndex:0] bounds].size.height;
        
    } else if (indexPath.row==2) {
        return [[[[NSBundle mainBundle] loadNibNamed:favouriteOriginWithDestinationCellNibName owner:self options:nil] objectAtIndex:0] bounds].size.height;
        
    } else if (indexPath.row>=3) {
        return [[[[NSBundle mainBundle] loadNibNamed:favouriteOneLocationCellNibName owner:self options:nil] objectAtIndex:0] bounds].size.height;
        
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 200;
        default:
            return 50;
    }
}


#pragma mark - UIScrollViewDelegate (For Map-Parallax-Effect)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float calculatedValue = -scrollView.contentOffset.y / 2.0;
    self.imageCenterYConstraint.constant = calculatedValue>0?0:-calculatedValue;
}


#pragma mark - STFahrplanEnteredLocationDisplay

-(void)enteredLocationDisplay:(STFahrplanEnteredLocationDisplayCellTVC*)enteredLocationDisplay nextAction:(id)sender
{
    /*
    if (!self.journeyService.originAddress || [self.journeyService.originAddress.locationName  isEqualToString:@""]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Info"
                                                         message:@"Bitte Start-Addresse eintragen."
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        return;
    }else if (!self.journeyService.destinationAddress || [self.journeyService.destinationAddress.locationName isEqualToString:@""]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Info"
                                                         message:@"Bitte Ziel-Addresse eintragen."
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        return;
    }
    */
    
    STFahrplanPremiumConnectionsVC *connectionsVC = [[STFahrplanPremiumConnectionsVC alloc] initWithNibName:@"STFahrplanPremiumConnectionsVC" bundle:nil];
    connectionsVC.title = @"Verbindungen";
    [self.navigationController pushViewController:connectionsVC animated:YES];
}

-(void)enteredLocationDisplay:(STFahrplanEnteredLocationDisplayCellTVC*)enteredLocationDisplay locationAction:(id)sender
{
    NSLog(@"locationAction");
    
}

-(void)enteredLocationDisplay:(STFahrplanEnteredLocationDisplayCellTVC*)enteredLocationDisplay originAction:(id)sender
{
    STFahrplanLocationNameFinderOverlayVC *locationNameFinderVC = [[STFahrplanLocationNameFinderOverlayVC alloc] initWithNibName:@"STFahrplanLocationNameFinderOverlayVC" bundle:nil];
    //[locationNameFinderVC setAddress:self.journeyService.destinationAddress];
    locationNameFinderVC.delegate = self;
    locationNameFinderVC.title = @"Abfahrt";
    [self presentViewController:locationNameFinderVC animated:YES completion:^{
        NSLog(@"STFahrplanLocationNameFinderOverlayVC presentViewController completion");
        
    }];
}

-(void)enteredLocationDisplay:(STFahrplanEnteredLocationDisplayCellTVC*)enteredLocationDisplay destinationAction:(id)sender
{
    STFahrplanLocationNameFinderOverlayVC *locationNameFinderVC = [[STFahrplanLocationNameFinderOverlayVC alloc] initWithNibName:@"STFahrplanLocationNameFinderOverlayVC" bundle:nil];
    //[locationNameFinderVC setAddress:self.journeyService.destinationAddress];
    locationNameFinderVC.delegate = self;
    locationNameFinderVC.title = @"Ankunft";
    [self presentViewController:locationNameFinderVC animated:YES completion:^{
        NSLog(@"STFahrplanLocationNameFinderOverlayVC presentViewController completion");
        
    }];
}


#pragma mark - STFahrplanLocationNameFinderDelegate

- (void)locationNameFinderAdressChoosed:(STFahrplanLocation *)adress
{
    
}


@end
