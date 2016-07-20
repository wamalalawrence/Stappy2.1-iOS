//
//  GarbageCalendarViewController.m
//  Stappy2
//
//  Created by Denis Grebennicov on 16/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "GarbageCalendarViewController.h"

#import "STRequestsHandler.h"
#import "STNewsAndEventsDetailViewController.h"
#import "STAppSettingsManager.h"

#import "GarbageDateTableViewCell.h"
#import "GarbageDateHeaderView.h"

#import "UIColor+STColor.h"
#import "NSDictionary+Default.h"

#import "NSDate+MCExtensions.h"

#import "GarbageCalendarSettingsViewController.h"

#import "Stappy2-Swift.h"

#import "STDetailViewController.h"

//TODO: create cell
static NSString *cellIdentifier = @"garbageDateCell";
static NSString *headerCellIdentifier = @"headerCell";

@interface GarbageCalendarViewController ()
@property (nonatomic, strong) NSDateFormatter *inputDateFormatter;
@property (nonatomic, strong) NSDateFormatter *outputDateFormatter;
@end

@implementation GarbageCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GarbageDateTableViewCell class]) bundle:[NSBundle mainBundle]]
     forCellReuseIdentifier:cellIdentifier];

    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GarbageDateHeaderView class]) bundle:[NSBundle mainBundle]]
     forCellReuseIdentifier:headerCellIdentifier];
    
    _tableView.separatorColor = [UIColor clearColor];
    
    self.title = @"ABFALLKALENDER";
        
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_blurred"]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSMutableArray *vcs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if (![[vcs objectAtIndex:vcs.count - 2] isKindOfClass:[GarbageCalendarSettingsViewController class]])
    {
        [vcs insertObject:[[GarbageCalendarSettingsViewController alloc] initSelf] atIndex:vcs.count - 1];
        [self.navigationController setViewControllers:vcs animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return [GarbageCalendarManager sharedInstance].results.count; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionData = [GarbageCalendarManager sharedInstance].results[(NSUInteger) section];
    NSArray *list = [sectionData valueForKey:@"list" withDefault:nil];
    return [list count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return [self createHeaderViewForHeaderInSection:indexPath.section];
    
    NSDictionary *sectionData = [GarbageCalendarManager sharedInstance].results[(NSUInteger) indexPath.section];
    NSArray *list = [sectionData valueForKey:@"list" withDefault:nil];
    NSDictionary *data = list[(NSUInteger) indexPath.row - 1];
    
    NSString *type = [data valueForKey:@"type" withDefault:@""];
    NSDictionary *t = [self typeFromId:type];
    
    NSString *title = [t valueForKey:@"name" withDefault:@""];
    
    // Prepare cell
    GarbageDateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.garbageLabel.text = title;
    cell.backgroundColor = [UIColor clearColor];
    
    // Fonts
    [[STAppSettingsManager sharedSettingsManager] setCustomFontForKey:@"garbage_calendar_view.garbage_label.font" toView:cell.garbageLabel];
    
    // draw circle
    UIView *circle = [cell circle];
    circle.layer.cornerRadius = circle.frame.size.width / 2;
    circle.backgroundColor = [cell circleColorForData:data];
    
    
    // check if the cell is the first of last in the section in order to round the corners
    NSInteger numberOfRowsInSection = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    [cell.separator setHidden:NO];
    if (indexPath.row == 1 || indexPath.row == numberOfRowsInSection - 1)
    {
        if (indexPath.row == numberOfRowsInSection - 1)
        {
            [cell cornerRadiusForCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)];
            [cell.separator setHidden:YES];
        }
        else
        {
            [cell cornerRadiusForCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)];
        }
    }
    else cell.dataView.layer.mask = nil;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionData = [GarbageCalendarManager sharedInstance].results[(NSUInteger) indexPath.section];
    NSArray *list = [sectionData valueForKey:@"list" withDefault:nil];
    NSDictionary *rowData = list[(NSUInteger) indexPath.row - 1];
    
    [[STRequestsHandler sharedInstance] itemDetailsForURL:rowData[@"url"] completion:^(STDetailGenericModel *itemDetails, NSDictionary* responseDict, NSError *error) {
        if (!error)
        {
            STDetailViewController * detailView = [[STDetailViewController alloc] initWithDataModel:itemDetails];
            [self.navigationController pushViewController:detailView animated:YES];
        }
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Header View

- (UITableViewCell *)createHeaderViewForHeaderInSection:(NSInteger)section
{
    GarbageDateHeaderView *myHeader = [_tableView dequeueReusableCellWithIdentifier:headerCellIdentifier];
    myHeader.selectionStyle = UITableViewCellSelectionStyleNone;
    myHeader.contentView.backgroundColor = [UIColor clearColor];
    
    NSDictionary *sectionData = [GarbageCalendarManager sharedInstance].results[(NSUInteger) section];
    NSString *dateString = [sectionData valueForKey:@"date" withDefault:nil];
    
    NSDate *date = [self.inputDateFormatter dateFromString:dateString];
    
    dateString = [self.outputDateFormatter stringFromDate:date];
    
    if ([date isToday])         dateString = [@"Heute - " stringByAppendingString:dateString];
    else if ([date isTomorrow]) dateString = [@"Morgen - " stringByAppendingString:dateString];

    myHeader.dateLabel.text = [dateString uppercaseString];
    myHeader.dateLabel.textColor = [UIColor whiteColor];
    
    // Font
    [[STAppSettingsManager sharedSettingsManager] setCustomFontForKey:@"garbage_calendar_view.garbage_header.font" toView:myHeader.dateLabel];
    
    return myHeader;
}

#pragma mark - Helper Methods

- (NSDictionary *)typeFromId:(NSString *)id {
    for (NSDictionary *t in [GarbageCalendarManager sharedInstance].garbageTypes) {
        NSString *item_id = [t valueForKey:@"enum" withDefault:nil];
        if ([item_id isEqualToString:id]) {
            return t;
        }
    }
    return nil;
}


- (NSDateFormatter *)inputDateFormatter {
    if (_inputDateFormatter == nil) {
        _inputDateFormatter= [[NSDateFormatter alloc] init];
        [_inputDateFormatter setDateFormat:@"dd.MM.yyy"];
    }
    return _inputDateFormatter;
}

- (NSDateFormatter *)outputDateFormatter {
    if (_outputDateFormatter == nil) {
        _outputDateFormatter = [[NSDateFormatter alloc] init];
        [_outputDateFormatter setDateFormat:@"EEEE, dd. MMMM"];
    }
    return _outputDateFormatter;
}

@end
