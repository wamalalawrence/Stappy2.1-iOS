//
//  SaehlerstandEingebenViewController.m
//  Stappy2
//
//  Created by Andrei Neag on 01.04.2016.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "SaehlerstandEingebenViewController.h"
#import "Defines.h"
#import "NSString+Utils.h"
#import "STAppSettingsManager.h"
#import "UIColor+STColor.h"

@interface SaehlerstandEingebenViewController ()

@property (weak, nonatomic) StappyTextField *activeTextField;

@end

@implementation SaehlerstandEingebenViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadSavedData];
    self.sendEmailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    if ([[STAppSettingsManager sharedSettingsManager] shouldHideNameAndAddressInDetailsScreen]) {
        self.vornameTextField.hidden = true;
        self.nachnameTextField.hidden = true;
        self.strasseTextField. hidden = true;
        self.nrTextField.hidden = true;
        self.plzTextField.hidden = true;
        self.ortTextField.hidden = true;
        self.zaehlerNummerTopConstraint.constant = 8;
    }
    [self setFontsAndColors];
}

-(void)setFontsAndColors {
    //Font
    STAppSettingsManager *settings = [STAppSettingsManager sharedSettingsManager];
    UIFont *titleFont = [settings customFontForKey:@"detailscreen.title.font"];
    
    if (titleFont) {
        self.topTitleLabel.font = titleFont;
        self.persnalDataLabel.font = titleFont;
        self.sendEmailButton.titleLabel.font = titleFont;
    }
    self.sendEmailButton.layer.borderColor = [UIColor partnerColor].CGColor;
    [self.sendEmailButton setTitleColor:[UIColor partnerColor] forState:UIControlStateNormal];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.topTitleLabel.textColor = [UIColor partnerColor];
    self.persnalDataLabel.textColor = [UIColor partnerColor];
    [self.view layoutIfNeeded];
}


- (void)loadSavedData {
    NSDictionary * savedDataDict = [[NSUserDefaults standardUserDefaults] objectForKey:kIndexDetailsDictionaryData];
    self.vornameTextField.text = [savedDataDict objectForKey:kVornameKey];
    self.nachnameTextField.text = [savedDataDict objectForKey:kNachNameKey];
    self.strasseTextField.text = [savedDataDict objectForKey:kStrasseKey];
    self.nrTextField.text = [savedDataDict objectForKey:kNrKey];
    self.plzTextField.text = [savedDataDict objectForKey:kPlzKey];
    self.ortTextField.text = [savedDataDict objectForKey:kOrtKey];
    self.zahlernulmTextField.text = [savedDataDict objectForKey:kZahlernummerKey];
}

- (void)saveData {
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
    if (self.vornameTextField.text.length > 0) {
        [dataDict setObject:self.vornameTextField.text forKey:kVornameKey];
    }
    if (self.nachnameTextField.text.length > 0) {
        [dataDict setObject:self.nachnameTextField.text forKey:kNachNameKey];
    }
    if (self.strasseTextField.text.length > 0) {
        [dataDict setObject:self.strasseTextField.text forKey:kStrasseKey];
    }
    if (self.nrTextField.text.length > 0) {
        [dataDict setObject:self.nrTextField.text forKey:kNrKey];
    }
    if (self.plzTextField.text.length > 0) {
        [dataDict setObject:self.plzTextField.text forKey:kPlzKey];
    }
    if (self.ortTextField.text.length > 0) {
        [dataDict setObject:self.ortTextField.text forKey:kOrtKey];
    }
    if (self.zahlernulmTextField.text.length > 0) {
        [dataDict setObject:self.zahlernulmTextField.text forKey:kZahlernummerKey];
    }
    [[NSUserDefaults standardUserDefaults] setObject:dataDict forKey:kIndexDetailsDictionaryData];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification methods

- (void)keyboardWasShown:(NSNotification*)notif {
    NSDictionary* userInfo = notif.userInfo;
    CGFloat keyboardHeight = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [UIView animateWithDuration:0.01 animations:^{
        self.scrollViewBottomConstraint.constant = keyboardHeight;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)keyboardWillBeHidden:(NSNotification*)notif {
    [UIView animateWithDuration:0.01 animations:^{
        self.scrollViewBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)dismissTextField:(UITapGestureRecognizer*)gesture {
    [self.activeTextField resignFirstResponder];
}

#pragma mark - TextField delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = (StappyTextField *)textField;
    [self.zahlerScrollView scrollRectToVisible:textField.frame animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self saveData];
}

#pragma mark - MFMailComposeViewControllerDelegate

-(IBAction)EmailButtonAction {
    
    if ([MFMailComposeViewController canSendMail])
    {
        //get bundle name
        //get city name from the bundle identifier
        NSString* cityName = [[STAppSettingsManager sharedSettingsManager] homeScreenTitle];
        if (cityName.length == 0) {
            cityName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        }
        cityName = [cityName splitString:cityName];
        NSString * messagBody;
        if (self.nachnameTextField.text.length > 0 ) {
             messagBody =[NSString stringWithFormat:@"Sehr geehrte Stadtwerke %@, \n                                    Ich möchte Ihnen hiermit meinen %@ Zählerstand übermitteln.\n Zählerstand: %@,%@ \n                                          Name: %@ %@ \n Addresse: %@ %@ 1  \n %@ %@ \n Zählernummer:%@",cityName,self.previousSelectedUtiliityTitle,self.indexTextField.text, self.lastPositionIndexTextField.text,self.vornameTextField.text, self.nachnameTextField.text, self.strasseTextField.text, self.nrTextField.text, self.plzTextField.text, self.ortTextField.text, self.zahlernulmTextField.text];
        }
        else {
        messagBody =[NSString stringWithFormat:@"Sehr geehrte Stadtwerke %@, \n Ich möchte Ihnen hiermit meinen %@ Zählerstand übermitteln.\n Zählerstand: %@,%@ \n Zählernummer:%@",cityName,self.previousSelectedUtiliityTitle,self.indexTextField.text, self.lastPositionIndexTextField.text, self.zahlernulmTextField.text];
        }
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bg_iPhone.png"] forBarMetrics:UIBarMetricsDefault];
        controller.navigationBar.tintColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        [controller setSubject:@"Zaehlerstand"];
        [controller setMessageBody:messagBody isHTML:NO];
        NSString* email = [STAppSettingsManager sharedSettingsManager].zahlerstandEmail;
        [controller setToRecipients:@[email]];

        [self presentViewController:controller animated:YES completion:NULL];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"No Email Accounts Available." message:@"Please setup at least one account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] ;
        [alert show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
