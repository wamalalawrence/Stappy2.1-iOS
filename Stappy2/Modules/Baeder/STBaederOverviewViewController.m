//
//  STBaederOverviewViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 08/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STBaederOverviewViewController.h"
#import "STRequestsHandler.h"

@interface STBaederOverviewViewController ()

@end

@implementation STBaederOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"menu.png"];
}

-(void)requestData {
    
    //request the data for the overview table
    __weak typeof(self) weakself = self;
    [[STRequestsHandler sharedInstance] allStadtInfoOverviewItemsWithUrl:@"/sinfo?id=5153" andCompletion:^(NSArray *overviewItems, NSError *error) {
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
