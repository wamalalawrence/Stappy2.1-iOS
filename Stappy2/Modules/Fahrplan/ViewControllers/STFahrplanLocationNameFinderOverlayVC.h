//
//  STFahrplanLocationNameFinderOverlayVC.h
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STFahrplanLocation.h"


@protocol STFahrplanLocationNameFinderDelegate <NSObject>
- (void)locationNameFinderAdressChoosed:(STFahrplanLocation *)adress;

@end

@interface STFahrplanLocationNameFinderOverlayVC : UIViewController

@property (weak, nonatomic) id<STFahrplanLocationNameFinderDelegate> delegate;
@property (strong, nonatomic) STFahrplanLocation *address;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@end
