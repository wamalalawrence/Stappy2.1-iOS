//
//  GarbageCalendarSettingsViewController.m
//  Stappy2
//
//  Created by Denis Grebennicov on 16/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "GarbageCalendarSettingsViewController.h"
#import "GarbageCalendarViewController.h"

#import "UIColor+STColor.h"
#import "STAppSettingsManager.h"

#import "Stappy2-Swift.h"

static NSString *cellIdentifier = @"garbageTypes";

@implementation GarbageCalendarSettingsViewController

- (instancetype)initSelf { return [super initWithNibName:@"GarbageCalendarSettingsViewController" bundle:nil]; }

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[GarbageCalendarViewController class]] ||
        ![GarbageCalendarManager sharedInstance].isConfigured)
    {
        return [self initSelf];
    }
    
    return [[GarbageCalendarViewController alloc] init];
}

- (void)viewDidLoad
{
    self.title = @"ABFALLKALENDER";
    
   
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithImage:[UIImage imageNamed:@"menu.png"]
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(goBack)];
    
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *navigationbarTitleFont = [settings customFontForKey:@"navigationbar.title.font"];
    
    if (navigationbarTitleFont) {
        [btnBack setTitleTextAttributes:@{NSFontAttributeName:navigationbarTitleFont} forState:UIControlStateNormal];
    }
    self.navigationController.navigationBar.topItem.leftBarButtonItem = btnBack;
    
    _showCalendarButton.layer.borderWidth = 1;
    _showCalendarButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    for (MLPAutoCompleteTextField *textField in @[_zipTextField, _streetTextField])
    {
        textField.autoCompleteTableBorderColor = [UIColor partnerColor];
        textField.autoCompleteTableCellTextColor = [UIColor blackColor];
        textField.autoCompleteDataSource = self;
        textField.showTextFieldDropShadowWhenAutoCompleteTableIsOpen = NO;
    }
    
    _streetTextField.showAutoCompleteTableWhenEditingBegins = YES;
    
    _zipTextField.autoCompleteDataSource = self;
    _streetTextField.autoCompleteDataSource = self;
    
    _garbageTypesTableView.dataSource = self;
    
    [_garbageTypesTableView registerNib:[UINib nibWithNibName:NSStringFromClass([GarbageTypesTableViewCell class])
                                                       bundle:[NSBundle mainBundle]]
                 forCellReuseIdentifier:cellIdentifier];
    
    _garbageTypesTableViewHeightConstraint.constant = [GarbageCalendarManager sharedInstance].garbageTypes.count * 44.0;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_blurred"]]];
    
    // SMSegmentView configuration
    _notificationSegmentedControl = [[SMSegmentView alloc] initWithFrame:CGRectMake(10, _notificationLabel.frame.origin.y + _notificationLabel.frame.size.height + 10, [UIScreen mainScreen].bounds.size.width - 20, 30) separatorColour:[UIColor lightGrayColor] separatorWidth:1 segmentProperties:nil];
    [self.view.subviews[0] addSubview:_notificationSegmentedControl];
    
    [_notificationSegmentedControl addSegmentWithTitle:@"GAR NICHT" onSelectionImage:nil offSelectionImage:nil];
    [_notificationSegmentedControl addSegmentWithTitle:@"21 UHR" onSelectionImage:nil offSelectionImage:nil];
    [_notificationSegmentedControl addSegmentWithTitle:@"7 UHR" onSelectionImage:nil offSelectionImage:nil];
    
    _notificationSegmentedControl.segmentOffSelectionColour = [UIColor colorWithWhite:0 alpha:0.6];
    _notificationSegmentedControl.segmentOnSelectionColour = [UIColor partnerColor];
    _notificationSegmentedControl.segmentOnSelectionTextColour = [UIColor whiteColor];
    _notificationSegmentedControl.segmentOffSelectionTextColour = [UIColor whiteColor];
    
    _notificationSegmentedControl.layer.cornerRadius = 3.0;
    
    // Fonts
    _notificationSegmentedControl.segmentTitleFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"garbage_calendar_settings.segmented_control.font"];
    [self configureFonts];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureFonts
{
    [[STAppSettingsManager sharedSettingsManager] setCustomFontForKey:@"garbage_calendar_settings.before_zip.font" toView:_beforeZipAndStreetLabel];
    [[STAppSettingsManager sharedSettingsManager] setCustomFontForKey:@"garbage_calendar_settings.notification_label.font" toView:_notificationLabel];
    [[STAppSettingsManager sharedSettingsManager] setCustomFontForKey:@"garbage_calendar_settings.zip.font" toView:_zipTextField];
    [[STAppSettingsManager sharedSettingsManager] setCustomFontForKey:@"garbage_calendar_settings.street.font" toView:_streetTextField];
    [[STAppSettingsManager sharedSettingsManager] setCustomFontForKey:@"garbage_calendar_settings.show_calendar_button.font" toView:_showCalendarButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    GarbageCalendarManager *manager = [GarbageCalendarManager sharedInstance];
    
    _zipTextField.text = manager.zip;
    _streetTextField.text = manager.street;
    
    [_notificationSegmentedControl selectSegmentAtIndex:manager.reminderType];
}

- (void)viewWillDisappear:(BOOL)animated
{
    GarbageCalendarManager *manager = [GarbageCalendarManager sharedInstance];
    
    manager.zip = _zipTextField.text;
    manager.street = _streetTextField.text;
    manager.reminderType = _notificationSegmentedControl.indexOfSelectedSegment;
    
    [manager save];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [GarbageCalendarManager sharedInstance].garbageTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GarbageTypesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *data = [GarbageCalendarManager sharedInstance].garbageTypes[indexPath.row];
    
    cell.delegate = self;
    cell.garbageTypeLabel.text = data[@"name"];
    cell.garbageTypeSwitch.tintColor = [UIColor partnerColor];
    cell.garbageTypeSwitch.onTintColor = [UIColor partnerColor];
    
    // Font
    [[STAppSettingsManager sharedSettingsManager] setCustomFontForKey:@"garbage_calendar_settings.cell.garbage_label.font"
                                                               toView:cell.garbageTypeLabel];
    
    BOOL selected = NO;
    for (NSDictionary *dict in [GarbageCalendarManager sharedInstance].enabledGarbageTypes)
    {
        if ([dict isEqualToDictionary:data]) selected = YES;
    }
    
    [cell.garbageTypeSwitch setOn:selected];
    
    // draw circle
    CGRect circleFrame = cell.garbageTypeImageView.frame;
    circleFrame.origin.x -= 3;
    circleFrame.origin.y -= 3;
    circleFrame.size.width  += 6;
    circleFrame.size.height += 6;
    
    UIView *circle = [[UIView alloc] initWithFrame:circleFrame];
    circle.layer.cornerRadius = circleFrame.size.width / 2;
    circle.backgroundColor = [cell circleColorForData:data];
    [cell addSubview:circle];
    [cell sendSubviewToBack:circle];
    
    return cell;
}

- (IBAction)showCalendar:(id)sender
{
    [[GarbageCalendarManager sharedInstance] configureWithZip:_zipTextField.text
                                                       street:_streetTextField.text
                                                   completion:^(NSArray *data, NSError *error)
    {
        if (!error)
        {
            UIViewController *preLastViewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
            
            if ([preLastViewController isKindOfClass:[GarbageCalendarViewController class]])
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                GarbageCalendarViewController *vc = [[GarbageCalendarViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Keine Termine gefunden"
                                        message:@"Leider konnten für die eingegebenen Daten keine Termine gefunden werden. Möglicherweise sollten Sie die PLZ, Straße und die ausgewählten Müllarten kontrollieren."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            NSLog(@"----- ERROR -----\n%@", error);
        }
    }];
}

#pragma mark - Autocompletion

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void(^)(NSArray *suggestions))handler
{
    if (textField == _zipTextField)
    {
        [[GarbageCalenderService sharedInstance] possibleZips:string completion:^(NSArray<NSString *> *possibleZips) {
            handler(possibleZips);
        }];
        _streetTextField.text = @"";
    }
    else
    {
        [[GarbageCalenderService sharedInstance] possibleStreetsForZip:_zipTextField.text street:string completion:^(NSArray<NSString *> *possibleStreets) {
            if (possibleStreets.count == 0)
            {
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"Es konnte keine Straße gefunden werden. Bitte eine neue Straße wählen!"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [_streetTextField resignFirstResponder];
                _streetTextField.text = @"";
            }
            handler(possibleStreets);
        }];
    }
}

#pragma mark - GarbageTypesTableViewCellDelegate

- (void)garbageTypesTableViewCell:(GarbageTypesTableViewCell *)cell toggleSwitch:(UISwitch *)sender
{
    NSIndexPath *indexPath = [_garbageTypesTableView indexPathForCell:cell];
    
    NSDictionary *data = [GarbageCalendarManager sharedInstance].garbageTypes[indexPath.row];
    
    NSMutableArray *newEnabledGarbageTypes = [NSMutableArray arrayWithArray:[GarbageCalendarManager sharedInstance].enabledGarbageTypes];
    
    if (sender.isOn) [newEnabledGarbageTypes addObject:data];
    else             [newEnabledGarbageTypes removeObject:data];
    
    [GarbageCalendarManager sharedInstance].enabledGarbageTypes = newEnabledGarbageTypes;
}
- (IBAction)tapGestureRecognized:(UITapGestureRecognizer *)sender {
    [_zipTextField resignFirstResponder];
    [_streetTextField resignFirstResponder];
}

@end
