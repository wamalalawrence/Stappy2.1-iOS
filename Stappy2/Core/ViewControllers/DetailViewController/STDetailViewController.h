//
//  STDetailViewController.h
//  Stappy2
//
//  Created by Pavel Nemecek on 21/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STMainModel;
@class STTankStationModel;
@class STParkHausModel;
@class STGeneralParkhausModel;

@interface STDetailViewController : UIViewController

@property(nonatomic, assign)BOOL ignoreFavoritesButton;
@property(nonatomic, assign)BOOL ignoreCalenderButton;

-(instancetype)initWithDataModel:(STMainModel *)dataModel;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDataModel:(STMainModel *)dataModel;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParkHausModel:(STParkHausModel *)parkHauseModel;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTankStationModel:(STTankStationModel *)tankStationModel;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGeneralParkHausModel:(STGeneralParkhausModel *)parkHauseModel;



@end
