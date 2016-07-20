//
//  STViewController.m
//  Schwedt
//
//  Created by Andrej Albrecht on 08.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STViewController.h"
#import "SWRevealViewController.h"

@interface STViewController () <UIGestureRecognizerDelegate, SWRevealViewControllerDelegate>
@property (strong,nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (weak, readonly) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, readonly) IBOutlet UIBarButtonItem *rightBarButtonItem;
@end

@implementation STViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ( self.revealViewController )
    {
        /*
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnViewWithOpenedMenu:)];
        [self.view addGestureRecognizer:self.tapGestureRecognizer];
        self.tapGestureRecognizer.enabled = NO;
        
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        */
        
        //LeftButton
        [self.leftBarButtonItem setTarget: self.revealViewController];
        [self.leftBarButtonItem setAction: @selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
        
        //RightButton
        [self.rightBarButtonItem setTarget: self.revealViewController];
        [self.rightBarButtonItem setAction: @selector(rightRevealToggle:)];
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotificationWillMoveToPosition:)
                                                 name:@"revealViewController.willMoveToPosition" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotificationDidMoveToPosition:)
                                                 name:@"revealViewController.didMoveToPosition" object:nil];
     */
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIBarButtonItem *)leftBarButtonItem
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

-(UIBarButtonItem *)rightBarButtonItem
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications

/*
 //send notifications
 NSDictionary* userInfo = @{@"FrontViewPosition": @(position)};
 [[NSNotificationCenter defaultCenter] postNotificationName:@"revealViewController.willMoveToPosition" object:self userInfo:userInfo];
 NSDictionary* userInfo = @{@"FrontViewPosition": @(position)};
 [[NSNotificationCenter defaultCenter] postNotificationName:@"revealViewController.didMoveToPosition" object:self userInfo:userInfo];
 */

/*
-(void) receiveNotificationWillMoveToPosition:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"revealViewController.willMoveToPosition"])
    {
        
        NSDictionary* userInfo = notification.userInfo;
        FrontViewPosition position = (FrontViewPosition)userInfo[@"FrontViewPosition"];
        
        if(position == FrontViewPositionLeft){
            NSLog(@"FrontViewPositionLeft");
        }else if(position == FrontViewPositionRight){
            NSLog(@"FrontViewPositionRight");
        }
        
        if (position == FrontViewPositionRight || position == FrontViewPositionLeftSide) {
            self.sidebarMenuOpen = YES;
            
            for (UIView *view in [self.view subviews]) {
                view.userInteractionEnabled = NO;
            }
        } else if (position == FrontViewPositionLeft) {
            self.sidebarMenuOpen = NO;
            
            for (UIView *view in [self.view subviews]) {
                view.userInteractionEnabled = YES;
            }
        }
    }
}

-(void) receiveNotificationDidMoveToPosition:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"revealViewController.didMoveToPosition"])
    {
        NSDictionary* userInfo = notification.userInfo;
        FrontViewPosition position = (FrontViewPosition)userInfo[@"FrontViewPosition"];
        if(position == FrontViewPositionLeft) {
            self.sidebarMenuOpen = NO;
            self.tapGestureRecognizer.enabled = NO;
        } else {
            self.sidebarMenuOpen = YES;
            self.tapGestureRecognizer.enabled = YES;
        }
    }
}
*/


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - SWRevealViewController Delegate Methods

/*
 - (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
 {
 NSLog(@"position:%lu", position);
 
 if (position == FrontViewPositionRight || position == FrontViewPositionLeftSide) {
 self.tapGestureRecognizer.enabled = YES;
 //self.interactivePopGestureRecognizer.enabled = NO;
 //self.view.userInteractionEnabled = NO;
 self.mapView.userInteractionEnabled = NO;
 
 } else if (position == FrontViewPositionLeft) {
 self.tapGestureRecognizer.enabled = NO;
 //self.interactivePopGestureRecognizer.enabled = YES;
 //self.view.userInteractionEnabled = YES;
 self.mapView.userInteractionEnabled = YES;
 
 }
 }
 */

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    NSLog(@"willMoveToPosition");
    
    if(position == FrontViewPositionLeft){
        NSLog(@"FrontViewPositionLeft");
    }else if(position == FrontViewPositionRight){
        NSLog(@"FrontViewPositionRight");
    }
    
    if (position == FrontViewPositionRight || position == FrontViewPositionLeftSide) {
        self.sidebarMenuOpen = YES;
        
        for (UIView *view in [self.view subviews]) {
            view.userInteractionEnabled = NO;
        }
    } else if (position == FrontViewPositionLeft) {
        self.sidebarMenuOpen = NO;
        
        for (UIView *view in [self.view subviews]) {
            view.userInteractionEnabled = YES;
        }
    }
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    NSLog(@"didMoveToPosition");
    
    if(position == FrontViewPositionLeft) {
        self.sidebarMenuOpen = NO;
        self.tapGestureRecognizer.enabled = NO;
    } else {
        self.sidebarMenuOpen = YES;
        self.tapGestureRecognizer.enabled = YES;
    }
}

-(void)tapOnViewWithOpenedMenu:(id)sender
{
    if (self.revealViewController.frontViewPosition == FrontViewPositionRight) { // tap by opened left menu
        [self.revealViewController revealToggleAnimated:YES];
        
    }else if (self.revealViewController.frontViewPosition == FrontViewPositionLeftSide){ // tap by opened right menu
        [self.revealViewController rightRevealToggleAnimated:YES];
        
    }
}

@end
