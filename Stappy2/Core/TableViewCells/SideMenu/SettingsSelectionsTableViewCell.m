//
//  SettingsSelectionsTableViewCell.m
//  Schwedt
//
//  Created by Andrei Neag on 10.02.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "SettingsSelectionsTableViewCell.h"
#import "STLeftSideSubSettingsModel.h"
#import "STLeftMenuSettingsModel.h"
#import "STAppSettingsManager.h"

@implementation SettingsSelectionsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self initLayout];

    [_selectionIndicator setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switcherTapped)];
    [_selectionIndicator addGestureRecognizer:tapGestureRecognizer];
    _selectionsState = SettingsSelectionsStateNone;
    [self.contentView.superview setClipsToBounds:YES];
}

- (void)initLayout {
    UIFont *titleLabelFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"sidemenu.settings_cell.font"];
    if (titleLabelFont) [self.titleLabel setFont:titleLabelFont];
}

// Overridden setters
- (void)setMenuSubSettingsModel:(STLeftSideSubSettingsModel *)menuSubSettingsModel
{
    if (![_menuSubSettingsModel isEqual:menuSubSettingsModel])
    {
        // remove old model from KVO observation
        if (_menuSubSettingsModel) [_menuSubSettingsModel removeObserver:self forKeyPath:@"selectionState"];

        _menuSubSettingsModel = menuSubSettingsModel;

        // add model to the observation
        [_menuSubSettingsModel addObserver:self forKeyPath:@"selectionState" options:NSKeyValueObservingOptionNew context:NULL];

        _selectionsState = menuSubSettingsModel.selectionState;

        self.expansionIndicator.hidden = (menuSubSettingsModel.subItems.count == 0);

        [self changeSelectionIndicatorToState:_selectionsState];
    }
}

- (void)switcherTapped
{
    switch (_selectionsState)
    {
        case SettingsSelectionsStateNone:
        case SettingsSelectionsStateSome: _selectionsState = SettingsSelectionsStateAll;  break;
        case SettingsSelectionsStateAll:  _selectionsState = SettingsSelectionsStateNone; break;
    }

    [_menuSubSettingsModel setAllSubitemsToState:_selectionsState];

    [self changeSelectionIndicatorToState:_selectionsState];

    // notify the delegate
    [_delegate settingsSelectionsTableViewCell:self switcherStateChanged:_selectionsState];
}

- (void)changeSelectionIndicatorToState:(SettingsSelectionsState)selectionsState
{
    NSString *selectionIndicatorName;
    switch(selectionsState)
    {
        case SettingsSelectionsStateNone: selectionIndicatorName = @"icon_tick";        break;
        case SettingsSelectionsStateSome: selectionIndicatorName = @"icon_tick_more";   break;
        case SettingsSelectionsStateAll:  selectionIndicatorName = @"icon_tick_active"; break;
    }
    
    _selectionIndicator.image = [UIImage imageNamed:selectionIndicatorName];
}

#pragma mark - KVO on model

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectionState"])
    {
        _selectionsState = _menuSubSettingsModel.selectionState;
        [self changeSelectionIndicatorToState:_selectionsState];
    }
}

- (void)dealloc { [_menuSubSettingsModel removeObserver:self forKeyPath:@"selectionState"]; }

@end
