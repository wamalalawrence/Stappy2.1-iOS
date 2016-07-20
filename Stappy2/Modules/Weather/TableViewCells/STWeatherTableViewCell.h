//
//  STWeatherTableViewCell.h
//  Stappy2
//
//  Created by Cynthia Codrea on 07/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STWeatherTableViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel* condition;
@property (weak, nonatomic) IBOutlet UIImageView *weatherIcon;
@property (weak, nonatomic) IBOutlet UILabel *timeOfForecast;
@property (weak, nonatomic) IBOutlet UILabel *degrees;
@property (weak, nonatomic) IBOutlet UILabel *precipPrediction;
@property (weak, nonatomic) IBOutlet UILabel *windSpeed;
@property (weak, nonatomic) IBOutlet UIView *weatherBackground;


@end
