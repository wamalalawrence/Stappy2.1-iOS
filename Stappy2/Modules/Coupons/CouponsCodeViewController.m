//
//  CouponsCodeViewController.m
//  Stappy2
//
//  Created by Andrei Neag on 10.05.2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "CouponsCodeViewController.h"
#import "Utils.h"
#import "Defines.h"
#import "RandomImageView.h"

@interface CouponsCodeViewController ()

@end

@implementation CouponsCodeViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundImageView.needsBlur = YES;
    // Do any additional setup after loading the view.
    self.couponsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:kCouponScreenShown];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)contentViewTapped:(UITapGestureRecognizer *)sender {
    [self.couponNumberTextField resignFirstResponder];
}

- (IBAction)startEnteringCouponNumber:(UITextField *)sender {
    
}

- (IBAction)couponNumberEditFinished:(UITextField *)sender {
    [self.couponNumberTextField resignFirstResponder];
}

- (IBAction)validateCouponCodeButtonPressed:(UIButton *)sender {
    [self validateAndSaveCouponCode];
}

- (IBAction)skipButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)validateAndSaveCouponCode {
    NSString * couponCode = self.couponNumberTextField.text;
    if ([Utils isCouponCodeValid:couponCode]) {
        [[NSUserDefaults standardUserDefaults] setObject:couponCode forKey:kActiveCouponCode];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self dismissViewControllerAnimated:true completion:nil];
    } else {
        // Show alert
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Kundennummer Error" message:@"Die eingegebene Kundennummer ist leider ungültig." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] ;
        [alert show];
    }
}

@end