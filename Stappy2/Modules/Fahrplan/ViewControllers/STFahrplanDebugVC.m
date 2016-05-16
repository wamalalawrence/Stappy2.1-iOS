//
//  STFahrplanDebugVC.m
//  Schwedt
//
//  Created by Andrej Albrecht on 03.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanDebugVC.h"
#import "STDebugHelper.h"
#import "STDebugEntry.h"
#import "STDebugHelperCellTVC.h"
#import "STFahrplanNearbyStopLocation.h"
#import "STFahrplanJourneyPlannerService.h"
#import "STFahrplanLocation.h"

@interface STFahrplanDebugVC () <UITableViewDataSource, UITableViewDelegate, STDebugHelperDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *sumValue;
@property (strong, nonatomic) STDebugHelper *debugHelper;
@end

static NSString *debugHelperCellIdentifier = @"STDebugHelperCelltVC.Identifier";

@implementation STFahrplanDebugVC


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STDebugHelperCellTVC" bundle:nil] forCellReuseIdentifier:debugHelperCellIdentifier];
    
    self.debugHelper = [STDebugHelper sharedInstance];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.debugHelper addObserver:self];
    [self updateLabels];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.debugHelper removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)resetAction:(id)sender {
    [self.debugHelper reset];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.debugHelper.debugDict count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STDebugEntry *debugEntry = [self.debugHelper entryAtIndex:indexPath.row];
    
    STDebugHelperCellTVC *cell = [self.tableView dequeueReusableCellWithIdentifier:debugHelperCellIdentifier];
    
    [cell setDebugEntry:debugEntry];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[[[NSBundle mainBundle] loadNibNamed:@"STDebugHelperCellTVC" owner:self options:nil] objectAtIndex:0] bounds].size.height;
}

#pragma mark - STDebugHelperDelegate

-(void)debugHelperDataChanged
{
    [self.tableView reloadData];
    
    [self updateLabels];
}

#pragma mark - Logic

-(void)updateLabels
{
    [self.sumValue setText:[NSString stringWithFormat:@"%lu", (unsigned long)[self.debugHelper countAllValues]]];
}

- (IBAction)setTestConnection:(id)sender {
    STFahrplanLocation *addressHamburgUeberseequartier = [[STFahrplanLocation alloc] init];
    addressHamburgUeberseequartier.locationID = @"A=1@O=Überseequartier, Hamburg@X=9998665@Y=53540354@U=80@L=0895883@B=1@p=1453857728@";
    addressHamburgUeberseequartier.locationName = @"Überseequartier, Hamburg";
    addressHamburgUeberseequartier.latitude = 53.551663;
    addressHamburgUeberseequartier.longitude = 9.934230;
    
    STFahrplanLocation *addressHamburgAltonaBhf = [[STFahrplanLocation alloc] init];
    addressHamburgAltonaBhf.locationID = @"A=1@O=Altona Bahnhof, Hamburg@X=9934230@Y=53551663@U=80@L=0692757@B=1@p=1453857728@";
    addressHamburgAltonaBhf.locationName = @"Altona Bahnhof, Hamburg";
    addressHamburgAltonaBhf.latitude = 53.551663;
    addressHamburgAltonaBhf.longitude = 9.934230;
    
    STFahrplanLocation *addressBremenBhf = [[STFahrplanLocation alloc] init];
    addressBremenBhf.locationID = @"A=1@O=Bremen Hbf@X=8813833@Y=53083477@U=80@L=8000050@B=1@p=1453857728@";
    addressBremenBhf.locationName = @"Bremen Hbf";
    addressBremenBhf.latitude = 53.083477;
    addressBremenBhf.longitude = 8.813833;
    
    STFahrplanLocation *addressBerlin = [[STFahrplanLocation alloc] init];
    addressBerlin.locationID = @"A=1@O=BERLIN@X=13386987@Y=52520501@U=80@L=8096003@B=1@p=1453261856@";
    addressBerlin.locationName = @"BERLIN";
    addressBerlin.latitude = 52.520501;
    addressBerlin.longitude = 13.386987;
    
    STFahrplanLocation *addressMunichAirport = [[STFahrplanLocation alloc] init];
    addressMunichAirport.locationID = @"A=1@O=München Flughafen Terminal@X=11785972@Y=48353731@U=80@L=8004168@B=1@p=1453857728@";
    addressMunichAirport.locationName = @"München Flughafen Terminal";
    addressMunichAirport.latitude = 48.353731;
    addressMunichAirport.longitude = 11.785972;
    
    STFahrplanLocation *addressHamburg = [[STFahrplanLocation alloc] init];
    addressHamburg.locationID = @"A=1@O=HAMBURG@X=9997434@Y=53557110@U=80@L=8096009@B=1@p=1453261856@";
    addressHamburg.locationName = @"HAMBURG";
    addressHamburg.latitude = 53.557110;
    addressHamburg.longitude = 9.997434;
    
    STFahrplanLocation *addressHamburgAirport = [[STFahrplanLocation alloc] init];
    addressHamburgAirport.locationID = @"A=1@O=Hamburg Airport@X=10006648@Y=53632350@U=80@L=8002547@B=1@p=1453261856@";
    addressHamburgAirport.locationName = @"Hamburg Airport";
    addressHamburgAirport.latitude = 53.632350;
    addressHamburgAirport.longitude = 10.006648;
    
    STFahrplanLocation *addressHamburgLiebermannStrasse = [[STFahrplanLocation alloc] init];
    addressHamburgLiebermannStrasse.locationID = @"A=1@O=Liebermannstraße, Hamburg@X=9900970@Y=53545802@U=80@L=0895174@B=1@p=1453857728@";
    addressHamburgLiebermannStrasse.locationName = @"Liebermannstraße, Hamburg";
    addressHamburgLiebermannStrasse.latitude = 53.545802;
    addressHamburgLiebermannStrasse.longitude = 9.900970;
    
    STFahrplanJourneyPlannerService *journeyService = [STFahrplanJourneyPlannerService sharedInstance];
    
    journeyService.originAddress = addressHamburgLiebermannStrasse;
    journeyService.destinationAddress = addressHamburgUeberseequartier;
    //[self updateViews];
}


@end
