//
//  STStadtInfoOverviewViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 25/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface STStadtInfoOverviewViewController : UIViewController<UITableViewDataSource,UITableViewDataSource,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *overviewTable;
@property (weak, nonatomic) IBOutlet UIButton *oderAlphabetically;
@property (weak, nonatomic) IBOutlet UIButton *showOpenedBusiness;
@property (weak, nonatomic) IBOutlet UIButton *leftHeaderButton;
@property (weak, nonatomic) IBOutlet UIButton *headerMapButton;
@property (weak, nonatomic) IBOutlet UILabel *headerCenterLabel;
@property (weak, nonatomic) IBOutlet UIButton *geoffneteButton;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property(nonatomic,strong)NSArray* overViewItems;
@property(nonatomic,strong)NSArray* backupOverviewItems;
@property(nonatomic, assign)BOOL ignoreFavoritesButton;

- (instancetype)initWithUrl:(NSString *)url title:(NSString *)title;

-(void)requestData;

@end
