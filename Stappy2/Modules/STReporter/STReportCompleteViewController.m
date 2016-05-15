//
//  STReportCompleteViewController.m
//  Stappy2
//
//  Created by Pavel Nemecek on 12/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReportCompleteViewController.h"
#import "STAppSettingsManager.h"

@interface STReportCompleteViewController ()

@property(nonatomic,weak) IBOutlet UILabel *titleLabel;
@property(nonatomic,weak) IBOutlet UILabel *subTitleLabel;
@property(nonatomic,weak) IBOutlet UIButton *dismissButton;
-(IBAction)dismissButtonTapped:(id)sender;
@end

@implementation STReportCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    [self customizeAppearance];
}
-(void)customizeAppearance{
    UIFont* titleFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.mainHeaderTitle.font"];
    UIFont* subTitleFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.headerTitle.font"];
    UIFont* buttonTextFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.buttonText.font"];
    
    if (buttonTextFont) {
        self.dismissButton.titleLabel.font = buttonTextFont;
    }
    if (titleFont) {
        self.titleLabel.font = titleFont;
    }
    
    if (subTitleFont) {
        self.subTitleLabel.font = subTitleFont;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO]; 
}

-(IBAction)dismissButtonTapped:(id)sender{

    [self.navigationController popToRootViewControllerAnimated:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
