//
//  STRegionPickerViewController.m
//  EndiosRegionPicker
//
//  Created by Thorsten Binnewies on 18.04.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STRegionPickerViewController.h"
#import "STRegionPickerSearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomBadge.h"
#import "BadgeStyle.h"
#import "RandomImageView.h"
#import "Defines.h"
#import "RandomImageView.h"
#import "Stappy2-Swift.h"

#import "STRegionManager.h"
#import "STRequestsHandler.h"

#define kNavBarTintColor [UIColor colorWithRed:26.0/255.0 green:96.0/255.0 blue:166.0/255.0 alpha:1.0]
//
#define kRegPickerJSONIdentifierRegions @"regions"
#define kRegPickerJSONIdentifierID @"id"
#define kRegPickerJSONIdentifierName @"name"
#define kRegPickerJSONIdentifierXPos @"xPos"
#define kRegPickerJSONIdentifierYPos @"yPos"
#define kRegPickerJSONIdentifierShortcut @"shortcut"
#define kRegPickerJSONIdentifierZipCodes @"zipCodes"
#define kRegPickerJSONIdentifierButton @"button"
#define kRegPickerJSONIdentifierIconButton @"iconButton"
//
#define kRegPickerMapImage @"map.png"
#define kRegPickerBackgroundImage @"image_content_bg_national_blur.jpg"
#define kRegPickerMessageIconSelect @"icon_tick_active1.png"
#define kRegPickerMessageIconDeselect @"icon_tick1.png"
#define kRegPickerNavBarIconLeft @"back"
#define kRegPickerNavBarIcon @"icon_content_badge_map_germany.png"
#define kRegPickerNavBarIconWithBadge @"icon_content_badge_map_germany_cutted.png"
#define kRegPickerMarkerIconSelected @"icon_regionenfilter_pin_active.png"
#define kRegPickerMarkerIconUnselected @"icon_regionenfilter_pin.png"
#define kRegPickerMarkerIconSize 80.0
#define kRegPickerRegionsFile @"regions-suewag.json"
#define kRegPickerAnnotationFont [UIFont fontWithName:@"RWEHeadline-MediumCondensed" size:50.0f * scale]
#define kRegPickerFont [UIFont fontWithName:@"RWEHeadline-MediumCondensed" size:18]
#define kRegPickerSearchForegroundColor [UIColor colorWithRed:66.0/255.0 green:80.0/255.0 blue:75.0/255.0 alpha:1.0]
#define kRegPickerSearchBackgroundColor [UIColor colorWithRed:44.0/255.0 green:60.0/255.0 blue:55.0/255.0 alpha:1.0]
#define kRegPickerSelectColor [UIColor colorWithRed:254.0/255.0 green:197.0/255.0 blue:3.0/255.0 alpha:1.0]
#define kRegPickerActionButtonColor [UIColor colorWithRed:136.0/255.0 green:186.0/255.0 blue:20.0/255.0 alpha:1.0]
#define kRegPickerTextColor [UIColor whiteColor]
//
#define kRegPickerSearchClearButtonImage @"icon_content_clear_text.png"
//
#define kRegPickerBorderColor [UIColor whiteColor].CGColor
#define kRegPickerBorderWidth 1.0f
#define kRegPickerCornerRadius 3.0f
#define kRegPickerDefaultZoomLevel 0.5f

@interface STRegionPickerViewController ()

@property (nonatomic,retain) CLLocationManager *locationManager;
@property BOOL haveLocation;
@property (nonatomic, retain) UIImage *mapImage;
@property (nonatomic, retain) UIImageView *mapImageView;
@property (nonatomic, retain) NSArray *allRegions;
//@property (nonatomic, retain) NSMutableArray *allButtons;
@property (nonatomic, retain) UIButton *navBarButton;
@property (nonatomic, retain) CustomBadge *badge;
@property (nonatomic, strong) NSDictionary* regionsDict;
@property BOOL returnedFromSearch;
@property int badgeCounter;

@end

@implementation STRegionPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.badgeCounter = 0;
    
    if (self.currentState == PickerStateStart) {
        
        self.title = @"REGIONEN FESTLEGEN";

    }
    else{
        self.title = @"REGIONENFILTER";

    }
    
    self.haveLocation = NO;
    self.returnedFromSearch = NO;
    self.allRegions = [self loadRegions];
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:kRegPickerNavBarIconLeft] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemTapped:)];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
 }

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    if (!self.returnedFromSearch) {
        [self adjustInterface];
        [self initializeScrollView];
           }
    self.backgroundImageView.needsBlur = YES;
    
}

-(void)adjustRegion{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"regionAdjusted" object:nil];
    
    NSString *region = [[STRegionManager sharedInstance] currentRegion];
    
    NSDictionary*curRegion = nil;
    
    for (NSDictionary*dict in self.allRegions) {
        if ([[dict valueForKey:@"name"] isEqualToString:region]) {
            curRegion = dict;
        }
    }
    
    if (curRegion) {
        NSInteger index = [self.allRegions indexOfObject:curRegion];
        UIButton*button = [self.selectionScrollView viewWithTag:index];
        [self regionButtonTapped:button];
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.returnedFromSearch) {
        self.returnedFromSearch = NO;
        [self addRegionButtonsToMap];
      
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - regions

- (NSArray*)loadRegions {

    NSString *fileName = [[kRegPickerRegionsFile lastPathComponent] stringByDeletingPathExtension];
    NSString *fileExt = [kRegPickerRegionsFile pathExtension];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExt];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    self.regionsDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    self.regionsDict = [self.regionsDict objectForKey:kRegPickerJSONIdentifierRegions];
    NSArray *jsonArray = [self.regionsDict allValues];
    if (jsonArray) {
        NSMutableArray *newArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in jsonArray) {
            NSMutableDictionary *nextDict = [NSMutableDictionary dictionaryWithDictionary:dict];
            [newArray addObject:nextDict];
        }
        return [NSArray arrayWithArray:newArray];
    }
    return nil;
}

- (void)addRegionButtonsToMap {
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSArray *regions = [defaults objectForKey:@"filter_regionen"];

    NSArray *regions = [[Filters sharedInstance] filtersForType:FilterTypeRegionen];
    
    CGFloat scale = self.selectionScrollView.zoomScale;
    for (NSMutableDictionary *regDict in self.allRegions) {
        
        CGSize size = [[regDict objectForKey:kRegPickerJSONIdentifierShortcut] sizeWithAttributes:@{NSFontAttributeName:kRegPickerAnnotationFont}];
        
        CGRect buttonRect = CGRectMake(([[regDict objectForKey:kRegPickerJSONIdentifierXPos] floatValue] * scale) - ((size.width/1.5)*scale),
                                       ([[regDict objectForKey:kRegPickerJSONIdentifierYPos] floatValue] * scale) - ((size.height/2)*scale) + ((kRegPickerMarkerIconSize/2)*scale),
                                       size.width,
                                       size.height);
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.frame = buttonRect;
        [aButton addTarget:self action:@selector(regionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [aButton setTitle:[regDict objectForKey:kRegPickerJSONIdentifierShortcut] forState:UIControlStateNormal];
        [aButton setTitleColor:kRegPickerTextColor forState:UIControlStateNormal];
        [aButton setTitleColor:kRegPickerSelectColor forState:UIControlStateSelected];
        aButton.titleLabel.font = kRegPickerAnnotationFont;
        aButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        aButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        aButton.contentMode = UIViewContentModeCenter;
        aButton.tag = [self.allRegions indexOfObject:regDict];
        [self.selectionScrollView addSubview:aButton];
        
        CGRect buttonRect2 = CGRectMake(aButton.frame.origin.x+(aButton.frame.size.width/2)-((kRegPickerMarkerIconSize/2)*scale),
                                        aButton.frame.origin.y-(kRegPickerMarkerIconSize*scale),
                                        (kRegPickerMarkerIconSize*scale),
                                        (kRegPickerMarkerIconSize*scale));
        UIButton *aButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton2.frame = buttonRect2;
        [aButton2 addTarget:self action:@selector(regionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [aButton2 setImage:[UIImage imageNamed:kRegPickerMarkerIconUnselected] forState:UIControlStateNormal];
        [aButton2 setImage:[UIImage imageNamed:kRegPickerMarkerIconSelected] forState:UIControlStateSelected];
        aButton2.contentMode = UIViewContentModeScaleAspectFill;
        aButton2.tag = [self.allRegions indexOfObject:regDict];
        [self.selectionScrollView addSubview:aButton2];
        
        [regDict setObject:aButton forKey:kRegPickerJSONIdentifierButton];
        [regDict setObject:aButton2 forKey:kRegPickerJSONIdentifierIconButton];
        
        if (regions) {
            if ([regions indexOfObject:[regDict objectForKey:kRegPickerJSONIdentifierID]] != NSNotFound) {
                aButton.selected = YES;
                aButton2.selected = YES;
                self.badgeCounter++;
                self.navBarButton.selected = YES;
            }
            [self updateBadge];
        }
    }
}

- (void)adjustRegionButtonsToMap {
    CGFloat scale = self.selectionScrollView.zoomScale;
    for (NSDictionary *thisDict in self.allRegions) {
        CGSize size = [[thisDict objectForKey:kRegPickerJSONIdentifierShortcut] sizeWithAttributes:@{NSFontAttributeName:kRegPickerAnnotationFont}];
        UIButton *thisButton = [thisDict objectForKey:kRegPickerJSONIdentifierButton];
        CGRect buttonRect = thisButton.frame;
        buttonRect.origin.x = ([[thisDict objectForKey:kRegPickerJSONIdentifierXPos] floatValue] * scale) - (size.width/1.5);
        buttonRect.origin.y = ([[thisDict objectForKey:kRegPickerJSONIdentifierYPos] floatValue] * scale) - (size.height/2);
        buttonRect.size.width = size.width;
        buttonRect.size.height = size.height;
        thisButton.frame = buttonRect;
        thisButton.titleLabel.font = kRegPickerAnnotationFont;
        
        UIButton *thisButton2 = [thisDict objectForKey:kRegPickerJSONIdentifierIconButton];
        CGRect buttonRect2 = thisButton2.frame;
        buttonRect2.origin.x = thisButton.frame.origin.x + (thisButton.frame.size.width/2) - ((kRegPickerMarkerIconSize/2)*scale);
        buttonRect2.origin.y = thisButton.frame.origin.y - (80*scale);
        buttonRect2.size.width = kRegPickerMarkerIconSize*scale;
        buttonRect2.size.height = kRegPickerMarkerIconSize*scale;
        thisButton2.frame = buttonRect2;

    }
}

- (void)adjustRegionForZipCode:(NSString*)zipCode {
    for (NSDictionary *regDict in self.allRegions) {
        NSArray *zipArray = [regDict objectForKey:kRegPickerJSONIdentifierZipCodes];
        if ([zipArray indexOfObject:[NSNumber numberWithInt:[zipCode intValue]]] != NSNotFound) {
            UIButton *thisButton = (UIButton*)[regDict objectForKey:kRegPickerJSONIdentifierButton];
            thisButton.selected = YES;
            self.badgeCounter++;
            self.navBarButton.selected = YES;
            [self refreshMessageLabelForRegion:regDict added:YES];
            CGRect posRect = CGRectMake(thisButton.frame.origin.x - (self.selectionScrollView.frame.size.width/2) + (thisButton.frame.size.width/2),
                                        thisButton.frame.origin.y - (self.selectionScrollView.frame.size.height/2) + (thisButton.frame.size.height/2),
                                        self.selectionScrollView.frame.size.width,
                                        self.selectionScrollView.frame.size.height);
            [self.selectionScrollView scrollRectToVisible:posRect animated:YES];
            [self updateBadge];
            break;
        }
    }
}

- (void)selectRegionsDone {
    NSMutableArray *selectedRegions = [[NSMutableArray alloc] init];
    for (NSDictionary *buttonDict in self.allRegions) {
        UIButton *thisButton = (UIButton*)[buttonDict objectForKey:kRegPickerJSONIdentifierButton];
        if (thisButton.selected) {
            [selectedRegions addObject:[buttonDict objectForKey:kRegPickerJSONIdentifierID]];
            NSLog(@"Region %@, ID %i", [buttonDict objectForKey:kRegPickerJSONIdentifierName], [[buttonDict objectForKey:kRegPickerJSONIdentifierID] intValue]);
        }
    }

    if (selectedRegions.count>0) {
        self.view.userInteractionEnabled = NO;

        [[Filters sharedInstance] saveRegionFilterWithFilterIds:selectedRegions forEnumFilterType:FilterTypeRegionen notification:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//         [defaults setObject:[NSArray arrayWithArray:selectedRegions] forKey:@"filter_regionen"];
        [defaults setBool:YES forKey:@"regionPickerShowed"];
        
        //set also the array of background images
        NSMutableArray *selectedRegionsBackgrounds = [[NSMutableArray alloc] init];
        for (int i=0; i<selectedRegions.count; i++) {
            NSString* jsonKey = [NSString stringWithFormat:@"%@",selectedRegions[i]];
            [selectedRegionsBackgrounds addObject:[[self.regionsDict objectForKey:jsonKey] objectForKey:@"image"]];
        }
        
        [defaults setObject:[NSArray arrayWithArray:selectedRegionsBackgrounds] forKey:kSessionImagesArray];
        [defaults removeObjectForKey:kSessionImage];
        [defaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRegionChagedNotification object:nil];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            //NOTE: I'm forced to make a request, because I don't know which filters I have to delete/add for the new regions

            [[Filters sharedInstance] resetFilterTypesLoadedFromServer];
        [[Filters sharedInstance] loadDefaultFilters];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRegionChagedNotification object:nil];
            [[[UIAlertView alloc] initWithTitle:nil message:@"Ihre Regionen wurden gespeichert." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }];

    }
    else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"Bitte wählen Sie mind. eine Region aus." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
   }

- (void)regionButtonTapped:(id)sender {

    UIButton *theButton = (UIButton*)sender;
    theButton.selected = !theButton.selected;
    
    if (theButton.currentImage) {
        for (NSDictionary *regDict in self.allRegions) {
            UIButton *testBtn = (UIButton*)[regDict objectForKey:kRegPickerJSONIdentifierIconButton];
            if ([testBtn isEqual:theButton]) {
                UIButton *iconBtn = [regDict objectForKey:kRegPickerJSONIdentifierButton];
                iconBtn.selected = theButton.selected;
            }
        }
    } else {
        for (NSDictionary *regDict in self.allRegions) {
            UIButton *testBtn = (UIButton*)[regDict objectForKey:kRegPickerJSONIdentifierButton];
            if ([testBtn isEqual:theButton]) {
                UIButton *iconBtn = [regDict objectForKey:kRegPickerJSONIdentifierIconButton];
                iconBtn.selected = theButton.selected;
            }
        }
    }
    if (theButton.selected) {
        [self refreshMessageLabelForRegion:[self.allRegions objectAtIndex:theButton.tag] added:YES];
        CGRect posRect = CGRectMake(theButton.frame.origin.x - (self.selectionScrollView.frame.size.width/2) + (theButton.frame.size.width/2),
                                    theButton.frame.origin.y - (self.selectionScrollView.frame.size.height/2) + (theButton.frame.size.height/2),
                                    self.selectionScrollView.frame.size.width,
                                    self.selectionScrollView.frame.size.height);
        [self.selectionScrollView scrollRectToVisible:posRect animated:YES];
        self.badgeCounter++;
        self.navBarButton.selected = YES;
    } else {
        [self refreshMessageLabelForRegion:[self.allRegions objectAtIndex:theButton.tag] added:NO];
        self.badgeCounter--;
        if (self.badgeCounter == 0) {
            self.navBarButton.selected = NO;
        }
    }
    [self updateBadge];
}

#pragma mark - search deleaget

-(void)searchFinished:(NSDictionary *)regionDict {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.returnedFromSearch = YES;
        if (regionDict) {
            UIButton *thisButton = (UIButton*)[regionDict objectForKey:kRegPickerJSONIdentifierButton];
            thisButton.selected = YES;
            self.badgeCounter++;
            self.navBarButton.selected = YES;
            [self refreshMessageLabelForRegion:regionDict added:YES];
            CGRect posRect = CGRectMake(thisButton.frame.origin.x - (self.selectionScrollView.frame.size.width/2) + (thisButton.frame.size.width/2),
                                        thisButton.frame.origin.y - (self.selectionScrollView.frame.size.height/2) + (thisButton.frame.size.height/2),
                                        self.selectionScrollView.frame.size.width,
                                        self.selectionScrollView.frame.size.height);
            [self.selectionScrollView scrollRectToVisible:posRect animated:YES];
            [self updateBadge];
        }
    });
}

#pragma mark - scroll view related

- (void)initializeScrollView {
    
    self.selectionScrollView.delegate = self;
    
    self.selectionScrollView.userInteractionEnabled = YES;
    self.selectionScrollView.exclusiveTouch = NO;
    self.selectionScrollView.canCancelContentTouches = NO;
    self.selectionScrollView.delaysContentTouches = NO;
    
    self.mapImage = [UIImage imageNamed:kRegPickerMapImage];
    self.mapImageView = [[UIImageView alloc] initWithImage:self.mapImage];

    self.mapImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.mapImage.size};
    [self.selectionScrollView addSubview:self.mapImageView];
    
    self.selectionScrollView.contentSize = self.mapImage.size;
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.selectionScrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.selectionScrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    CGRect scrollViewFrame = self.selectionScrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.selectionScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.selectionScrollView.contentSize.height;
    CGFloat minScale = MAX(scaleWidth, scaleHeight);
    self.selectionScrollView.minimumZoomScale = minScale;
    
    self.selectionScrollView.maximumZoomScale = 1.0f;
    self.selectionScrollView.zoomScale = kRegPickerDefaultZoomLevel;
    
    NSString* defaultRegion = [STRegionManager sharedInstance].currentRegion;
    NSDictionary* positionRegion = [[STRegionManager sharedInstance] positionForRegion:defaultRegion];
    
    
    CGRect posRect = CGRectMake(([[positionRegion valueForKey:@"xPos"] floatValue] * kRegPickerDefaultZoomLevel) - self.selectionScrollView.frame.size.width /3 ,
                                ([[positionRegion valueForKey:@"yPos"] floatValue] * kRegPickerDefaultZoomLevel) - self.selectionScrollView.frame.size.height /2,
                                self.selectionScrollView.frame.size.width,
                                self.selectionScrollView.frame.size.height);
    
//    CGRect posRect = CGRectMake((self.selectionScrollView.contentSize.width/2)-(self.selectionScrollView.frame.size.width/2)+200,
//                                (self.selectionScrollView.contentSize.height/2)-(self.selectionScrollView.frame.size.height/2),
//                                self.selectionScrollView.frame.size.width,
//                                self.selectionScrollView.frame.size.height);
    [self.selectionScrollView scrollRectToVisible:posRect animated:NO];
    
}

- (void)centerScrollViewContents {
    
    CGSize boundsSize = self.selectionScrollView.bounds.size;
    CGRect contentsFrame = self.mapImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.mapImageView.frame = contentsFrame;
    
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    CGPoint pointInView = [recognizer locationInView:self.mapImageView];
    CGFloat newZoomScale = self.selectionScrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.selectionScrollView.maximumZoomScale);
    CGSize scrollViewSize = self.selectionScrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.selectionScrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    CGFloat newZoomScale = self.selectionScrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.selectionScrollView.minimumZoomScale);
    [self.selectionScrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mapImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
    [self adjustRegionButtonsToMap];
}

#pragma mark - location manager delegate

- (void)initializeLocationManager {
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    //    [self.locationManager requestLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if (!self.haveLocation) {
        self.haveLocation = YES;
        
        CLLocation *currentLocation = [locations objectAtIndex:0];
        [self.locationManager stopUpdatingLocation];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!(error)) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                if (placemark.postalCode) {
                    [self adjustRegionForZipCode:[NSString stringWithString:placemark.postalCode]];
                }
            } else {

            }
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark - button actions

- (IBAction)searchButtonTapped:(id)sender {

    self.currentState = PickerStateSelect;
    self.selectionScrollView.hidden = NO;
    self.startView.hidden = YES;
    [self.actionButton setTitle:@"Auswahl speichern" forState:UIControlStateNormal];

    STRegionPickerSearchViewController *vc = [[STRegionPickerSearchViewController alloc] initWithNibName:@"STRegionPickerSearchViewController" bundle:nil];
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    NSMutableArray *notSelectedRegions = [[NSMutableArray alloc] init];
    for (NSDictionary *regDict in self.allRegions) {
        UIButton *theButton = (UIButton*)[regDict objectForKey:kRegPickerJSONIdentifierButton];
        if (!theButton.selected) {
            [notSelectedRegions addObject:regDict];
        }
    }
    vc.allRegions = notSelectedRegions;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)actionButtonTapped:(id)sender {
    if (self.currentState == PickerStateStart) {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustRegion) name:@"regionAdjusted" object:nil];
        [[STRegionManager sharedInstance] getRegionFromCurrentUserLocation];
       

        
        self.title = @"REGIONENFILTER";

        
//        [self initializeLocationManager];
        self.currentState = PickerStateSelect;
        self.selectionScrollView.hidden = NO;
        self.startView.hidden = YES;
        self.messageView.hidden = NO;
        self.messageLabel.text = @"Fügen Sie durch das Klicken auf die Pins Regionen hinzu";
        [self.actionButton setTitle:@"Auswahl speichern" forState:UIControlStateNormal];
    } else if (self.currentState == PickerStateSelect) {
        [self selectRegionsDone];
    }
    //save in user defaults the state of all regions selected or not
    BOOL areAllRegionsSelected = NO;
    if ([self selectedRegionsCount] == self.allRegions.count) {
        areAllRegionsSelected = YES;
    }
    [[NSUserDefaults standardUserDefaults] setBool:areAllRegionsSelected forKey:@"allRegionsSelected"];
}

#pragma mark - interface

- (void)refreshMessageLabelForRegion:(NSDictionary*)regDict added:(BOOL)added {
    self.messageView.hidden = NO;
    NSMutableAttributedString *msgString = [[NSMutableAttributedString alloc] init];
    
    UIFont *labelFont = kRegPickerFont;
    
    NSDictionary *fontAttributes = @{NSFontAttributeName:labelFont,
                                     NSForegroundColorAttributeName:kRegPickerTextColor};
    
    NSDictionary *selFontAttributes = @{NSFontAttributeName:labelFont,
                                        NSForegroundColorAttributeName:kRegPickerSelectColor};
    
    [msgString appendAttributedString:[[NSAttributedString alloc]
                                       initWithString:[regDict objectForKey:kRegPickerJSONIdentifierShortcut]
                                       attributes:selFontAttributes]];
    [msgString appendAttributedString:[[NSAttributedString alloc]
                                       initWithString:@" - "
                                       attributes:fontAttributes]];
    [msgString appendAttributedString:[[NSAttributedString alloc]
                                       initWithString:[regDict objectForKey:kRegPickerJSONIdentifierName]
                                       attributes:fontAttributes]];
    if (added) {
        [msgString appendAttributedString:[[NSAttributedString alloc]
                                           initWithString:@" hinzugefügt"
                                           attributes:fontAttributes]];
        self.messageIconImageView.image = [UIImage imageNamed:kRegPickerMessageIconSelect];
    } else {
        [msgString appendAttributedString:[[NSAttributedString alloc]
                                           initWithString:@" entfernt"
                                           attributes:fontAttributes]];
        self.messageIconImageView.image = [UIImage imageNamed:kRegPickerMessageIconDeselect];
    }
    self.messageLabel.attributedText = msgString;
}

- (void)adjustInterface {
    
    self.navBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.navBarButton.frame = CGRectMake(0, 0, 35, 35);
    [self.navBarButton setImage:[UIImage imageNamed:kRegPickerNavBarIcon] forState:UIControlStateNormal];
    [self.navBarButton setImage:[UIImage imageNamed:kRegPickerNavBarIconWithBadge] forState:UIControlStateSelected];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navBarButton];
    
    self.backgroundImageView.image = [UIImage imageNamed:kRegPickerBackgroundImage];
    self.searchButtonBackgroundView.backgroundColor = kRegPickerSearchBackgroundColor;
    self.searchButton.backgroundColor = kRegPickerSearchForegroundColor;
    self.startLabel.textColor = kRegPickerTextColor;
    [self addBorderToView:self.selectionScrollView];
    [self addBorderToView:self.actionButton];
    [self adjustFont];
    self.actionButton.backgroundColor = kRegPickerActionButtonColor;
    
    if (self.currentState == PickerStateSelect) {
        self.selectionScrollView.hidden = NO;
        self.startView.hidden = YES;
        [self.actionButton setTitle:@"Auswahl speichern" forState:UIControlStateNormal];        
        self.messageView.hidden = NO;
        self.messageLabel.text = @"Fügen Sie durch das Klicken auf die Pins Regionen hinzu";
    } else {
        self.messageView.hidden = YES;
    }
}

- (void)addBorderToView:(UIView*)currentView {
    currentView.layer.borderColor = kRegPickerBorderColor;
    currentView.layer.borderWidth = kRegPickerBorderWidth;
    currentView.layer.cornerRadius = kRegPickerCornerRadius;
}

- (void)adjustFont {
    self.searchButton.titleLabel.font = kRegPickerFont;
    self.messageLabel.font = kRegPickerFont;
    self.startLabel.font = kRegPickerFont;
    self.actionButton.titleLabel.font = kRegPickerFont;
}

- (void)updateBadge {
    if (!self.badge) {
        BadgeStyle *badgeStyle = [BadgeStyle freeStyleWithTextColor:kRegPickerSelectColor
                                                     withInsetColor:[UIColor clearColor]
                                                     withFrameColor:nil
                                                          withFrame:NO
                                                         withShadow:NO
                                                        withShining:NO
                                                       withFontType:BadgeStyleFontTypeCustom];
        
        self.badge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%lu",(unsigned long)self.badgeCounter] withStyle:badgeStyle];
        CGRect badgeRect = self.badge.frame;
        badgeRect.origin.x = 0-3;
        badgeRect.origin.y = self.navBarButton.frame.size.height - (badgeRect.size.height-4);
        self.badge.frame = badgeRect;
        [self.navBarButton addSubview:self.badge];
    } else {
        if (self.badgeCounter == 0) {
            [self.badge autoBadgeSizeWithString:@""];
        } else {
            [self.badge autoBadgeSizeWithString:[NSString stringWithFormat:@"%lu",(unsigned long)self.badgeCounter]];
        }
    }
}

-(void)leftBarButtonItemTapped:(id)sender{

    if ([self selectedRegionsCount]>0) {
    [self dismissViewControllerAnimated:YES completion:nil];
          }
    else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"Bitte wählen Sie mind. eine Region aus." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

-(NSInteger)selectedRegionsCount{

    NSMutableArray *selectedRegions = [[NSMutableArray alloc] init];
    for (NSDictionary *buttonDict in self.allRegions) {
        UIButton *thisButton = (UIButton*)[buttonDict objectForKey:kRegPickerJSONIdentifierButton];
        if (thisButton.selected) {
            [selectedRegions addObject:[buttonDict objectForKey:kRegPickerJSONIdentifierID]];
            NSLog(@"Region %@, ID %i", [buttonDict objectForKey:kRegPickerJSONIdentifierName], [[buttonDict objectForKey:kRegPickerJSONIdentifierID] intValue]);
        }
    }
    
    return selectedRegions.count;

}

- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }


@end














