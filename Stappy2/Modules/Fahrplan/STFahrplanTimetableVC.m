//
//  STFahrplanTimetableVC.m
//  Schwedt
//
//  Created by Andrej Albrecht on 09.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STFahrplanTimetableVC.h"
#import "STFahrplanNearbyStopLocation.h"
#import "STRequestsHandler.h"
#import "STAppSettingsManager.h"
#import "STFahrplanDeparture.h"

#import "STFahrplanTimetableJourneyStopCellTVC.h"
#import "STFahrplanTimetableSectionCellTVC.h"

#import "STFahrplanJourneyDetail.h"
#import "STDebugHelper.h"
#import <MapKit/MapKit.h>
#import "STFahrplanJourneyPlannerService.h"
#import "STFahrplanJourneyStop.h"


static NSString *timetableSectionCellIdentifier = @"STFahrplanTimetableSectionCellTVC.Identifier";
static NSString *timetableCellIdentifier = @"STFahrplanTimetableJourneyStopCellTVC.Identifier";

@interface STFahrplanTimetableVC () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timetableTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timetableSubtitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *tableData;

@end

@implementation STFahrplanTimetableVC


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initStadtwerkLayout];
    [self initCells];
    
    NSLog(@"LocationID:%@",self.location.locationID);
    
    [self updateLabels];
    
    
    [self updateLocationInfos];
    
    //[self loadTestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Layout

-(void)initStadtwerkLayout
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *titleFont = [settings customFontForKey:@"fahrplan.timetable_view.primary.title.font"];
    UIFont *subtitleFont = [settings customFontForKey:@"fahrplan.timetable_view.primary.subtitle.font"];
    
    if (titleFont) {
        [self.timetableTitleLabel setFont:titleFont];
    }
    if (subtitleFont) {
        [self.timetableSubtitleLabel setFont:subtitleFont];
    }
}

-(void)initCells
{
    [self.tableView registerNib:[UINib nibWithNibName:@"STFahrplanTimetableJourneyStopCellTVC" bundle:nil] forCellReuseIdentifier:timetableCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"STFahrplanTimetableSectionCellTVC" bundle:nil] forCellReuseIdentifier:timetableSectionCellIdentifier];
}

#pragma mark - Actions

- (IBAction)actionClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    id object = [self.tableData objectAtIndex:indexPath.row];
    
    if ([object isKindOfClass:[STFahrplanDeparture class]]) {
        STFahrplanTimetableSectionCellTVC *depCell = (STFahrplanTimetableSectionCellTVC *)[self.tableView dequeueReusableCellWithIdentifier:timetableSectionCellIdentifier];
        
        STFahrplanDeparture *departure = (STFahrplanDeparture *) object;
        [depCell setDeparture:departure];
        
        cell = depCell;
    } else if ([object isKindOfClass:[STFahrplanJourneyStop class]]) {
        STFahrplanTimetableJourneyStopCellTVC *stopCell = (STFahrplanTimetableJourneyStopCellTVC *)[self.tableView dequeueReusableCellWithIdentifier:timetableCellIdentifier];
        
        STFahrplanJourneyStop *journeyStop = (STFahrplanJourneyStop *)object;
        [stopCell setJourneyStop:journeyStop];
        
        cell = stopCell;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.tableData objectAtIndex:indexPath.row] isKindOfClass:[STFahrplanDeparture class]]) {
        return [[[[NSBundle mainBundle] loadNibNamed:@"STFahrplanTimetableSectionCellTVC" owner:self options:nil] objectAtIndex:0] bounds].size.height;
    } else if ([[self.tableData objectAtIndex:indexPath.row] isKindOfClass:[STFahrplanJourneyStop class]]) {
        return [[[[NSBundle mainBundle] loadNibNamed:@"STFahrplanTimetableJourneyStopCellTVC" owner:self options:nil] objectAtIndex:0] bounds].size.height;
    } else {
        return [[[[NSBundle mainBundle] loadNibNamed:@"STFahrplanTimetableJourneyStopCellTVC" owner:self options:nil] objectAtIndex:0] bounds].size.height;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath row:%lu", indexPath.row);
    
    id object = [self.tableData objectAtIndex:indexPath.row];
    
    if ([object isKindOfClass:[STFahrplanDeparture class]]) {
        STFahrplanDeparture *departure = (STFahrplanDeparture *)object;
        
        if (![[self.tableData objectAtIndex:indexPath.row+1] isKindOfClass:[STFahrplanDeparture class]]) {
            NSMutableArray *tableDataCopy = [NSMutableArray arrayWithArray:self.tableData];
            
            //remove next cells if [object isKindOfClass:[STFahrplanJourneyDetail class]]
            
            NSLog(@"%lu < %lu",(unsigned long) indexPath.row, [self.tableData count]);
            
            for (int i=0;indexPath.row < [self.tableData count];i++) {
                if (![[tableDataCopy objectAtIndex:indexPath.row+1] isKindOfClass:[STFahrplanDeparture class]]) {
                    [tableDataCopy removeObjectAtIndex:indexPath.row+1];
                }else{
                    break;
                }
            }
            self.tableData = tableDataCopy;
            [self.tableView reloadData];
            return;
        }
    
        
        /*
         //Insert Test
         STFahrplanJourneyDetail *journeyDetail = [[STFahrplanJourneyDetail alloc] init];
         NSMutableArray *arrayTableData = [NSMutableArray arrayWithArray:self.tableData];
         NSIndexPath *insertedIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
         [arrayTableData insertObject:journeyDetail atIndex:insertedIndexPath.row];
         self.tableData = arrayTableData;
         NSArray *array = [NSArray arrayWithObjects:insertedIndexPath, nil];
         [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
        */
        
        [[STDebugHelper sharedInstance] incrementCounterOfKey:@"timetable.journeydetail"];
        
        [[STFahrplanJourneyPlannerService sharedInstance] getJourneyDetailofDeparture:departure onSuccess:^(STFahrplanJourneyDetail *journeyDetail) {
            NSLog(@"onSuccess previously clicked:%lu", indexPath.row);
            
            NSMutableArray *arrayTableData = [NSMutableArray arrayWithArray:self.tableData];
            
            int i=0;
            for (STFahrplanJourneyStop *stop in journeyDetail.stops) {
                
                NSIndexPath *insertedIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1+i inSection:indexPath.section];
                [arrayTableData insertObject:stop atIndex:insertedIndexPath.row];
                //NSArray *array = [NSArray arrayWithObjects:insertedIndexPath, nil];
                //withRowAnimation is very slow...
                //self.tableData = arrayTableData;
                //[self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
                
                i++;
            }
            
            self.tableData = arrayTableData;
            [self.tableView reloadData];
            
            
        } onFailure:^(NSError *error) {
            if (error) {
                NSLog(@"ERROR: %@", [error localizedDescription]);
                NSLog(@"onFailure previously clicked:%lu", indexPath.row);
                
                
                if ([error code] == NSURLErrorNotConnectedToInternet) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Keine Internetverbindung." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Abfahrtszeiten leider nicht verfügbar." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }];
        
    } else if ([object isKindOfClass:[STFahrplanJourneyDetail class]]) {
        NSLog(@"click on STFahrplanJourneyDetail");
        
        
        /*
        NSMutableArray *removedArray = [NSMutableArray arrayWithArray:self.tableData];
        
        [removedArray removeObjectAtIndex:indexPath.row];
        
        self.tableData = removedArray;
        
        NSArray *array = [NSArray arrayWithObject:indexPath];
        
        [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
        */
    }
}

#pragma mark - Logic

-(void)updateLabels
{
    [self.timetableTitleLabel setText:self.location.locationName];
    
    if (self.location && self.location.longitude!=0 && self.location.latitude!=0) {
        /*
         STFahrplanJourneyPlannerService *journeyService = [STFahrplanJourneyPlannerService sharedInstance];
         CLLocationCoordinate2D stopLocation2D = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
         CLLocationCoordinate2D userLocation2D = CLLocationCoordinate2DMake(journeyService.userLocation.location, journeyService.userLocation.longitude);
         
         MKMapPoint userLocation = MKMapPointForCoordinate(userLocation2D);
         MKMapPoint stopLocation = MKMapPointForCoordinate(stopLocation2D);
         CLLocationDistance distance = MKMetersBetweenMapPoints(userLocation, stopLocation);
         */
        
        [self.timetableSubtitleLabel setText:@""];
    }
}


-(void)updateLocationInfos
{
    [[STDebugHelper sharedInstance] incrementCounterOfKey:@"timetable.departureboard"];
    
    
    [[STFahrplanJourneyPlannerService sharedInstance] departureBoardForLocation:self.location onSuccess:^(NSArray *departures) {
        NSLog(@"departures:%lu", (unsigned long)[departures count]);
        
        
        self.tableData = departures;
        [self.tableView reloadData];
    } onFailure:^(NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", [error localizedDescription]);
            
            if ([error code] == NSURLErrorNotConnectedToInternet) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Keine Internetverbindung." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Abfahrtszeiten leider nicht verfügbar." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }];
}


#pragma mark - Test

-(void)loadTestData
{
    NSArray *testData = @[
                          [[STFahrplanDeparture alloc]init],
                          [[STFahrplanDeparture alloc]init],
                          [[STFahrplanDeparture alloc]init],
                          [[STFahrplanDeparture alloc]init],
                          [[STFahrplanDeparture alloc]init],
                          [[STFahrplanDeparture alloc]init],
                          [[STFahrplanDeparture alloc]init]
                          ];
    
    self.tableData = testData;
    [self.tableView reloadData];
}

@end
