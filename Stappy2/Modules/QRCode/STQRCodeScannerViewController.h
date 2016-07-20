//
//  STQRCodeScannerViewController.h
//  Stappy2
//
//  Created by Denis Grebennicov on 26/01/16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface STQRCodeScannerViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet UIView *recognizedQRCodeView;
@property (weak, nonatomic) IBOutlet UILabel *recognizedQRCodeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;
@end
