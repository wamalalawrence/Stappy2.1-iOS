//
//  Indicators.h
//  Stappy2
//
//  Created by Denis Grebennicov on 26/03/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Indicators : UIView
@property (weak, nonatomic) IBOutlet UIImageView *leftArrow;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrow;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic) NSInteger currentIndicator;
@property (nonatomic) NSInteger totalNumberOfPages;
@property (nonatomic) NSInteger maxNumberOfIndicatorsPerPage;

@end