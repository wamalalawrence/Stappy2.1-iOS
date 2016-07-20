//
//  TankUndLadesaulenViewController.h
//  Stappy2
//
//  Created by Pavel Nemecek on 04/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STTankStationsViewController : UIViewController

@property(nonatomic,strong)NSString *stationsId;
-(void)fetchTankStationsFromServerWithId;
@end
