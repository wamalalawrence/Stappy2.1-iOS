//
//  STReportAddressSearchViewController.h
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPrediction.h"
@protocol STReportAddressSearchViewControllerDelegate <NSObject>
@optional
-(void)searchControllerDidSelectPrediction:(STPrediction*)prediction;
 @end


@interface STReportAddressSearchViewController : UIViewController
@property (weak, nonatomic) id<STReportAddressSearchViewControllerDelegate> delegate;

@end
