//
//  STWeatherTableViewCell.m
//  Stappy2
//
//  Created by Cynthia Codrea on 07/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STWeatherTableViewCell.h"
#import "STAppSettingsManager.h"

@implementation STWeatherTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self initStadtwerkLayout];
    self.weatherBackground.layer.cornerRadius = 5;
    self.weatherBackground.clipsToBounds = true;
}

-(void) initStadtwerkLayout
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *conditionLabelFont = [settings customFontForKey:@"weather.weather_cell.condition_label.font"];
    UIFont *timeOfForecastLabelFont = [settings customFontForKey:@"weather.weather_cell.time_of_forecast_label.font"];
    UIFont *degreesLabelFont = [settings customFontForKey:@"weather.weather_cell.degrees_label.font"];
    UIFont *precipPredictionLabelFont = [settings customFontForKey:@"weather.weather_cell.precip_prediction_label.font"];
    UIFont *windSpeedLabelFont = [settings customFontForKey:@"weather.weather_cell.wind_speed_label.font"];
    
    if (conditionLabelFont) {
        [self.condition setFont:conditionLabelFont];
    }
    if (timeOfForecastLabelFont) {
        [self.timeOfForecast setFont:timeOfForecastLabelFont];
    }
    if (degreesLabelFont) {
        [self.degrees setFont:degreesLabelFont];
    }
    if (precipPredictionLabelFont) {
        [self.precipPrediction setFont:precipPredictionLabelFont];
    }
    if (windSpeedLabelFont) {
        [self.windSpeed setFont:windSpeedLabelFont];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
