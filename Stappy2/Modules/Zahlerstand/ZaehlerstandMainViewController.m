//
//  ZaehlerstandMainViewController.m
//  Stappy2
//
//  Created by Andrei Neag on 01.04.2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "ZaehlerstandMainViewController.h"
#import "SaehlerstandEingebenViewController.h"
#import "CALayer+Additions.h"
#import "STAppSettingsManager.h"

//categories
#import "UIColor+STColor.h"
#import "UIImage+tintImage.h"

@interface ZaehlerstandMainViewController ()

@end

@implementation ZaehlerstandMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.selectedItemTitle = [NSString string];
    self.manualEnterButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [self.topSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [self.topSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
    
    //remove borders
    [self.topSegmentedControl setBackgroundImage:[UIImage st_imageWithColor:[UIColor transparencyColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.topSegmentedControl setBackgroundImage:[UIImage st_imageWithColor:[UIColor secondaryColor]] forState:UIControlStateSelected  barMetrics:UIBarMetricsDefault];
    
    self.containerView.backgroundColor = [UIColor whiteColor];

    
    [self setFonts];
}

-(void)setFonts {
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *titleFont = [settings customFontForKey:@"detailscreen.title.font"];
    
    if (titleFont) {
        self.manualEnterButton.titleLabel.font = titleFont;
        
        self.manualEnterButton.layer.borderColor = [UIColor partnerColor].CGColor;
        [self.manualEnterButton setTitleColor:[UIColor partnerColor] forState:UIControlStateNormal];
        
        self.zaehlerstandLabel.font = titleFont;
        self.infoLabel.font = titleFont;
    }
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)manualButtonPressed:(UIButton *)sender {
    SaehlerstandEingebenViewController * manualScreen = [[SaehlerstandEingebenViewController alloc] initWithNibName:@"SaehlerstandEingebenViewController" bundle:nil];
    manualScreen.previousSelectedUtiliityTitle = self.selectedItemTitle;
    [self.navigationController pushViewController:manualScreen animated:YES];
}

- (IBAction)segmenteControllChanged:(UISegmentedControl *)sender {
    [self updateLabels];
}

- (void)updateLabels {
    self.selectedItemTitle = @"Strom";
    switch (self.topSegmentedControl.selectedSegmentIndex) {
        case 0:
            self.selectedItemTitle = @"Strom";
            break;
        case 1:
            self.selectedItemTitle = @"Wasser";
            break;
        default:
            self.selectedItemTitle = @"Gas";
            break;
    }
    self.zaehlerstandLabel.text = [NSString stringWithFormat:@"%@-Zählerstand", self.selectedItemTitle];
}

@end
