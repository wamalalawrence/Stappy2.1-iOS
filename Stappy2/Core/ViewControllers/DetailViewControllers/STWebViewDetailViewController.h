//
//  STWebViewDetailViewController.h
//  Stappy2
//
//  Created by Cynthia Codrea on 07/12/15.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STWebViewDetailViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (instancetype)initWithURL:(NSString *)url;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDetailUrl:(NSString*)detailUrl;

@end
