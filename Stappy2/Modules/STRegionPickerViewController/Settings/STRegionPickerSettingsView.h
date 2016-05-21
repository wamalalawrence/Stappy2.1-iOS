//
//  STRegionPickerSettingsView.h
//  Stappy2
//
//  Created by Denis Grebennicov on 21/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STRegionPickerSettingsViewDelegate <NSObject>
- (void)regionsButtonWasPressed;
@end

@interface STRegionPickerSettingsView : UIView
@property (weak, nonatomic) IBOutlet UIButton *selectRegionsButton;
@property (weak, nonatomic) id<STRegionPickerSettingsViewDelegate> delegate;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (instancetype)initWithFrame:(CGRect)frame;

- (IBAction)selectRegionsButtonPressed:(id)sender;
@end
