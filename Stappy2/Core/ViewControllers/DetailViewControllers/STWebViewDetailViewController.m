//
//  STWebViewDetailViewController.m
//  Stappy2
//
//  Created by Cynthia Codrea on 07/12/15.
//  Copyright © 2015 Cynthia Codrea. All rights reserved.
//

#import "STWebViewDetailViewController.h"

@interface STWebViewDetailViewController ()

@property(nonatomic, strong)NSString* detailUrl;

@end

@implementation STWebViewDetailViewController

- (instancetype)initWithURL:(NSString *)url {
    return [self initWithNibName:@"STWebViewDetailViewController" bundle:nil andDetailUrl:url];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDetailUrl:(NSString*)detailUrl {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _detailUrl = detailUrl;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailWebView.delegate = self;
    self.detailWebView.scalesPageToFit = YES;
    [self.activityIndicator startAnimating];
    NSURL *requestUrl = [NSURL URLWithString:self.detailUrl];
    NSURLRequest *webRequest = [NSURLRequest requestWithURL:requestUrl];
    
    [self.detailWebView loadRequest:webRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
}

@end
