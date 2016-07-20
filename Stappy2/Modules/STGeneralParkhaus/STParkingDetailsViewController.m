//
//  STParkingDetailsViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 12/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STParkingDetailsViewController.h"
#import "STParkHausModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "STRequestsHandler.h"

static NSString *parkingDomain = @"http://parkinghq.com";

@interface STParkingDetailsViewController ()

@property(nonatomic,strong)STParkHausModel *dataModel;

@end

@implementation STParkingDetailsViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDataModel:(STParkHausModel *)dataModel {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        self.dataModel = dataModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self updateUI];
}

- (void)updateUI {
    
    if (self.dataModel.image_url && self.dataModel.image_url.length > 0) {
        NSURL* imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",parkingDomain,self.dataModel.image_url]];
        [self.parkingImge sd_setImageWithURL:imageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageUrl) {
            if (!image) {
                self.parkingImge.image = [UIImage imageNamed:@"image_content_article_default"];
            }
        }];
    }
//    self.openinHoursWebView
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
