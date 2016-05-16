//
//  STRegionPickerSearchViewController.h
//  EndiosRegionPicker
//
//  Created by Thorsten Binnewies on 20.04.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STRegionPickerSearchDelegate <NSObject>

@optional - (void)searchFinished:(NSDictionary*)regionDict;

@end

@interface STRegionPickerSearchViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
- (IBAction)saveButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *allRegions;

@end
