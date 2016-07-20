//
//  WeatherCustomHeaderView.m
//  Stappy2
//
//  Created by Cynthia Codrea on 11/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STWeatherHeader.h"
#import "UIColor+STColor.h"
#import "UIImage+tintImage.h"
#import "STAppSettingsManager.h"

@implementation STWeatherHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)changeForecastDate:(id)sender {
}

-(void)awakeFromNib {
    
    //remove borders
    [self.weatherChangeSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [self.weatherChangeSegmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];

    [self.weatherChangeSegmentedControl setBackgroundImage:[UIImage st_imageWithColor:[UIColor colorWithWhite:1.0 alpha:0.1]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [self.weatherChangeSegmentedControl setBackgroundImage:[UIImage st_imageWithColor:[UIColor partnerColor]] forState:UIControlStateSelected  barMetrics:UIBarMetricsDefault];
    
        STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
        UIFont *headerFont = [settings customFontForKey:@"detailscreen.time.font"];
    
    if (headerFont) {
        NSDictionary *highlightedAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:headerFont };
        
        [self.weatherChangeSegmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
         [self.weatherChangeSegmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateNormal]; [self.weatherChangeSegmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
     

    }

    

}

@end
