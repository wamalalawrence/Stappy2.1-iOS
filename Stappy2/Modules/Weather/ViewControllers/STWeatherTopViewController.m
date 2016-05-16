//
//  STWeatherTopViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 07/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STWeatherTopViewController.h"
#import "STWeatherTableViewCell.h"
#import "STWeatherHourlyModel.h"
#import "STWeatherModel.h"
#import "STWeatherCurrentObservation.h"
#import "STWeatherHeader.h"

#import "STRequestsHandler.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+STColor.h"
#import "STAppSettingsManager.h"
#import "NSString+Utils.h"

static NSString * const SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";

@interface STWeatherTopViewController ()

@property(nonatomic, strong)NSArray *hourlyForecasts;
@property(nonatomic, strong)NSArray *nextDaysForecasts;
@property(nonatomic, strong)NSDictionary *weatherDictionary;
@property(nonatomic, strong)STWeatherCurrentObservation* observation;
@property(nonatomic, assign, getter=isCurrentForecast)BOOL currentForecast;

- (void)changeForecastDate:(UISegmentedControl *) sender;

@end

@implementation STWeatherTopViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hourlyData:(NSArray*)hourlyData nextDAysData:(NSArray*)nextDaysData andObservation:(STWeatherCurrentObservation*)observation{
    if (self = [super initWithNibName:@"STWeatherTopViewController" bundle:nil]) {
        self.currentForecast = YES;
        self.hourlyForecasts = hourlyData;
        self.nextDaysForecasts = nextDaysData;
        self.observation = observation;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showHeader = false;
    [self initStadtwerkLayout];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    UINib *nib = [UINib nibWithNibName:@"STWeatherTableViewCell" bundle:nil];
    [self.weatherTable registerNib:nib forCellReuseIdentifier:@"weatherCell"];
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"STWeatherHeader" bundle:nil];
    [self.weatherTable registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
    
    //load the weather configuration file
    NSString* path = [[NSBundle mainBundle] pathForResource:@"weather_icons" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    NSDictionary* weatherDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    self.weatherDictionary = [weatherDict objectForKey:@"match_icons_condition"];
    
    [self populateCurrentObservationFrom:self.observation];
    self.weatherTable.clipsToBounds = false;
}

#pragma mark - Layout

-(void) initStadtwerkLayout
{
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *currentDateFont = [settings customFontForKey:@"weather.weather_header.current_date.font"];
    UIFont *currentTemperatureFont = [settings customFontForKey:@"weather.weather_header.current_temperature.font"];
    UIFont *currentConditionFont = [settings customFontForKey:@"weather.weather_header.current_condition.font"];
    UIFont *currentRainConditionFont = [settings customFontForKey:@"weather.weather_header.current_rain_condition.font"];
    UIFont *currentWindConditionFont = [settings customFontForKey:@"weather.weather_header.current_wind_condition.font"];
    
    if (currentDateFont) {
        [self.currentDate setFont:currentDateFont];
    }
    if (currentTemperatureFont) {
        [self.currentTemperature setFont:currentTemperatureFont];
    }
    if (currentConditionFont) {
        [self.currentCondition setFont:currentConditionFont];
    }
    if (currentRainConditionFont) {
        [self.currentRainCondition setFont:currentRainConditionFont];
    }
    if (currentWindConditionFont) {
        [self.currentWindCondition setFont:currentWindConditionFont];
    }
}

#pragma mark - UITableView data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.isCurrentForecast ? [self.hourlyForecasts count] : [self.nextDaysForecasts count];
}

//add segmented control changing the tables data source to the header view

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    STWeatherHeader *sectionHeaderView = (STWeatherHeader *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
    sectionHeaderView.weatherChangeSegmentedControl.tintColor = [UIColor partnerColor];    
    [sectionHeaderView.weatherChangeSegmentedControl addTarget:self action:@selector(changeForecastDate:) forControlEvents:UIControlEventValueChanged];
    sectionHeaderView.headerBackgroundView.alpha = self.showHeader ? 0.5 : 0;
    self.weatherHeader = sectionHeaderView;
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString* cellIdentifier = @"weatherCell";
    STWeatherTableViewCell * cell = [self.weatherTable dequeueReusableCellWithIdentifier:cellIdentifier];
    //check if we need to show information form the current forecast or the next days
    if (self.isCurrentForecast) {
        STWeatherHourlyModel* weatherModel = self.hourlyForecasts[indexPath.row];
        cell.condition.text = [weatherModel.condition capitalizedFirstLetter];
        NSString *imageUrl = weatherModel.imageForecastUrl;
        NSString* imageName = self.weatherDictionary[[NSString stringWithFormat:@"%@",weatherModel.icon]];
        UIImage * conditionsImage = [UIImage imageNamed:imageName];
        if (!conditionsImage) {
            cell.weatherIcon.image = [UIImage imageNamed:@"cloudy"];
        } else {
            cell.weatherIcon.image = conditionsImage;
        }
        NSString *temperature = weatherModel.temp;
        cell.degrees.text = [NSString stringWithFormat:@"%@° C",temperature];
        cell.timeOfForecast.text = weatherModel.hour;
        cell.precipPrediction.text = [NSString stringWithFormat:@"%@%%",weatherModel.rainChance];
        cell.windSpeed.text = [NSString stringWithFormat:@"%@km/h",weatherModel.windSpeed];
    }
    else {
        STWeatherModel* nextForecast = self.nextDaysForecasts[indexPath.row];
        cell.condition.text = [nextForecast.condition capitalizedFirstLetter];
        NSString *imageUrl = nextForecast.imageForecastUrl;
        NSString* imageName = self.weatherDictionary[[NSString stringWithFormat:@"%@",nextForecast.icon]];
        UIImage * conditionsImage = [UIImage imageNamed:imageName];
        if (!conditionsImage) {
            [cell.weatherIcon sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        } else {
            cell.weatherIcon.image = conditionsImage;
        }
        NSString* lowestTemperature = nextForecast.tempLow;
        NSString* highestTemperature = nextForecast.tempHigh;
        cell.degrees.text = [NSString stringWithFormat:@"%@/%@° C",lowestTemperature,highestTemperature];
        cell.precipPrediction.text = [NSString stringWithFormat:@"%d%%",nextForecast.rainChance];
        cell.windSpeed.text = [NSString stringWithFormat:@"%dkm/h",nextForecast.windSpeed];
        cell.timeOfForecast.text = [NSString stringWithFormat:@"%@,%d.%d.",nextForecast.dateDay,nextForecast.numericDay,nextForecast.numericMonth];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)changeForecastDate:(UISegmentedControl *) sender {
    if (sender.selectedSegmentIndex == 0) {
        //show today's hourly forecast
        self.currentForecast = YES;
        [sender setSelectedSegmentIndex:0];
        [self.weatherTable reloadData];
    } else {
        //show next days forecasts
        self.currentForecast = NO;
        [sender setSelectedSegmentIndex:1];
        [self.weatherTable reloadData];
    }
}

-(void)populateCurrentObservationFrom:(STWeatherCurrentObservation*)observation {
    NSString *imageUrl = observation.imageUrl;
    NSString* imageName = self.weatherDictionary[[NSString stringWithFormat:@"%@",observation.icon]];
    UIImage * conditionsImage = [UIImage imageNamed:imageName];
    if (!conditionsImage) {
        [self.currentWeatherIcon sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    } else {
        self.currentWeatherIcon.image = conditionsImage;
    }
    self.currentCondition.text = observation.condition;
    self.currentTemperature.text = [NSString stringWithFormat:@"%d° C", observation.temperature];
    self.currentRainCondition.text = [NSString stringWithFormat:@"%d%%",observation.precipitations];
    self.currentWindCondition.text = [NSString stringWithFormat:@"%dkm/h",observation.windSpeed];
    
}
@end
