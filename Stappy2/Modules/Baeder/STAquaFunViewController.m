//
//  STAquaFunViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 28/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STAquaFunViewController.h"
#import "STRequestsHandler.h"
#import "STAppSettingsManager.h"

@interface STAquaFunViewController ()

@end

@implementation STAquaFunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)requestData {
    
    //request the data for the overview table
    __weak typeof(self) weakself = self;
    //get the ID from the configuration file
    NSString* requestUrl = [STAppSettingsManager sharedSettingsManager].aquaUrl;
    [[STRequestsHandler sharedInstance] allStadtInfoOverviewItemsWithUrl:requestUrl andCompletion:^(NSArray *overviewItems, NSError *error) {
        __strong typeof(weakself) strongSelf = weakself;
        strongSelf.overViewItems = overviewItems;
        strongSelf.backupOverviewItems = overviewItems;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.overviewTable reloadData];
        });
    }];
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
