//
//  STQRCodeScannerViewController.m
//  Stappy2
//
//  Created by Denis Grebennicov on 26/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STQRCodeScannerViewController.h"
#import "UIImage+tintImageWithColor.h"
#import "SWRevealViewController.h"
#import "STWebViewDetailViewController.h"
#import "AppDelegate.h"

#define VIEW_WITH_BLURRED_BACKGROUND_HEIGHT 50
#define LASER_SCANNER_ANIMATION_DURATION_FROM_TOP_TO_BOTTOM 2.5

@interface STQRCodeScannerViewController ()
@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureDeviceInput* input;
@property (strong, nonatomic) AVCaptureMetadataOutput* output;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview;

@property (nonatomic, strong) UIImageView *laserView;
@property (nonatomic, assign, getter=isFound) BOOL found;
@end

@implementation STQRCodeScannerViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    /* Burger and navigation bar */
    //self.navigationController.navigationBar.backgroundColor = [UIColor orangeColor];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    self.sidebarButton.tintColor = [UIColor whiteColor];
    if (revealViewController)
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        
        [self.rightBarButton setTarget: self.revealViewController];
        [self.rightBarButton setAction: @selector(rightRevealToggle:)];
    }
    
    /* */
    _found = NO;
    
    [self createViewWithBlurredBackground];
    [self createFoundView];
    [self setupScanner];
    
    _laserView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"laserscanner.png"]];
    _laserView.frame = CGRectMake(0, VIEW_WITH_BLURRED_BACKGROUND_HEIGHT,
                                  self.view.frame.size.width, _laserView.frame.size.height);
    _laserView.alpha = 0;
    _laserView.image = [_laserView.image tintImageWithColor:[UIColor redColor]];
    
    [self.view addSubview:_laserView];
}

- (void)createViewWithBlurredBackground
{
    UILabel *instructionLabel = [[UILabel alloc] init];
    instructionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    instructionLabel.numberOfLines = 0;
    instructionLabel.textAlignment = NSTextAlignmentLeft;
    instructionLabel.text = @"Fokussieren Sie einen QR-Code";
    instructionLabel.textColor = [UIColor whiteColor];
    instructionLabel.font = [AppDelegate kievitFontWithSize:18];
    
    CGRect blurredViewFrame = CGRectMake(0, 0, self.view.frame.size.width, VIEW_WITH_BLURRED_BACKGROUND_HEIGHT);
    
    // check if the UIBlurEffect is available (is available for iOS8+)
    if ([UIBlurEffect class])
    {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *viewWithBlurredBackground = [[UIVisualEffectView alloc] initWithEffect:effect];
        viewWithBlurredBackground.frame = blurredViewFrame;
        
        instructionLabel.frame = CGRectMake(10, 0, self.view.frame.size.width, VIEW_WITH_BLURRED_BACKGROUND_HEIGHT);
        [viewWithBlurredBackground.contentView addSubview:instructionLabel];
        
        [self.view addSubview:viewWithBlurredBackground];
    }
    else
    {
        UIView *transparentView = [[UIView alloc] initWithFrame:blurredViewFrame];
        transparentView.backgroundColor = [UIColor lightGrayColor];
        transparentView.alpha = 0.7;
        
        instructionLabel.highlightedTextColor = [UIColor blackColor];
        instructionLabel.highlighted = YES;
        instructionLabel.frame = transparentView.frame;
        
        [transparentView addSubview:instructionLabel];
        [self.view addSubview:transparentView];
    }
}

-(void)createFoundView
{
    self.recognizedQRCodeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.recognizedQRCodeView.layer.cornerRadius = 5.0;
    self.recognizedQRCodeView.alpha = 0;
}

- (void)setupScanner
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    if (!self.input) return;
    
    self.session = [[AVCaptureSession alloc] init];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    AVCaptureConnection *con = self.preview.connection;
    
    con.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.input)
    {
        [[[UIAlertView alloc] initWithTitle:@"Kamerafunktion deaktiviert"
                                    message:@"Bitte Zugriff auf Kamera akzeptieren."
                                   delegate:self
                          cancelButtonTitle:@"Abbruch"
                          otherButtonTitles:@"Freischalten", nil] show];
        return;
    }
    
    if (self.isFound)
    {
        _recognizedQRCodeView.alpha = 0;
        _laserView.alpha = 0;
        self.found = NO;
    }
    
    if([self isCameraAvailable])
    {
        [self startScanning];
        [self startLaserScanner];
    }
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)evt
{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
    [self focus:pt];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for(AVMetadataObject *current in metadataObjects)
    {
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
        {
            NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];
            [self onFound:scannedValue];
        }
    }
}

#pragma mark - Helper methods

- (void)startScanning { [self.session startRunning]; }

- (void)stopScanning { [self.session stopRunning]; }

- (BOOL)isCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0 && self.input; // if self.input is not nil
}

- (void)focus:(CGPoint)aPoint
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([device isFocusPointOfInterestSupported] &&
       [device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        double screenWidth = screenRect.size.width;
        double screenHeight = screenRect.size.height;
        double focus_x = aPoint.x/screenWidth;
        double focus_y = aPoint.y/screenHeight;
        if([device lockForConfiguration:nil])
        {
            [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
         
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) [device setExposureMode:AVCaptureExposureModeAutoExpose];
            [device unlockForConfiguration];
        }
    }
}

- (void)showFoundViewWithText:(NSString *)text backgroundColor:(UIColor *)color transitionToNewController:(BOOL)willTransition {
    self.recognizedQRCodeLabel.text = text;
    self.found = YES;
    self.recognizedQRCodeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    [UIView animateKeyframesWithDuration:0.85 delay:0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.2 animations:^{ self.recognizedQRCodeView.alpha = 1; }];
        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.4 animations:^{ self.recognizedQRCodeView.backgroundColor = color; }];
        [UIView addKeyframeWithRelativeStartTime:0.6 relativeDuration:0.25 animations:^{
            const CGFloat *components = CGColorGetComponents([color CGColor]);
            CGFloat red = components[0];
            
            if (red == 1) self.recognizedQRCodeView.backgroundColor = [UIColor colorWithRed:0.78 green:0 blue:0 alpha:1];
            else          self.recognizedQRCodeView.backgroundColor = [UIColor colorWithRed:0 green:0.58 blue:0 alpha:1];
        }];
    } completion:^(BOOL finished) {
        if (willTransition) {
            STWebViewDetailViewController *webviewVC = [[STWebViewDetailViewController alloc] initWithNibName:nil bundle:nil andDetailUrl:text];
            [self.navigationController pushViewController:webviewVC animated:YES];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.5 animations:^{ self.recognizedQRCodeView.alpha = 0; }];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.found = NO;
                [self startLaserScanner];
            });
        }
    }];
}

- (void)onFound:(NSString *)value
{
    if (self.isFound)
    {
        [self stopLaserScanner];
        return;
    }
    
    if ([value hasPrefix:@"http"])
    {
        [self showFoundViewWithText:value
                    backgroundColor:[UIColor colorWithRed:0.25 green:1 blue:0.25 alpha:1.0]
          transitionToNewController:YES];
    }
    else
    {
        [self showFoundViewWithText:@"Sorry, in diesem QR-Code ist leider keine Web-Adresse enthalten!"
                    backgroundColor:[UIColor colorWithRed:1 green:0.25 blue:0.25 alpha:1.0]
          transitionToNewController:NO];
    }
}

#pragma mark - LaserView methods

- (void)startLaserScanner
{
    _laserView.frame = CGRectMake(0, VIEW_WITH_BLURRED_BACKGROUND_HEIGHT - 4, _laserView.frame.size.width, _laserView.frame.size.height);
    
    [UIView animateWithDuration:0.8 animations:^{ _laserView.alpha = 0.8; }];
    [UIView animateWithDuration:LASER_SCANNER_ANIMATION_DURATION_FROM_TOP_TO_BOTTOM
                          delay:0.2
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _laserView.frame = CGRectMake(0, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - 4,
                                                       _laserView.frame.size.width, _laserView.frame.size.height);
                     } completion:nil];
}

- (void)stopLaserScanner
{
    [_laserView.layer removeAllAnimations];
    _laserView.alpha = 0;
}

@end
