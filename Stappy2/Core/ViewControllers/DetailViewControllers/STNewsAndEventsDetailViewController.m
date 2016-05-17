//
//  STNewsAndEventsDetailViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 12/11/2015.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STNewsAndEventsDetailViewController.h"
#import "STNewsModel.h"
#import "STAppSettingsManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DKHelper/UIView+DKHelper.h>
#import "NSObject+AssociatedObject.h"
#import "ActionOptionsCollectionViewCell.h"
#import "STWebViewDetailViewController.h"
#import "STDetailGenericModel.h"
#import "STRequestsHandler.h"
#import "Defines.h"
#import "STAnnotationsMapViewController.h"
#import "StLocalDataArchiever.h"
#import "Utils.h"
#import "UIImage+tintImage.h"
#import "UIColor+STColor.h"
#import "PDFPreviewCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "STDetailImageGalleryViewController.h"
#import "RandomImageView.h"

//models
#import "STAngeboteModel.h"
#import "STEventsModel.h"
#import "STStadtinfoOverviewModel.h"
#import "STStadtinfoOverwiewImages.h"
#import "STParkHausModel.h"

//helpers
#import "NSDate+DKHelper.h"

NSString *const kImagesCollectionViewIdentifier = @"PDFPreviewCollectionViewCell";

typedef NS_ENUM(NSInteger, CollectionViewAnimationDirection) {
    kCollectionViewAnimationDirectionForward,
    kCollectionViewAnimationDirectionBackward
};

@interface STNewsAndEventsDetailViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailRightBgImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailRightBgImageViewTopConstraint;
@property (assign,nonatomic) CGRect originalImageFrame;
@property(nonatomic, strong)STMainModel *dataModel;
@property(nonatomic, strong)STParkHausModel *parkHausModel;
@property(nonatomic, strong)STTankStationModel *tankStationModel;
@property(nonatomic, strong)STGeneralParkhausModel *generalParkHausModel;

@property(nonatomic, strong)NSDictionary *sharingOptions;
@property(nonatomic, strong)NSMutableArray *sharingCollectionDataSource;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailImageViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *timeLabelDistanceToAddressViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *timeLabelDistanceToActionOptions;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *locationViewDistanceToBodyViewConstraint;
@property (nonatomic, strong) NSString* detailUrl;
@property (nonatomic, strong) NSMutableArray* imagesDataSource;
@end

@implementation STNewsAndEventsDetailViewController

- (instancetype)initWithDataModel:(STMainModel *)dataModel
{ return [self initWithNibName:@"STNewsAndEventsDetailViewController" bundle:nil andDataModel:dataModel]; }

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDataModel:(STMainModel *)dataModel {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        self.dataModel = dataModel;
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andParkHausModel:(STParkHausModel *)parkHauseModel {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        self.parkHausModel = parkHauseModel;
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andGeneralParkHausModel:(STGeneralParkhausModel *)parkHauseModel {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        self.generalParkHausModel = parkHauseModel;
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTankStationModel:(STTankStationModel *)tankStationModel {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        self.tankStationModel = tankStationModel;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.associatedObject = @(self.navigationController.navigationBar.translucent);
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = [self.associatedObject boolValue];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // See if we need to show coupons or not
    if (![self.dataModel isKindOfClass:[STAngeboteModel class]] || ![[STAppSettingsManager sharedSettingsManager] showCoupons]) {
        self.customerViewHeightConstraint.constant = 0;
        self.qrTitleLabelHeightConstraint.constant = 0;
        self.customerNumberButtonTopConstraint.constant = 0;
        self.customerNumberButtonHeightConstraint.constant = 0;
    }
    self.qrImageViewHeightConstraint.constant = 0;

    self.customerNumberButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.actionsOptions registerNib:[UINib nibWithNibName:@"ActionOptionsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kActionOptionsCellIdentifier];
    UINib * nib = [UINib nibWithNibName:@"PDFPreviewCollectionViewCell" bundle:nil];
    [self.imagesCollectionView registerNib:nib forCellWithReuseIdentifier:kImagesCollectionViewIdentifier];
    
    if ([self.dataModel conformsToProtocol:@protocol(Favoritable)]) {
        ((STMainModel<Favoritable> *)self.dataModel).favorite = [[StLocalDataArchiever sharedArchieverManager] isFavorite:((STMainModel<Favoritable> *)self.dataModel)];
    }
    
    self.imagesCollectionViewHeightConstraint.constant = 0;
    self.pdfButtonHeightConstraint.constant = 0;

    self.imagesDataSource = [NSMutableArray array];
    self.sharingOptions = [STAppSettingsManager sharedSettingsManager].detailScreenSharingOptions;
    
    self.sharingCollectionDataSource = [NSMutableArray array];
    [self.sharingCollectionDataSource addObject:[self.sharingOptions objectForKey:@"share"]];
    for (NSString* key in [self.sharingOptions allKeys]) {
        SEL selector = NSSelectorFromString(key);
        if ([key isEqualToString:@"endDate"]) {
            if (!self.ignoreCalenderButton) {
                if ([self.dataModel respondsToSelector:selector]) {
                    [self.sharingCollectionDataSource addObject:[self.sharingOptions objectForKey:key]];
                } else if ([self.parkHausModel respondsToSelector:selector]) {
                    [self.sharingCollectionDataSource addObject:[self.sharingOptions objectForKey:key]];
                }
            }
            continue;
        }
        if (self.dataModel) {
            if ([self.dataModel respondsToSelector:selector]) {
                [self.sharingCollectionDataSource addObject:[self.sharingOptions objectForKey:key]];
            }
        } else if (self.parkHausModel) {
            if ([self.parkHausModel respondsToSelector:selector]) {
                [self.sharingCollectionDataSource addObject:[self.sharingOptions objectForKey:key]];
            }
        }
        else if (self.tankStationModel) {
            if ([self.tankStationModel respondsToSelector:selector]) {
                [self.sharingCollectionDataSource addObject:[self.sharingOptions objectForKey:key]];
            }
        }
        else if (self.generalParkHausModel) {
            if ([self.generalParkHausModel respondsToSelector:selector]) {
                [self.sharingCollectionDataSource addObject:[self.sharingOptions objectForKey:key]];
            }
        }

        if ([key isEqualToString:@"favorite"]) {
            if (!self.ignoreFavoritesButton) {
                if ([self.dataModel conformsToProtocol:@protocol(Favoritable)]) {
                    [self.sharingCollectionDataSource addObject:[self.sharingOptions objectForKey:key]];
                } else if ([self.parkHausModel conformsToProtocol:@protocol(Favoritable)]) {
                    [self.sharingCollectionDataSource addObject:[self.sharingOptions objectForKey:key]];
                }
            }
        }
    }
    
    self.actionsOptions.delegate = self;
    self.actionsOptions.dataSource = self;
    

    
    [self.descriptionLabel setTextContainerInset:UIEdgeInsetsMake(8.0, 6.0, 8.0, 6.0)];
    
    [self.locationView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickShowOnMap)]];
    
    //check if parking model
    //TODO : refactor to remove all the checks
    if (self.parkHausModel) {
        if ([self.parkHausModel respondsToSelector:@selector(openingTimes)] &&
            [self.parkHausModel valueForKey:@"openingTimes"] != nil) {
            
            NSString *data = [self.parkHausModel valueForKey:@"openingTimes"];
            if ([self.parkHausModel respondsToSelector:@selector(rates)] &&
                [self.parkHausModel valueForKey:@"rates"] != nil) {
                data = [data stringByAppendingString:[self.parkHausModel valueForKey:@"rates"]];
            }
            
            if (data == nil) {
                self.openingHoursMultipleViewsHeightConstraint.constant = 0;
            }
            //show in a web view the table with opening hours
            self.parkingOpeningWebView.hidden = NO;
            self.parkingOpeningWebView.delegate = self;

            NSString* css  = @"<style media=\"screen\" type=\"text/css\">\n"
            "body {\n"
            " \tmargin:0px;padding:8px;\n"
            "}\n"
            "td {\n"
            "\tfont-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;\n"
            "\tfont-size:8pt;\t\n"
            "\tborder:1px solid white;\t\n"
            "\tpadding:8px;\n"
            "\tcolor:white;\n"
            "}\n"
            "table {\n"
            "\twidth:100%;\n"
            "    border-spacing: 0px;\n"
            "    border-collapse: collapse;\t\n"
            "}\n"
            "\n"
            "</style>";
            NSString* strHTML = [NSString stringWithFormat:@"<html><head>%@</head><body>%@%@</html></body>",css, [self.parkHausModel valueForKey:@"openingTimes"],[self.parkHausModel valueForKey:@"rates"]];
            //NSLog(strHTML);
            [self.parkingOpeningWebView loadHTMLString:strHTML baseURL:nil];
        }
    }
    else if (self.tankStationModel) {
        if ([self.tankStationModel respondsToSelector:@selector(openinghours2)] &&
            [self.tankStationModel valueForKey:@"openinghours2"] != nil) {
            
            NSArray *data = [self.tankStationModel valueForKey:@"openinghours2"];
            
            if ([OpeningClosingTimesModel isEmpty:data]) {
                self.openingHoursMultipleViewsHeightConstraint.constant = 0;
            }
            
            self.openingHoursMultipleViewsHeightConstraint.constant = [OpeningHoursMultipleViews heightForData:data];
            self.openingHoursMultipleViews.openingHoursData = data;
        }    }
    else if (self.generalParkHausModel) {
        if ([self.generalParkHausModel respondsToSelector:@selector(openinghours2)] &&
            [self.generalParkHausModel valueForKey:@"openinghours2"] != nil) {
            
            NSArray *data = [self.generalParkHausModel valueForKey:@"openinghours2"];
            
            if ([OpeningClosingTimesModel isEmpty:data]) {
                self.openingHoursMultipleViewsHeightConstraint.constant = 0;
            }
            
            self.openingHoursMultipleViewsHeightConstraint.constant = [OpeningHoursMultipleViews heightForData:data];
            self.openingHoursMultipleViews.openingHoursData = data;
        }    }
    else {
    if ([self.dataModel respondsToSelector:@selector(openinghours2)] &&
        [self.dataModel valueForKey:@"openinghours2"] != nil) {
    
        NSArray *data = [self.dataModel valueForKey:@"openinghours2"];
        
        if ([OpeningClosingTimesModel isEmpty:data]) {
            self.openingHoursMultipleViewsHeightConstraint.constant = 0;
        }
        
        self.openingHoursMultipleViewsHeightConstraint.constant = [OpeningHoursMultipleViews heightForData:data];
        self.openingHoursMultipleViews.openingHoursData = data;
    } else {
        //TODO: remove the constraints of the openingHoursMultipleView
    }
}
    
    [self updateUI];
    
    self.actionsCollectionViewWidthConstraint.constant = [UIScreen mainScreen].bounds.size.width;
    [self.view setNeedsLayout];
    [self.actionsOptions reloadData];
}

- (void)updateUI {
    
    _pinImageView.image = [[UIImage imageNamed:@"pin"] imageTintedWithColor:[UIColor partnerColor]];
    
    NSString * title = [self modelTitle];
    if (title.length > 0) {
        self.titleLabel.attributedText = [Utils text:title withSpacing:8];
    }
    
    NSString * address = [self modelAddress];
    if (address.length > 0) {
        self.locationLabel.attributedText = [Utils text:address withSpacing:3];
    }
    else {
        self.locationViewDistanceToBodyViewConstraint.constant = -36;
        self.locationView.alpha = 0;
        [self.locationView setNeedsUpdateConstraints];
    }
    
    if ([self.dataModel respondsToSelector:@selector(dateToShow)] && self.dataModel.dateToShow.length > 0) {
        NSString* textDate = [[self.dataModel.dateToShow componentsSeparatedByString:@" "] componentsJoinedByString:@" | "];
        //the date comes in different formats for different components(with and without hour) for some reason
        NSDate* dateToShow;
        dateToShow = [NSDate dateFromString:self.dataModel.dateToShow format:@"dd.MM.yyyy HH:mm"];
        if (!dateToShow) {
            dateToShow = [NSDate dateFromString:self.dataModel.dateToShow format:@"dd.MM.yyyy"];
        }
                self.timeLabel.text = [NSString stringWithFormat:@"%@, den %@",[dateToShow dayName],textDate];
    } else {
        self.timeLabel.frame = CGRectMake(self.timeLabel.frame.origin.x, self.timeLabel.frame.origin.y, 0, 0);
        self.timeLabelDistanceToAddressViewConstraint.constant = 0;
        self.timeLabelDistanceToActionOptions.constant = 0;
        self.timeLabel.alpha = 0;
        [self.timeLabel setNeedsUpdateConstraints];
    }
    
    self.infoLabel.text = @"Info";
    
    NSString * bodyString = [self modelBodyString];
    if (bodyString.length > 0) {
    self.descriptionLabel.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor partnerColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        self.descriptionLabel.text = bodyString;
        self.descriptionLabel.textColor = [UIColor whiteColor];
        [NSLayoutConstraint deactivateConstraints:self.activeInfoViewConstraints];
    } else {
        self.infoViewHeightConstraint.constant = 0;
        self.infoLabel.text = nil;
    }
    
    if ([self.dataModel isKindOfClass:[STEventsModel class]]) {
        self.eventTypeLabel.text = self.dataModel.secondaryKey;
    }
    [self setImageAndBackgroundImage];
    self.pdfButton.hidden = YES;
    [self updateImagesAndPDF];
    [self setFonts];
    
    NSLog(@"CONTRSAS: %f",self.openingHoursMultipleViewsHeightConstraint.constant);
    
    float maxHeight = 0;
    for (UIView *child in self.detailsScrollView.subviews) {
        float childHeight = child.frame.origin.y + child.frame.size.height;
        //if child spans more than current maxHeight then make it a new maxHeight
        if (childHeight > maxHeight)
            maxHeight = childHeight;
    
    }
    

}

-(void)setImageAndBackgroundImage {
    NSString *type = self.dataModel.type == nil ? @"Event" : self.dataModel.type;
    NSString *placeholderImageName = [type stringByAppendingString:@"_placeholder"];
    UIImage *placeholderImage = [UIImage imageNamed:placeholderImageName];
    placeholderImage = placeholderImage != nil ? placeholderImage : [UIImage imageNamed:@"image_content_article_default"];
    self.detailRightBgImageView.image = placeholderImage;
    if (self.dataModel.background && self.dataModel.background.length > 0) {
        NSURL* imageUrl = [[STRequestsHandler sharedInstance] buildImageUrl:self.dataModel.background];
        [self.detailRightBgImageView sd_setImageWithURL:imageUrl
                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                  if (!image) {
                                                      self.detailRightBgImageView.image = placeholderImage;
                                                  }
                                              }];
        self.detailBgImageView.needsBlur = YES;
    } else if ([UIImage imageNamed:@"placeholder"]){
        self.detailRightBgImageView.image = [UIImage imageNamed:@"placeholder"];
        self.detailBgImageView.needsBlur = YES;
    } else if ([self modelImageString].length > 0) {
        [self.detailRightBgImageView sd_setImageWithURL:[self buildModelImageString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageUrl) {
            if (!image) {
                self.detailRightBgImageView.image = placeholderImage;
            }
        }];
        // show image
        [self.detailBgImageView sd_setImageWithURL:[self buildModelImageString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageUrl) {
            if (!image) {
                self.detailBgImageView.image = placeholderImage;
            }
        }];
    }
    else {
        self.detailBgImageView.needsBlur = YES;
    }
    
    self.originalImageFrame= self.detailRightBgImageView.frame;
    
}

-(void)updateImagesAndPDF {
    //add images and pdf if found
    if (self.dataModel.images.count > 0) {
        //populate with items
        if ([self.dataModel.images[0] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *imageDict = self.dataModel.images[0];
            NSString *imageType = [imageDict objectForKey:@"type"];
            NSString *imageLocation = [imageDict objectForKey:@"full"];
            
            if (/*self.dataModel.images.count == 1 && */[imageType isEqualToString:@"pdf"]) {
                //this is a pdf
                self.pdfButton.hidden = NO;
                self.pdfButtonHeightConstraint.constant = 80;
                
                if ([imageLocation hasPrefix:@"http"] || [imageLocation hasPrefix:@"www"]) {
                    self.detailUrl = imageLocation;
                }
                else {
                    self.detailUrl = [NSString stringWithFormat:@"%@%@", [STAppSettingsManager sharedSettingsManager].baseUrl, imageLocation];
                }                
            }
        }
        else {
            //images
            STStadtinfoOverwiewImages * model = [[STStadtinfoOverwiewImages alloc] init];
            self.pdfButtonHeightConstraint.constant = 0;
            for (model in self.dataModel.images) {
                NSString* imageLocation = [NSString stringWithFormat:@"%@%@",[STAppSettingsManager sharedSettingsManager].baseUrl, model.location];
                [self.imagesDataSource addObject:imageLocation];
                if ([model.type isEqualToString:@"pdf"]) {
                    self.pdfButton.hidden = NO;
                    self.pdfButtonHeightConstraint.constant = self.customerNumberButtonHeightConstraint.constant == 0 ? 80 : 0;
                    if ([imageLocation hasPrefix:@"http"] || [imageLocation hasPrefix:@"www"]) {
                        self.detailUrl = imageLocation;
                    }
                    else {
                        self.detailUrl = [NSString stringWithFormat:@"%@%@", [STAppSettingsManager sharedSettingsManager].baseUrl, imageLocation];
                    }
                }
            }
            // Show the images collection only if no coupon is available.
            self.imagesCollectionViewHeightConstraint.constant = self.customerNumberButtonHeightConstraint.constant == 0 ? 70 : 0;
            if ([self.dataModel isKindOfClass:[STAngeboteModel class]] && [[STAppSettingsManager sharedSettingsManager] showCoupons]) {
                    model = self.dataModel.images.firstObject;
                    NSString* imageLocation = [NSString stringWithFormat:@"%@%@",[STAppSettingsManager sharedSettingsManager].baseUrl, model.location];
                    [self.qrImageView sd_setImageWithURL:[NSURL URLWithString:imageLocation]];
            }
        }
    } else if ([self.dataModel isKindOfClass:[STAngeboteModel class]] && [[STAppSettingsManager sharedSettingsManager] showCoupons]) {
        self.qrImageViewHeightConstraint.constant = 0;
    }
}

-(void)setFonts {
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *titleFont = [settings customFontForKey:@"detailscreen.title.font"];
    UIFont *timeFont = [settings customFontForKey:@"detailscreen.time.font"];
    UIFont *eventTypeFont = [settings customFontForKey:@"detailscreen.event_type.font"];
    UIFont *addressFont = [settings customFontForKey:@"detailscreen.location.font"];
    UIFont *infoLabelFont = [settings customFontForKey:@"detailscreen.info.font"];
    UIFont *descriptionFont = [settings customFontForKey:@"detailscreen.description.font"];
    
    if (titleFont) {
        self.titleLabel.font = titleFont;
    }
    
    if (timeFont) {
        self.timeLabel.font = timeFont;
    }
    
    if (addressFont) {
        self.locationLabel.font = addressFont;
    }
    
    if (infoLabelFont) {
        self.infoLabel.font = infoLabelFont;
    }
    
    if (descriptionFont) {
        self.descriptionLabel.font = descriptionFont;
    }
    
    if (eventTypeFont) {
        self.eventTypeLabel.font = eventTypeFont;
    }
    
    // round curves
    _locationView.layer.cornerRadius = 3;
    _detailInfoView.layer.cornerRadius = 3;
    
    [self.imagesCollectionView reloadData];
    
    [self.view layoutIfNeeded];
}

-(void)dismissView:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.imagesCollectionView) {
        return self.imagesDataSource.count;
    }
    if (self.sharingCollectionDataSource.count > 5)
        return ceil((double)self.sharingCollectionDataSource.count / 3) * 5;
    else
        return self.sharingCollectionDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *collectionCell = [[UICollectionViewCell alloc] init];
    if (collectionView == self.imagesCollectionView) {
        //TODO : change this with datasource
        collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:kImagesCollectionViewIdentifier forIndexPath:indexPath];
        PDFPreviewCollectionViewCell *cell = (PDFPreviewCollectionViewCell*)collectionCell;
        NSURL * imageUrl = [[NSURL alloc] initWithString:self.imagesDataSource[indexPath.row]];
        [cell.previewImageView sd_setImageWithURL:imageUrl];
    } else {
        collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:kActionOptionsCellIdentifier forIndexPath:indexPath];
        ActionOptionsCollectionViewCell *cell =  (ActionOptionsCollectionViewCell*) collectionCell;
        
        if (indexPath.row > 4 && indexPath.row % 5 == 0) {
            cell.imageView.image = [UIImage imageNamed:@"action_options_arrow_left"];
            cell.associatedObject = @(kCollectionViewAnimationDirectionBackward);
        } else if (self.sharingCollectionDataSource.count > 5 && indexPath.row % 5 == 4 && indexPath.row - 1 < self.sharingCollectionDataSource.count) {
            cell.imageView.image = [UIImage imageNamed:@"action_options_arrow_right"];
            cell.associatedObject = @(kCollectionViewAnimationDirectionForward);
        } else {
            NSInteger dataIndex = indexPath.row;
            if (indexPath.row > 4 && self.sharingCollectionDataSource.count > 5) {
                dataIndex -= dataIndex / 5 * 2;
            }
            
            if (dataIndex < self.sharingCollectionDataSource.count) {
                id icon = self.sharingCollectionDataSource[dataIndex][@"icon"];
                
                if ([icon isKindOfClass:[NSString class]]) {
                    cell.imageView.image = [UIImage imageNamed:icon];
                } else {
                    if ([self.dataModel conformsToProtocol:@protocol(Favoritable)]) {
                        BOOL favorite = NO;
                        favorite = ((STMainModel<Favoritable> *)self.dataModel).favorite;
                        NSString *favoriteKey = favorite ? @"on" : @"off";
                        
                        if ([favoriteKey isEqualToString:@"on"]) {
                            cell.imageView.image = [[UIImage imageNamed:icon[favoriteKey]] imageTintedWithColor:[UIColor partnerColor]];
                        }
                        else{
                            cell.imageView.image = [UIImage imageNamed:icon[favoriteKey]];

                        }
                        
                    }

                }
                
                cell.associatedObject = self.sharingCollectionDataSource[dataIndex][@"SEL"];
            } else {
                cell.imageView.image = nil;
                cell.associatedObject = nil;
            }
        }
    }
    
    return collectionCell;
}

#pragma mark - ActionOptionsAnimation

- (void)animateCollectionViewToDirection:(CollectionViewAnimationDirection)direction buttonIndexPath:(NSIndexPath *)buttonIndexPath {
    if (direction == kCollectionViewAnimationDirectionForward) {
        [self.actionsOptions scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:buttonIndexPath.row + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    } else {
        [self.actionsOptions scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:buttonIndexPath.row - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.imagesCollectionView) {
        //show preview galery of the images
        STDetailImageGalleryViewController *galleryDController = [[STDetailImageGalleryViewController alloc] initWithNibName:@"STDetailImageGalleryViewController" bundle:nil andDataSource:self.imagesDataSource ];
        [self.navigationController pushViewController:galleryDController animated:YES];
        
    } else {
        ActionOptionsCollectionViewCell *cell = (ActionOptionsCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

        if ([cell.associatedObject isKindOfClass:[NSNumber class]]) {
            CollectionViewAnimationDirection direction = [cell.associatedObject integerValue];
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
        NSInteger numberOfItemsPerPage = self.sharingCollectionDataSource.count >= 5 ? 5 : self.sharingCollectionDataSource.count;
        CGSize newSize = CGSizeMake(collectionView.frame.size.width / numberOfItemsPerPage, collectionView.frame.size.height);
        NSLog(@"%.0f, %.0f", self.view.frame.size.width, newSize.width);
        return newSize;
    }
}

#pragma mark - collection sharing actions

-(void)didClickFavorites:(ActionOptionsCollectionViewCell *)cell {
    if ([self.dataModel conformsToProtocol:@protocol(Favoritable)]) {
        STMainModel<Favoritable> *model = (STMainModel<Favoritable> *)self.dataModel;
        if ([model isFavorite]) {
            
          
            
            cell.imageView.image = [UIImage imageNamed:[self.sharingOptions valueForKeyPath:@"favorite.icon.off"]] ;
        } else {
            cell.imageView.image = [[UIImage imageNamed:[self.sharingOptions valueForKeyPath:@"favorite.icon.on"]] imageTintedWithColor:[UIColor partnerColor]];
        }
        
        [[StLocalDataArchiever sharedArchieverManager] saveFavoriteStatusForModel:model];
    }
    
}

-(void)didClickPhone {
    NSString* phoneNumber = @"";
    if (self.dataModel) {
        phoneNumber = [self.dataModel valueForKey:@"phone"];
    } else if (self.parkHausModel) {
        phoneNumber = self.parkHausModel.phone;
    }
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    if (cleanedString.length > 0) {
        NSString *url = [@"telprompt://" stringByAppendingString:cleanedString];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

-(void)didClickWebsite {
    NSString* url = @"";
    if (self.dataModel) {
        url = [self.dataModel valueForKey:@"contactUrl"];
    } else if (self.parkHausModel) {
        url = self.parkHausModel.website;
    }



    STWebViewDetailViewController *webVC = [[STWebViewDetailViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

-(void)didClickEmail {
    NSString* email = @"";
    if (self.dataModel) {
        email = [self.dataModel valueForKey:@"email"];
    } else if (self.parkHausModel) {
        email = self.parkHausModel.email;
    }
    NSString *url = [NSString stringWithFormat:@"mailto:%@",email];
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (void)didClickShare
{
    NSString *text = @"";
    NSString *title = [self modelTitle];
    NSString *body  = self.dataModel.body;
    
    if (title) text = title;
    if (body)
    {
        if (title) text = [NSString stringWithFormat:@"%@\n\n%@", title, body];
        else       text = body;
    }
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:text];
    
    UIImage *imageToSend = self.detailRightBgImageView.image;
    if (imageToSend) { // Sometimes I don't get the image (default image to send). Check if it is nil or not
        [sharingItems addObject:imageToSend];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    NSString* cityName = [[STAppSettingsManager sharedSettingsManager] homeScreenTitle];
    if (cityName.length == 0) {
        cityName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    NSString *appName = cityName;
    
    NSString *subject;
    if ([appName containsString:@"App"]) {
        subject = [NSString stringWithFormat:@"Gefunden in der %@", appName];
    } else {
        subject = [NSString stringWithFormat:@"Gefunden in der App %@", appName];
    }
    
    [activityController setValue:subject forKey:@"subject"];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)didClickShowOnMap {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Bitte wählen" delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:nil otherButtonTitles:
                            @"Auf Karte anzeigen",
                            @"Route zur Adresse", nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    popup.delegate = self;
}

- (void)didClickCalendar {
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
    NSString* endDateString = [NSString stringWithFormat:@"%@ %@", self.dataModel.endDateString, self.dataModel.endDateHourString];
    NSDate* endDate = [dateFormatter dateFromString:endDateString];
    NSString* startDateString = [NSString stringWithFormat:@"%@", self.dataModel.startDateString];
    NSDate* startDate = [dateFormatter dateFromString:startDateString];
    event.title     = [self modelTitle];;
    event.location  = self.dataModel.address;
    event.startDate = startDate;
    event.endDate   = endDate;
    event.notes     = self.dataModel.body;
    
    // Create the edit dialog
    EKEventEditViewController *eventController = [[EKEventEditViewController alloc] init];
    [eventController setEditViewDelegate:self];
    [eventController setEventStore:eventStore];
    [eventController setEvent:event];
    
    // Display the event dialog modal
    [self.navigationController presentViewController:eventController animated:YES completion:nil];
}

/**
 *  Alert will be shown when the user presses the "Calendar button",
 *  but the access to the iOS calendar is denied.
 *
 *  This method will be called, when the user presses any button of the
 *  alertView.
 *  If buttonIndex is equal to 1, then open the settings app, so that
 *  the user can set the m.eins settings to allow access to the calendar
 */
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
            STAnnotationsMapViewController *mapVC = nil;
            if (self.dataModel) {
                mapVC = [[STAnnotationsMapViewController alloc] initWithData:@[self.dataModel]];
            } else if (self.parkHausModel) {
                mapVC = [[STAnnotationsMapViewController alloc]initWithData:@[self.parkHausModel]];
            }
            [self.navigationController pushViewController:mapVC animated:YES];
        } else if (buttonIndex == 1) {
            MKPlacemark *placemark = nil;
            if (self.dataModel) {
                placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([self.dataModel.latitude doubleValue], [self.dataModel.longitude doubleValue])
                                              addressDictionary:nil];
            } else if (self.parkHausModel) {
                placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([self.dataModel.latitude floatValue], [self.parkHausModel.longitude floatValue])
                                                  addressDictionary:nil];
            }
            
            NSArray* arrMkItems = [NSArray arrayWithObjects:
                                   [MKMapItem mapItemForCurrentLocation],
                                   [[MKMapItem alloc] initWithPlacemark:placemark],
                                   nil];
            [MKMapItem openMapsWithItems:arrMkItems
                           launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                                          MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsDirectionsModeKey,nil]
             ];
        }
    }
}
- (IBAction)showPdf:(id)sender {
    STWebViewDetailViewController *webPage = [[STWebViewDetailViewController alloc] initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:self.detailUrl];
    [self.navigationController pushViewController:webPage animated:YES];
}

#pragma mark - Data updates

- (NSString*)modelTitle {
    NSString * returnedTitle = @"";
    if (self.dataModel) {
        returnedTitle = self.dataModel.title;
    } else if (self.parkHausModel) {
        returnedTitle = self.parkHausModel.name;
    }
    else if (self.tankStationModel) {
        returnedTitle = self.tankStationModel.title;
    }
    else if (self.generalParkHausModel) {
        returnedTitle = self.generalParkHausModel.title;
    }
    return returnedTitle;
}

- (NSString*)modelAddress {
    NSString * returnedAddress = @"";
    if (self.dataModel) {
        returnedAddress = self.dataModel.address;
    } else if (self.parkHausModel) {
        returnedAddress = self.parkHausModel.street1;
    }
    else if (self.tankStationModel) {
        returnedAddress = self.tankStationModel.address;
    }
    else if (self.generalParkHausModel) {
        returnedAddress = self.generalParkHausModel.address;
    }
    return returnedAddress;
}

- (NSString*)modelBodyString {
    NSString * returnedString = @"";
    if (self.dataModel) {
        returnedString = self.dataModel.body;
    } else if (self.parkHausModel) {
//        returnedString = self.parkHausModel.descriptionParkhaus;
    }
    else if (self.tankStationModel) {
      returnedString = self.tankStationModel.body;
    }
    else if (self.generalParkHausModel) {
        returnedString = self.generalParkHausModel.body;
    }
    return returnedString;
}

- (NSString*)modelImageString {
    NSString * returnedImageString = @"";
    if (self.dataModel) {
        returnedImageString = self.dataModel.image;
    } else if (self.parkHausModel) {
        returnedImageString = self.parkHausModel.image_url;
    }
    return returnedImageString;
}

- (NSURL*)buildModelImageString {
    NSURL * returnedImageUrl = nil;
    if (self.dataModel) {
        returnedImageUrl = [[STRequestsHandler sharedInstance] buildImageUrl:[self modelImageString]];
    } else if (self.parkHausModel) {
        returnedImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.parkinghq.com/%@", self.parkHausModel.image_url]];
    }
    return returnedImageUrl;
}

#pragma mark - WebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    self.openingHoursMultipleViewsHeightConstraint.constant = fittingSize.height;
    [self.view layoutIfNeeded];
}

#pragma mark-
- (IBAction)customerButtonPressed:(UIButton *)sender {
    if (self.qrImageViewHeightConstraint.constant == 0 && self.dataModel.images.count > 0) {
        self.qrImageViewHeightConstraint.constant = 130;
        [UIView animateWithDuration:0.75 animations:^{
            [self.view layoutIfNeeded];
            [self.detailsScrollView setContentOffset:CGPointMake(0, self.detailsScrollView.contentSize.height - self.detailsScrollView.frame.size.height) animated:YES];
        }];
    } else {
        [self.customerNumberButton setTitleColor:[UIColor partnerColor] forState:UIControlStateNormal];
        [self.customerNumberButton setTitleColor:[UIColor partnerColor] forState:UIControlStateDisabled];
        self.customerNumberButton.enabled = NO;
    }
}

@end
