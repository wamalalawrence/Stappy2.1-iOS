//
//  CouponsCodeViewController.h
//  Stappy2
//
//  Created by Andrei Neag on 10.05.2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StappyTextField.h"
@class RandomImageView;

@interface CouponsCodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet StappyTextField *couponNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *couponsButton;
@property (weak, nonatomic) IBOutlet RandomImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *couponsBodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@end
