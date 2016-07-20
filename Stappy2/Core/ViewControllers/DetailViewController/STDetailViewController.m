//
//  STDetailViewController.m
//  Stappy2
//
//  Created by Pavel Nemecek on 21/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STDetailViewController.h"

//frameworks
#import <EventKit/EventKit.h>
#import <EventKitUI/EKEventEditViewController.h>

//models
#import "STMainModel.h"
#import "STParkHausModel.h"
#import "STTankStationModel.h"
#import "STGeneralParkhausModel.h"
#import "STEventsModel.h"
#import "STStadtinfoOverwiewImages.h"
#import "STDetailViewModel.h"

//networking
#import "STRequestsHandler.h"

//categories
#import "NSDate+DKHelper.h"
#import "NSObject+AssociatedObject.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+tintImage.h"
#import "UIColor+STColor.h"
#import "UIImage+ImageEffects.h"

//cell
#import "STDetailActionCollectionViewCell.h"
#import "STDetailImageCollectionViewCell.h"

//datasources
#import "STDetailImagesDataSource.h"
#import "STDetailActionsDataSource.h"

//controllers
#import "STWebViewDetailViewController.h"
#import "STAnnotationsMapViewController.h"
#import "STDetailImageGalleryViewController.h"
#import "STWebViewDetailViewController.h"

//others
#import "Utils.h"
#import "STAppSettingsManager.h"
#import "Stappy2-Swift.h"
#import "RandomImageView.h"
#import "StLocalDataArchiever.h"

//constants
static NSString * const STActionsCollectionViewCellIdentifier = @"actionCell";
static NSString * const STImagesCollectionViewCellIdentifier = @"imageCell";
static CGFloat const STPDFButtonHeightConstraintDefaultValue = 80.0;
static CGFloat const STImagesCollectionViewHeightConstraintDefaultValue = 66.0;
static CGFloat const STHorizontalMarginValue = 8.0;
static CGFloat const STCouponMarginValue = 32.0;

typedef NS_ENUM(NSInteger, STCollectionViewAnimationDirection) {
    STCollectionViewAnimationDirectionForward,
    STCollectionViewAnimationDirectionBackward
};

typedef NS_ENUM(NSInteger, STCouponStatus) {
    STCouponStatusNew,
    STCouponStatusViewed,
    STCouponStatusUsed
};

@interface STDetailViewController ()<UICollectionViewDelegate, UIActionSheetDelegate, EKEventEditViewDelegate, UIWebViewDelegate>

@property(nonatomic,strong) STDetailViewModel*viewModel;

@property (weak, nonatomic) IBOutlet RandomImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//cover and headline
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;

//actions - sharing etc.
@property (weak, nonatomic) IBOutlet UICollectionView *actionsCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionsCollectionViewHeightConstraint;
@property(nonatomic,strong) NSMutableArray*actionsArray;
@property(nonatomic,strong) NSDictionary*sharingOptions;
@property(nonatomic,strong) STDetailActionsDataSource*actionsDataSource;

//date and category
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

//adress and location
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;

//main content - description
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTextViewHeightConstraint;

//images
@property (weak, nonatomic) IBOutlet UIView *imagesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;
@property(nonatomic,strong) NSMutableArray*imagesArray;
@property(nonatomic,strong) STDetailImagesDataSource*imagesDataSource;

//pdf button
@property (weak, nonatomic) IBOutlet UIButton *pdfButton;
-(IBAction)pdfButtonTapped:(id)sender;
@property (strong, nonatomic) NSString*pdfUrlString;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pdfButtonHeightConstraint;

//opening hours
@property (weak, nonatomic) IBOutlet OpeningHoursMultipleViews *openingHoursView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openingHoursViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIWebView *parkingOpeningWebView;

//coupon
@property (weak, nonatomic) IBOutlet UIView *couponsView;
@property (weak, nonatomic) IBOutlet UILabel *couponDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *couponImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *couponImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *couponViewHeightConstraint;
@property(nonatomic,assign) STCouponStatus couponStatus;
@property (weak, nonatomic) IBOutlet UIButton *couponButton;
-(IBAction)couponButtonTapped:(id)sender;

@end

@implementation STDetailViewController

- (instancetype)initWithDataModel:(STMainModel *)dataModel
{ return [self initWithNibName:@"STDetailViewController" bundle:nil andDataModel:dataModel];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDataModel:(STMainModel *)dataModel {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        [self setupWithModel:dataModel];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParkHausModel:(STParkHausModel *)parkHauseModel {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        [self setupWithModel:parkHauseModel];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGeneralParkHausModel:(STGeneralParkhausModel *)parkHauseModel {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        [self setupWithModel:parkHauseModel];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTankStationModel:(STTankStationModel *)tankStationModel {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        [self setupWithModel:tankStationModel];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    self.navigationController.navigationBar.barTintColor = [UIColor transparencyColor];
    self.navigationController.navigationBar.tintColor = [UIColor transparencyColor];
    self.navigationController.navigationBar.translucent = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
}




//transforms models into viewmodel
-(void)setupWithModel:(id)model{
    self.viewModel = [[STDetailViewModel alloc] initWithModel:model];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.actionsCollectionView registerNib:[UINib nibWithNibName:@"STDetailActionCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:STActionsCollectionViewCellIdentifier];
    [self.imagesCollectionView registerNib:[UINib nibWithNibName:@"STDetailImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:STImagesCollectionViewCellIdentifier];
    [self setCoverImageAndBackground];

    [self customizeAppearance];
    [self setContent];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.backgroundImageView.image = [UIImage imageNamed:@"background_blurred"];
    [self.navigationController.navigationBar setBarTintColor:[UIColor partnerColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
}

//custom fonts and other target specific styling
-(void)customizeAppearance{

        STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
        UIFont *headlineFont = [settings customFontForKey:@"detailscreen.title.font"];
        UIFont *dateFont = [settings customFontForKey:@"detailscreen.time.font"];
        UIFont *categoryFont = [settings customFontForKey:@"detailscreen.event_type.font"];
        UIFont *addressFont = [settings customFontForKey:@"detailscreen.location.font"];
        UIFont *contentFont = [settings customFontForKey:@"detailscreen.description.font"];
        
        if (headlineFont) {
            self.headlineLabel.font = headlineFont;
        }
        if (dateFont) {
            self.dateLabel.font = dateFont;
        }
        if (categoryFont) {
        self.categoryLabel.font = categoryFont;
        }
        if (addressFont) {
            self.addressLabel.font = addressFont;
        }
        if (contentFont) {
            self.contentTextView.font = contentFont;
            self.couponDescriptionLabel.font = contentFont;
            self.couponButton.titleLabel.font = contentFont;
        }
    
    self.contentTextView.textContainerInset = UIEdgeInsetsZero;
    self.contentTextView.textContainer.lineFragmentPadding = 0;

}

#pragma mark - Content setters

-(void)setContent{

    self.imagesArray = [NSMutableArray array];
    
    //headline
    if (self.viewModel.headline.length>0) {
        self.headlineLabel.attributedText = [Utils text:self.viewModel.headline withSpacing:8];
    }
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];

    UIFont *contentFont = [settings customFontForKey:@"detailscreen.description.font"];

    if (!contentFont) {
        contentFont = [UIFont systemFontOfSize:16];
    }
    
    //description box - empty = hiden
    if (self.viewModel.content.length>1) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        self.contentTextView.font = contentFont;
        style.maximumLineHeight = 20;
        style.minimumLineHeight = 20;
        style.alignment = NSTextAlignmentLeft;
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        
        self.contentTextView.attributedText = [[NSAttributedString alloc] initWithString:self.viewModel.content attributes:@{NSFontAttributeName:contentFont, NSParagraphStyleAttributeName: style}] ;
        self.contentTextView.textColor = [UIColor whiteColor];
         self.contentTextView.userInteractionEnabled = YES;
         self.contentTextView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
         self.contentTextView.scrollEnabled = NO;
         self.contentTextView.editable = NO;
         self.contentTextView.selectable = YES;
        self.contentTextView.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor partnerColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle], NSFontAttributeName:contentFont};
        
        CGFloat width =  self.contentTextView.bounds.size.width - 2.0 *  self.contentTextView.textContainer.lineFragmentPadding;
        
        NSDictionary *options = @{ NSFontAttributeName:  self.contentTextView.font, NSParagraphStyleAttributeName:style };
        CGRect boundingRect = [ self.contentTextView.text boundingRectWithSize:CGSizeMake(width, NSIntegerMax)
                                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                       attributes:options context:nil];
        
        
        self.contentTextViewHeightConstraint.constant=  ceilf(boundingRect.size.height);
        }
    else{
        self.contentTextViewHeightConstraint.constant = 0;
        [self addZeroHeightConstraint:self.contentView];
    }
    
    //location box - empty = hiden
    if (self.viewModel.address.length>0) {
        self.addressLabel.attributedText = [Utils text:self.viewModel.address withSpacing:3];;
        [self.locationView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapButtonTapped:)]];
        self.pinImageView.image = [[UIImage imageNamed:@"pin"] imageTintedWithColor:[UIColor partnerColor]];
        
    }
    else{
        self.locationViewBottomConstraint.constant = 0;
        [self addZeroHeightConstraint:self.locationView];
    }
    
    //hide actions once there is no content
    if (self.viewModel.content.length == 0 && self.viewModel.address.length==0) {
        self.actionsCollectionViewHeightConstraint.constant = 0;
    }
    
    [self setActions];
    [self setDataModelContent];
    [self setOpeningHours];

}

-(void)setOpeningHours{
    
    //specific action for wurzburg parking - loads data into webview
    if (self.viewModel.openingTimes) {
        self.parkingOpeningWebView.hidden = NO;
        self.parkingOpeningWebView.delegate = self;
        [self.parkingOpeningWebView loadHTMLString:self.viewModel.openingTimes baseURL:nil];
    }
    
    //generic opening hours box
    if(self.viewModel.openingHours){
        if ([OpeningClosingTimesModel isEmpty:self.viewModel.openingHours]) {
            return;
        }
        self.openingHoursViewHeightConstraint.constant = [OpeningHoursMultipleViews heightForData:self.viewModel.openingHours];
        self.openingHoursView.openingHoursData = self.viewModel.openingHours;
    }
}

-(void)setDataModelContent{
    
    //date label - empty = hiden
    if ((self.viewModel.date && self.viewModel.date.length>0) || self.viewModel.category.length > 0) {
        self.dateLabel.text =self.viewModel.date;
    }
    else{
        self.locationViewTopConstraint.constant = STHorizontalMarginValue;
    }
    
    //specific for even model - type/category of the event
    if (self.viewModel.category) {
        self.categoryLabel.text = self.viewModel.category;
    }
    
    //images collection view - custom behaviour for coupons - isOffer test
    if (self.viewModel.images && self.viewModel.images.count>0) {
        if (self.viewModel.isOffer) {
            [self setCouponViewContent];
            self.imagesViewHeightConstraint.constant = 0;
            self.pdfButtonHeightConstraint.constant = 0;
        }
        else{
            [self addZeroHeightConstraint:self.couponButton];
            self.couponViewHeightConstraint.constant = 0;
            [self setImagesAndPDF];
        }
    }
    else{
        self.couponViewHeightConstraint.constant = 0;
        self.imagesViewHeightConstraint.constant = 0;
        self.pdfButtonHeightConstraint.constant = 0;
        [self addZeroHeightConstraint:self.couponButton];
    }
}

-(void)setActions{

    self.sharingOptions = [STAppSettingsManager sharedSettingsManager].detailScreenSharingOptions;
    self.actionsArray = [NSMutableArray array];
    [self.actionsArray addObject:[self.sharingOptions objectForKey:@"share"]];
    
    //add action based on model properties
    for (NSString* key in [self.sharingOptions allKeys]) {
        SEL selector = NSSelectorFromString(key);
            if ([self.viewModel respondsToSelector:selector] && [self.viewModel valueForKey:key] != nil) {
                if ([key isEqualToString:@"endDate"]) {
                    if (!self.ignoreCalenderButton) {
                        if (self.viewModel.endDate) {
                            [self.actionsArray addObject:[self.sharingOptions objectForKey:key]];
                        }
                    }
                }

                else if ([key isEqualToString:@"latitude"]) {
                    
                        if (self.viewModel.latitude>0) {
                            [self.actionsArray addObject:[self.sharingOptions objectForKey:key]];
                        }
                    
                }

                
                else{
                        
                        if ([[self.viewModel valueForKey:key] isKindOfClass:[NSString class]]) {
                            if ( [[[self.viewModel valueForKey:key] stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceCharacterSet]] length]>3) {
                                [self.actionsArray addObject:[self.sharingOptions objectForKey:key]];
 
                            }
                        }
                        else{
                            [self.actionsArray addObject:[self.sharingOptions objectForKey:key]];

                        }
                        
                    }
            }
        
        if ([key isEqualToString:@"favorite"]) {
            if (!self.ignoreFavoritesButton) {
                if (self.viewModel.isFavoritable) {
                    [self.actionsArray addObject:[self.sharingOptions objectForKey:key]];
                }
            }
        }
    }
    
    self.actionsDataSource = [[STDetailActionsDataSource alloc] initWithItems:[self.actionsArray copy] cellIdentifier:STActionsCollectionViewCellIdentifier dataModel:self.viewModel.model];
    self.actionsCollectionView.dataSource = self.actionsDataSource;
    [self.actionsCollectionView reloadData];
}

-(void)setImagesAndPDF {

    STStadtinfoOverwiewImages*firstModel = [self.viewModel.images firstObject];
    
    NSString* imageLocation = nil;
    
    //initaly hide pdf button and images collection view
    self.pdfButtonHeightConstraint.constant = 0;
    self.imagesViewHeightConstraint.constant = 0;
    
    //only pdf = display button and hide collection view
    if ([firstModel.type isEqualToString:@"pdf"] && self.viewModel.images.count==1) {
       imageLocation = [NSString stringWithFormat:@"%@%@",[STAppSettingsManager sharedSettingsManager].baseUrl, firstModel.location];
        if ([imageLocation hasPrefix:@"http"] || [imageLocation hasPrefix:@"www"]) {
            self.pdfUrlString = imageLocation;
        }
        else {
            self.pdfUrlString = [NSString stringWithFormat:@"%@%@", [STAppSettingsManager sharedSettingsManager].baseUrl, imageLocation];
        }
        self.pdfButtonHeightConstraint.constant = STPDFButtonHeightConstraintDefaultValue;
    }
    else{
        self.imagesViewHeightConstraint.constant = STImagesCollectionViewHeightConstraintDefaultValue;
        for (STStadtinfoOverwiewImages * model in self.viewModel.images) {
            imageLocation = [NSString stringWithFormat:@"%@%@",[STAppSettingsManager sharedSettingsManager].baseUrl, model.location];
            [self.imagesArray addObject:imageLocation];
            
            if ([model.type isEqualToString:@"pdf"]) {
                if ([imageLocation hasPrefix:@"http"] || [imageLocation hasPrefix:@"www"]) {
                    self.pdfUrlString = imageLocation;
                }
                else {
                    self.pdfUrlString = [NSString stringWithFormat:@"%@%@", [STAppSettingsManager sharedSettingsManager].baseUrl, imageLocation];
                }
                self.pdfButtonHeightConstraint.constant = STPDFButtonHeightConstraintDefaultValue;
            }
        }
        self.imagesDataSource = [[STDetailImagesDataSource alloc] initWithItems:[self.imagesArray copy] cellIdentifier:STImagesCollectionViewCellIdentifier];
        self.imagesCollectionView.dataSource = self.imagesDataSource;
        [self.imagesCollectionView reloadData];
    }
}

-(void)setCouponViewContent{
    
    //set initial coupon state - has impact on coupon button behaviour
    self.couponStatus = STCouponStatusNew;
    self.couponButton.layer.cornerRadius = 3.0;
    self.couponButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.couponButton.layer.borderWidth = 1.0;
    
    STStadtinfoOverwiewImages*couponImageModel = self.viewModel.images.firstObject;
    NSString* imageLocation = [NSString stringWithFormat:@"%@%@",[STAppSettingsManager sharedSettingsManager].baseUrl, couponImageModel.location];
    [self.couponImageView sd_setImageWithURL:[NSURL URLWithString:imageLocation]];
    
    if (self.viewModel.couponDescription && self.viewModel.couponDescription.length>0) {
        self.couponDescriptionLabel.text = self.viewModel.couponDescription;
    }
    
    [self.couponButton setTitle:@"Gutschein anzeigen" forState:UIControlStateNormal];
    self.couponViewHeightConstraint.constant = 0;
}

-(void)setCoverImageAndBackground {
   
    UIImage*placeholderImage = [UIImage imageNamed:@"image_content_article_default"];
    self.coverImageView.image = placeholderImage;
    
    NSURL*coverImageURL = self.viewModel.coverImageUrl;
    
    if (coverImageURL) {
        [self.coverImageView sd_setImageWithURL:coverImageURL placeholderImage:placeholderImage];
        
    }
    
    BOOL showBlur = [STAppSettingsManager sharedSettingsManager].showDetailScreenBlur;
    if (showBlur) {
    //use model background image if provided and perform blur
    if (self.viewModel.background.length) {
        NSURL* backgroundImageUrl = [[STRequestsHandler sharedInstance] buildImageUrl:self.viewModel.background];
        [self.backgroundImageView sd_setImageWithURL:backgroundImageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) {
                self.backgroundImageView.image = placeholderImage;
            }
            else{
                UIImage*bluerdImage = [image applyBlurWithRadius:15.0 tintColor:nil saturationDeltaFactor:2 maskImage:nil];
                self.backgroundImageView.image = bluerdImage;
            }
        }];
    }
    else{
    
        if (coverImageURL) {
            
            [self.backgroundImageView sd_setImageWithURL:coverImageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!image) {
                    self.backgroundImageView.image = placeholderImage;
                }
                else{
                    UIImage*bluerdImage = [image applyBlurWithRadius:15.0 tintColor:nil saturationDeltaFactor:2 maskImage:nil];
                    self.backgroundImageView.image = bluerdImage;
                }
            }];

            
            
        }
        
    }
    }
}


#pragma mark - ActionOptionsAnimation

- (void)animateCollectionViewToDirection:(STCollectionViewAnimationDirection)direction buttonIndexPath:(NSIndexPath *)buttonIndexPath {
    if (direction == STCollectionViewAnimationDirectionForward) {
        [self.actionsCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:buttonIndexPath.row + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    } else {
        [self.actionsCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:buttonIndexPath.row - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.imagesCollectionView) {
        STDetailImageGalleryViewController *galleryViewController = [[STDetailImageGalleryViewController alloc] initWithNibName:@"STDetailImageGalleryViewController" bundle:nil andDataSource:self.imagesArray ];
        [self.navigationController pushViewController:galleryViewController animated:YES];
    } else {
        STDetailActionCollectionViewCell *cell = (STDetailActionCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        //perform action or slide
        if ([cell.associatedObject isKindOfClass:[NSNumber class]]) {
            STCollectionViewAnimationDirection direction = [cell.associatedObject integerValue];
            [self animateCollectionViewToDirection:direction buttonIndexPath:indexPath];
        } else if ([cell.associatedObject isKindOfClass:[NSString class]]) {
            SEL cellSelector = NSSelectorFromString(cell.associatedObject);
            IMP imp = [self methodForSelector:cellSelector];
            void (*func)(id, SEL, id) = (void *)imp;
            func(self, cellSelector, cell);
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.imagesCollectionView) {
        return CGSizeMake(50, 50);
    } else {
        NSInteger numberOfItemsPerPage = self.actionsArray.count >= 5 ? 5 : self.actionsArray.count;
        CGSize newSize = CGSizeMake(collectionView.frame.size.width / numberOfItemsPerPage, collectionView.frame.size.height);
        return newSize;
    }
}

#pragma mark - collection sharing actions

-(void)favoriteButtonTapped:(id)sender {
    
    if ([sender isKindOfClass:[STDetailActionCollectionViewCell class]]) {
        STDetailActionCollectionViewCell*cell = (STDetailActionCollectionViewCell*)sender;
        if (self.viewModel.isFavoritable) {
            
            UIImage*favImage;
            
            if (self.viewModel.isFavorite) {
                self.viewModel.favorite = NO;
                favImage = [UIImage imageNamed:[self.sharingOptions valueForKeyPath:@"favorite.icon.off"]];
            } else {
                self.viewModel.favorite = YES;

                favImage= [[UIImage imageNamed:[self.sharingOptions valueForKeyPath:@"favorite.icon.on"]] imageTintedWithColor:[UIColor partnerColor]];
            }
            
            cell.imageView.image=favImage;
            [[StLocalDataArchiever sharedArchieverManager] saveFavoriteStatusForModel:self.viewModel.model];
        }
    }
}

-(void)phoneButtonTapped:(id)sender {
    NSString* phoneNumber = @"";
    if (self.viewModel.phone) {
        phoneNumber =self.viewModel.phone;
    }
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    if (cleanedString.length > 0) {
        NSString *url = [@"telprompt://" stringByAppendingString:cleanedString];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

-(void)websiteButtonTapped:(id)sender {
    NSString* url = @"";
    if (self.viewModel.contactUrl) {
        url = self.viewModel.contactUrl;
    }
    if (url.length>0) {
        STWebViewDetailViewController *webViewController = [[STWebViewDetailViewController alloc] initWithURL:url];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

-(void)emailButtonTapped:(id)sender {
    NSString* email = @"";
    if (self.viewModel.email) {
        email = self.viewModel.email;
    }
    if (email.length>0) {
        NSString *url = [NSString stringWithFormat:@"mailto:%@",email];
        url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

- (void)shareButtonTapped:(id)sender
{
    BOOL hasCupons = NO;
    
    if ((self.couponDescriptionLabel.text.length > 0) && [[STAppSettingsManager sharedSettingsManager] showCoupons]){
        
        hasCupons = YES;
    }
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (hasCupons) {
        NSString *text = [NSString stringWithFormat:@"%@ %@",self.contentTextView.text,self.couponDescriptionLabel.text];
        [sharingItems addObject:text];
        [sharingItems addObject:self.couponImageView.image];
    }
    else {
        NSString *text = @"";
        NSString *title = self.viewModel.headline;
        NSString *body  = self.viewModel.content;
        
        if (title) text = title;
        if (body)
        {
            if (title) text = [NSString stringWithFormat:@"%@\n\n%@", title, body];
            else       text = body;
        }
        
        [sharingItems addObject:text];
        
        UIImage *imageToSend = self.coverImageView.image;
        if (imageToSend) { // Sometimes I don't get the image (default image to send). Check if it is nil or not
            [sharingItems addObject:imageToSend];
        }
        
        if (self.viewModel.contactUrl && self.viewModel.contactUrl.length>0) {
            [sharingItems addObject:[NSURL URLWithString:self.viewModel.contactUrl]];
        }
    }

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    NSString* cityName = [[STAppSettingsManager sharedSettingsManager] homeScreenTitle];
    if (cityName.length == 0) {
        cityName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    NSString *appName = cityName;
    
    NSString *subject;
    subject = @"Ein Gutschein für Dich - gefunden in der Süwag-App!";
    
    [activityController setValue:subject forKey:@"subject"];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)mapButtonTapped:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Bitte wählen" delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:nil otherButtonTitles:
                            @"Auf Karte anzeigen",
                            @"Route zur Adresse", nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    popup.delegate = self;
}

- (void)calendarButtonTapped:(id)sender {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView;
                
                // check if the iOS version is 8.0 or bigger, since UIApplicationOpenSettingsURLString is only available in iOS 8
                if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending)
                {
                    alertView = [[UIAlertView alloc] initWithTitle:@"Kalenderfunktion deaktiviert"
                                                           message:@"Bitte Zugriff auf Kalender akzeptieren."
                                                          delegate:self
                                                 cancelButtonTitle:@"Abbruch"
                                                 otherButtonTitles:@"Freischalten", nil];
                }
                else // the iOS version is less than 8.0
                {
                    alertView = [[UIAlertView alloc] initWithTitle:@"Achtung"
                                                           message:@"Der Zugriff auf Ihren Kalender ist blockiert. Um den Zugriff zu erlauben gehen Sie zu: Einstellungen -> Datenschutz -> Kalender"
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }
                [alertView show];
            });
            
            return;
        }
        
        [self addEventToEventStore:eventStore];
    }];
}

- (void)addEventToEventStore:(EKEventStore *)eventStore {
    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    NSString* endDateString = [NSString stringWithFormat:@"%@ %@", self.viewModel.endDateString, self.viewModel.endDateHourString];
    NSDate* endDate = [dateFormatter dateFromString:endDateString];
    NSString* startDateString = self.viewModel.startDateString;
    NSDate* startDate = [dateFormatter dateFromString:startDateString];
    event.title     = self.viewModel.headline;
    event.location  = self.viewModel.address;
    event.startDate = startDate;
    event.endDate   = endDate;
    event.notes     = self.viewModel.content;
    
    // Create the edit dialog
    EKEventEditViewController *eventController = [[EKEventEditViewController alloc] init];
    [eventController setEditViewDelegate:self];
    [eventController setEventStore:eventStore];
    [eventController setEvent:event];
    
    // Display the event dialog modal
    [self.navigationController presentViewController:eventController animated:YES completion:nil];
}

//allow calendar usage
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            STAnnotationsMapViewController *mapViewController  = [[STAnnotationsMapViewController alloc] initWithData:@[self.viewModel.model]];
            [self.navigationController pushViewController:mapViewController animated:YES];
        } else if (buttonIndex == 1) {
            MKPlacemark *placemark =[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.viewModel.latitude, self.viewModel.longitude) addressDictionary:nil];
            NSArray* arrMkItems = [NSArray arrayWithObjects: [MKMapItem mapItemForCurrentLocation], [[MKMapItem alloc] initWithPlacemark:placemark],nil];
            [MKMapItem openMapsWithItems:arrMkItems launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey,nil]];
        }
    }
}

#pragma mark - button actions

-(IBAction)couponButtonTapped:(id)sender{
  
    //check coupon status and perform action
    switch (self.couponStatus) {
        case STCouponStatusNew:
            [self viewCoupon];
            break;
        case STCouponStatusViewed:
            [self useCoupon];
            break;
        default:
            break;
    }
}

-(void)viewCoupon{
    
    [[STRequestsHandler sharedInstance] postViewCouponWithOfferId:[[self.viewModel.model valueForKey:@"angebotItemID"]integerValue]];
    CGFloat imageHeight = 0.0;
    UIImage*couponImage = self.couponImageView.image;
    float width = couponImage.size.width;
    float height = couponImage.size.height;
    float scaleFactor = (width > height) ? width / height : height/width;
    imageHeight = CGRectGetWidth(self.couponImageView.frame)*scaleFactor;
    self.couponImageViewHeightConstraint.constant = imageHeight;
    
    CGSize textSize = [self.couponDescriptionLabel intrinsicContentSize];

    //adjust coupon view size based on image and text
    self.couponViewHeightConstraint.constant = imageHeight+ CGRectGetHeight(self.couponDescriptionLabel.frame)+STCouponMarginValue+textSize.height;

    self.couponStatus = STCouponStatusViewed;
    
    if (![self offerUsed]) {
        [self.couponButton setTitle:@"Gutschein einlösen" forState:UIControlStateNormal];

    }
    else{
        [self.couponButton setTitle:@"Gutschein eingelöst" forState:UIControlStateNormal];
        self.couponButton.enabled = NO;
    }
    
    
}

-(BOOL)offerUsed{

    
    NSMutableArray*array = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"usedOffers"];
    
    for (id value in array) {
        if ([value integerValue]== [[self.viewModel.model valueForKey:@"angebotItemID"]integerValue]) {
            return YES;
        }
    }
    
    
    return NO;
    
}

-(void)useCoupon{

    [[STRequestsHandler sharedInstance] postUseCouponWithOfferId:[[self.viewModel.model valueForKey:@"angebotItemID"]integerValue]];
    
    [[STRequestsHandler sharedInstance] postSecondUseOfCouponWithOfferId:[[self.viewModel.model valueForKey:@"angebotItemID"]integerValue] name:self.viewModel.headline];

    NSMutableArray*array = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"usedOffers"];
    
    [array addObject:[self.viewModel.model valueForKey:@"angebotItemID"]];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"usedOffers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    

    self.couponStatus = STCouponStatusUsed;
    [self.couponButton setTitle:@"Gutschein eingelöst" forState:UIControlStateNormal];
    self.couponButton.enabled = NO;
}

-(IBAction)pdfButtonTapped:(id)sender{
    STWebViewDetailViewController *webViewViewController = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:self.pdfUrlString];
    [self.navigationController pushViewController:webViewViewController animated:YES];
}

#pragma mark - Helpers

-(void)addZeroHeightConstraint:(UIView*)view{
    NSLayoutConstraint *zeroheightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:0];
    [view addConstraint:zeroheightConstraint];
}

#pragma mark - WebViewDelegate methods
//used only for Wurzburg parking
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    self.openingHoursViewHeightConstraint.constant = fittingSize.height;
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
