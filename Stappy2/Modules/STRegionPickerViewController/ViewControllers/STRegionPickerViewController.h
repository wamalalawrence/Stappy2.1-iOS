//
//  STRegionPickerViewController.h
//  EndiosRegionPicker
//
//  Created by Thorsten Binnewies on 18.04.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "STRegionPickerSearchViewController.h"

typedef NS_ENUM (NSUInteger, PickerState) {
    PickerStateStart = 0,
    PickerStateSelect
};

@class RandomImageView;

@interface STRegionPickerViewController : UIViewController <CLLocationManagerDelegate, UIScrollViewDelegate, STRegionPickerSearchDelegate>

@property (weak, nonatomic) IBOutlet RandomImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIView *searchButtonBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)searchButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;
- (IBAction)actionButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UIImageView *messageIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *selectionScrollView;

@property (weak, nonatomic) IBOutlet UIView *startView;
@property (weak, nonatomic) IBOutlet UIImageView *startImageView;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;

@property PickerState currentState;

@end
