//
//  STGenerralParkhausTableViewController.m
//  Stappy2
//
//  Created by Pavel Nemecek on 17/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STGenerralParkhausTableViewController.h"
#import "STAppSettingsManager.h"
#import "STRequestsHandler.h"
#import "STGeneralParkhausModel.h"
#import "SWRevealViewController.h"
#import "STNewsAndEventsDetailViewController.h"
#import "STParkHausTableViewCell.h"
@interface STGenerralParkhausTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray*parkHauses;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation STGenerralParkhausTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.leftBarButton setTarget: self.revealViewController];
        [self.leftBarButton setAction: @selector(revealToggle:)];
        [self.rightBarButton setTarget: self.revealViewController];
        [self.rightBarButton setAction: @selector(rightRevealToggle:)];
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];

    self.parkHauses = @[];

    
    [self fetchTankStationsFromServer];

}

-(void)fetchTankStationsFromServer{
    
    __weak typeof(self) weakSelf = self;
    
    [[STRequestsHandler sharedInstance] allGeneralParkHausesWithCompletion:^(NSArray *parkHauses, NSError *error) {
        if (!error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.parkHauses = parkHauses;
            [strongSelf.tableView reloadData];
        }
        else{
            [[[UIAlertView alloc] initWithTitle:@"Fehler beim Laden der Daten." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    return self.parkHauses.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STParkHausTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"parkHausCell" forIndexPath:indexPath];
    [cell setupWithParkHaus:self.parkHauses[indexPath.row] location:self.locationManager.location];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self presentParkHausDetailScreenWithModel:self.parkHauses[indexPath.row]];
}

-(void)presentParkHausDetailScreenWithModel:(STGeneralParkhausModel*)parkHausModel {
    
    STNewsAndEventsDetailViewController *detailViewController = [[STNewsAndEventsDetailViewController alloc] initWithNibName:@"STNewsAndEventsDetailViewController" bundle:nil andGeneralParkHausModel:parkHausModel];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
