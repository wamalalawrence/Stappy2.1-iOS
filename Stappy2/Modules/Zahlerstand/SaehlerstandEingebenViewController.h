//
//  SaehlerstandEingebenViewController.h
//  Stappy2
//
//  Created by Andrei Neag on 01.04.2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "StappyTextField.h"

@interface SaehlerstandEingebenViewController : UIViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet StappyTextField *vornameTextField;
@property (weak, nonatomic) IBOutlet StappyTextField *nachnameTextField;
@property (weak, nonatomic) IBOutlet StappyTextField *strasseTextField;
@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet StappyTextField *nrTextField;
@property (weak, nonatomic) IBOutlet StappyTextField *plzTextField;
@property (weak, nonatomic) IBOutlet StappyTextField *ortTextField;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet StappyTextField *zahlernulmTextField;
@property (weak, nonatomic) IBOutlet StappyTextField *indexTextField;
@property (weak, nonatomic) IBOutlet StappyTextField *lastPositionIndexTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendEmailButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zaehlerNummerTopConstraint;

@property (weak, nonatomic) IBOutlet UILabel *persnalDataLabel;
@property (retain, nonatomic) NSString * previousSelectedUtiliityTitle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UIScrollView *zahlerScrollView;

@end
