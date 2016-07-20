//
//  SettingsSelectionsTableViewCell.h
//  Schwedt
//
//  Created by Andrei Neag on 10.02.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STLeftSideSubSettingsModel;
@class STLeftMenuSettingsModel;
@class SettingsSelectionsTableViewCell;

typedef NS_ENUM(NSInteger, SettingsSelectionsState)
{
    SettingsSelectionsStateUnknown,
    SettingsSelectionsStateNone,
    SettingsSelectionsStateSome,
    SettingsSelectionsStateAll
};

@protocol SettingsSelectionsTableViewCellDelegate <NSObject>
@required
- (void)settingsSelectionsTableViewCell:(SettingsSelectionsTableViewCell *)tableViewCell
                   switcherStateChanged:(SettingsSelectionsState)selectionsState;
@end

@interface SettingsSelectionsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *expansionIndicator;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectionIndicator;

@property (nonatomic, weak) STLeftSideSubSettingsModel *menuSubSettingsModel;

@property (nonatomic, weak) id<SettingsSelectionsTableViewCellDelegate> delegate;

@property (assign, nonatomic, getter = isExpanded) BOOL expanded;
@property (nonatomic, assign) SettingsSelectionsState selectionsState;

- (void)switcherTapped;
@end
