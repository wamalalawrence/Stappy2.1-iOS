//
//  STDetailImageGalleryViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 25/04/2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STDetailImageGalleryViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *detailImageGallery;
@property (weak, nonatomic) IBOutlet UIPageControl *galleryPageControl;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDataSource:(NSArray*)dataSource;

@end
