//
//  STNewsAndEventsDetailViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 12/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EKEventEditViewController.h>
#import "Stappy2-Swift.h"
#import "STTankStationModel.h"
#import "STGeneralParkhausModel.h"
@class STMainModel;
@class STParkHausModel;
@class STDetailGenericModel;
@class RandomImageView;

@interface STNewsAndEventsDetailViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, EKEventEditViewDelegate, UIWebViewDelegate>

@property(nonatomic,weak)IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet RandomImageView *detailBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *detailRightBgImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *detailsScrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
-(IBAction)dismissView:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet UILabel *eventTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIWebView *parkingOpeningWebView;
@property (weak, nonatomic) IBOutlet UICollectionView *actionsOptions;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UIView *detailInfoView;
@property (weak, nonatomic) IBOutlet OpeningHoursMultipleViews *openingHoursMultipleViews;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openingHoursMultipleViewsHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *pdfButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pdfButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoViewHeightConstraint;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *noInfoViewConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *activeInfoViewConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionsCollectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesCollectionViewHeightConstraint;
@property(nonatomic, assign)BOOL ignoreFavoritesButton;
@property(nonatomic, assign)BOOL ignoreCalenderButton;
// Customer Number
@property (weak, nonatomic) IBOutlet UIView *customerNumberView;
@property (weak, nonatomic) IBOutlet UILabel *QRTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *customerNumberButton;
- (IBAction)customerButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrTitleLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customerNumberButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customerNumberButtonHeightConstraint;
//========

-(instancetype)initWithDataModel:(STMainModel *)dataModel;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDataModel:(STMainModel *)dataModel;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParkHausModel:(STParkHausModel *)parkHauseModel;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTankStationModel:(STTankStationModel *)tankStationModel;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGeneralParkHausModel:(STGeneralParkhausModel *)parkHauseModel;

@end
