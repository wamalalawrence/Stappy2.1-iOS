//
//  GarbageCalendarSettingsViewController.h
//  Stappy2
//
//  Created by Denis Grebennicov on 16/04/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GarbageTypesTableViewCell.h"
#import <MLPAutoCompleteTextField/MLPAutoCompleteTextField.h>

@import SMSegmentView;

@interface GarbageCalendarSettingsViewController : UIViewController <UITableViewDataSource, MLPAutoCompleteTextFieldDataSource, GarbageTypesTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UILabel *beforeZipAndStreetLabel;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *zipTextField;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *streetTextField;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UIButton *showCalendarButton;
@property (strong, nonatomic) SMSegmentView *notificationSegmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *garbageTypesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *garbageTypesTableViewHeightConstraint;

- (instancetype)initSelf;

- (IBAction)showCalendar:(id)sender;
- (IBAction)notificationSegmenteControlValueChanged:(id)sender;

@end
