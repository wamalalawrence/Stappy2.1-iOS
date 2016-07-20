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

@property(nonatomic,strong)NSArray* zaehlerstandItems;

@end

@implementation ZaehlerstandMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //get Options from configuration file for the segmented control
    if ([STAppSettingsManager sharedSettingsManager].zaehlerstandItems) {
        self.zaehlerstandItems = [STAppSettingsManager sharedSettingsManager].zaehlerstandItems;
        [self setSegments:self.zaehlerstandItems];
    }
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
    NSString* selectedTitle = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    self.zaehlerstandLabel.text = [NSString stringWithFormat:@"%@-Zählerstand", selectedTitle];
}

- (void)setSegments:(NSArray *)segments
{
    [self.topSegmentedControl removeAllSegments];
    
    for (NSString *segment in segments) {
        [self.topSegmentedControl insertSegmentWithTitle:segment atIndex:self.topSegmentedControl.numberOfSegments animated:NO];
    }
}

@end
