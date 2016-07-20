//
// Created by Denis Grebennicov on 23/05/16.
// Copyright (c) 2016 endios GmbH. All rights reserved.
//

#import "STWeatherPageViewController.h"
#import "STWeatherViewController.h"
#import "SWRevealViewController.h"
#import "STRegionManager.h"

@interface STWeatherPageViewController ()
@property (nonatomic, strong) NSMutableArray *weatherViewControllers;
@end

@implementation STWeatherPageViewController

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options
{ return [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:navigationOrientation options:options]; }

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self.revealViewController action:@selector(revealToggle:)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right_menu_open"] style:UIBarButtonItemStylePlain target:self.revealViewController action:@selector(rightRevealToggle:)];
    }
    
    self.dataSource = self;

    _weatherViewControllers = [NSMutableArray array];

    for (NSString *region in [[STRegionManager sharedInstance] selectedAndCurrentRegions])
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        STWeatherViewController *weatherVC = [storyBoard instantiateViewControllerWithIdentifier:@"STWeatherViewController"];
        weatherVC.region = region;
        [_weatherViewControllers addObject:weatherVC];
    }

    [self setViewControllers:@[_weatherViewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [_weatherViewControllers indexOfObject:viewController];

    if (index > 0) return _weatherViewControllers[--index];
    else           return nil;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [_weatherViewControllers indexOfObject:viewController];

    if (index < _weatherViewControllers.count - 1) return _weatherViewControllers[++index];
    return nil;
}

@end