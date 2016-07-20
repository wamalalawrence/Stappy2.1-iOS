//
//  ZaehlerstandMainViewController.h
//  Stappy2
//
//  Created by Andrei Neag on 01.04.2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZaehlerstandMainViewController : UIViewController
@property (retain, nonatomic) NSString * selectedItemTitle;
@property (weak, nonatomic) IBOutlet UIButton *manualEnterButton;
@property (weak, nonatomic) IBOutlet UILabel *zaehlerstandLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *topSegmentedControl;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
- (IBAction)manualButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *containerView;
- (IBAction)segmenteControllChanged:(UISegmentedControl *)sender;


@end
