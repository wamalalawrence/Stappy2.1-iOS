//
//  STWeatherViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 06/01/2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STWeatherViewController.h"
#import "STWeatherTopViewController.h"

#import "SWRevealViewController.h"
#import "BTGlassScrollView.h"
#import "STRequestsHandler.h"
#import "NSDate+DKHelper.h"
#import "NSBundle+DKHelper.h"
#import "STWeatherCurrentObservation.h"
#import "STWeatherHeader.h"
#import "STAppSettingsManager.h"
#import "STRegionManager.h"

//helpers
#import "NSString+Utils.h"
#import "STWeatherService.h"

@interface STWeatherViewController ()

@property(nonatomic, strong)STWeatherTopViewController *startView;
@property(nonatomic, strong)NSDictionary* weatherBackgroundDict;
@property(nonatomic, strong)NSArray *hourlyForecasts;
@property(nonatomic, strong)NSArray *nextDaysForecasts;
@property(nonatomic, strong)STWeatherCurrentObservation* observation;
@property(nonatomic, strong)NSString* glassViewBgImageName;
@property(nonatomic, assign)int topDistance;

@end

@implementation STWeatherViewController
{
    BTGlassScrollView *_glassScrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];

        [self.rightBarButton setTarget: self.revealViewController];
        [self.rightBarButton setAction: @selector(rightRevealToggle:)];
    }
    
    //load the weather configuration file
    NSString* path = [[NSBundle mainBundle] pathForResource:@"weather_icons" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    NSDictionary* weatherDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    self.weatherBackgroundDict = [weatherDict objectForKey:@"match_backgrounds_condition"];
    
    //request here the weather information so we know which background image to load
    //request the data to show the forecast
    __weak typeof(self) weakself = self;
    [[STWeatherService sharedInstance] weatherForCurrentDayAndForecastForRegion:self.region withCompletion:^(NSArray *hourlyWeatherArray, NSArray *nextDaysForecastArray, STWeatherCurrentObservation* observation, NSError *error) {
        __strong typeof(weakself) strongSelf = weakself;
        strongSelf.hourlyForecasts = hourlyWeatherArray;
        strongSelf.nextDaysForecasts = nextDaysForecastArray;
        strongSelf.observation = observation;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView* foregroundView = [self customViewWithHourlyData:self.hourlyForecasts nextDaysData:self.nextDaysForecasts andObservation:observation];
            self.glassViewBgImageName = [self.weatherBackgroundDict objectForKey:observation.icon];
            _glassScrollView = [[BTGlassScrollView alloc] initWithFrame:self.view.bounds BackgroundImage:[UIImage imageNamed:self.glassViewBgImageName] blurredImage:nil viewDistanceFromBottom:self.topDistance foregroundView:foregroundView];
            _glassScrollView.delegate = self;
            _glassScrollView.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
            _glassScrollView.blurredBackgroundImageView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:_glassScrollView];
            [self.view bringSubviewToFront:self.topDateContainer];
            _glassScrollView.removeRandomImages = YES;
            self.startView.weatherTable.scrollEnabled = NO;
        });
    }];
    self.backgroundBlurrImageView.needsBlur = YES;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EE dd.MM | HH.mm"];
        
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    NSString* cityName;
    if ([STRegionManager sharedInstance].selectedAndCurrentRegions.count == 1) {
        //if there is one region set the bundle name in order to allow special characters
        cityName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    else {
        cityName = _region;
    }
    self.dateContainerLabel.text = [NSString stringWithFormat:@"%@, %@ Uhr", cityName,stringFromDate];
    
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    
    UIFont *headerFont = [settings customFontForKey:@"lokalnews.header_view.weekDayLabel.font"];

    if (headerFont) {
        self.dateContainerLabel.font = headerFont;

    }
    
}

- (void)viewWillLayoutSubviews
{
    // if the view has navigation bar, this is a great place to realign the top part to allow navigation controller
    // or even the status bar
    [super viewWillLayoutSubviews];
    [_glassScrollView setTopLayoutGuideLength:[self.topLayoutGuide length] + 39];
}

- (UIView *)customViewWithHourlyData:(NSArray*)hourlyData nextDaysData:(NSArray*)nextDaysData andObservation:(STWeatherCurrentObservation*)observation
{
    // All the views will be added from xib.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect navBarRect = self.navigationController.navigationBar.bounds;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), screenRect.size.height - navBarRect.size.height - DEFAULT_BLUR_RADIUS - 10 - self.topDateContainer.frame.size.height)];
    view.backgroundColor = [UIColor clearColor];
    // We should move this logic inside a xib file. This is not working correctly when rotate.
    self.startView = [[STWeatherTopViewController alloc] initWithNibName:@"STWeatherTopViewController" bundle:nil hourlyData:self.hourlyForecasts nextDAysData:self.nextDaysForecasts andObservation:self.observation];
    self.startView.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), view.frame.size.height);
    [view addSubview:self.startView.view];
    self.topDistance = screenRect.size.height - (64 + self.startView.currentObservationContainer.bounds.size.height);
    return view;
}

- (BTGlassScrollView *)currentGlass
{
    return _glassScrollView;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_glassScrollView.foregroundScrollView]) {
        [self updateHeaderAlpha];
    }
}

-(void)updateHeaderAlpha {
    [_glassScrollView.blurredBackgroundImageView setAlpha:0];
    int minimumScrollPosition = -40.f;
    int maximumScrollPosition = _glassScrollView.foregroundScrollView.contentSize.height - _glassScrollView.foregroundScrollView.frame.size.height;
    //Enable scrolling on table when reach top position
    if (_glassScrollView.foregroundScrollView.contentOffset.y >= maximumScrollPosition) {
        _glassScrollView.foregroundScrollView.contentOffset = CGPointMake(0, maximumScrollPosition);
        //unable scroll on table
        self.startView.weatherTable.scrollEnabled = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.startView.weatherHeader.headerBackgroundView.alpha = 0.5;
            self.startView.showHeader = true;
        } completion:^(BOOL finished) {
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.startView.weatherHeader.headerBackgroundView.alpha = 0;
            self.startView.showHeader = false;
        } completion:^(BOOL finished) {
        }];
    }
    //Disable back scroll on table when reach bottom position
    if (_glassScrollView.foregroundScrollView.contentOffset.y == minimumScrollPosition) {
        //disable scroll on weather table
        self.startView.weatherTable.scrollEnabled = NO;
    }
}

- (NSString *)region { if (_region == nil) _region = [[STRegionManager sharedInstance] currentRegion]; return _region; }

@end
