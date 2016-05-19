//
//  STReporterRecapViewController.m
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReporterRecapViewController.h"
#import "STReportCategory.h"
#import "STReportType.h"
#import <MessageUI/MessageUI.h>
#import "STAppSettingsManager.h"

@interface STReporterRecapViewController ()<UITextFieldDelegate, MFMailComposeViewControllerDelegate>{
    UITextField*_activeField;
    MFMailComposeViewController *_mailComposer;
}
@property(nonatomic,weak) IBOutlet UILabel*categoryLabel;
@property(nonatomic,weak) IBOutlet UILabel*typeLabel;
@property(nonatomic,weak) IBOutlet UILabel*descriptionHeaderLabel;
@property(nonatomic,weak) IBOutlet UILabel*descriptionLabel;
@property(nonatomic,weak) IBOutlet UILabel*addressLabel;
@property(nonatomic,weak) IBOutlet UILabel*infoHeaderLabel;
@property(nonatomic,weak) IBOutlet UITextField*firstNameTextField;
@property(nonatomic,weak) IBOutlet UITextField*lastNameTextField;
@property(nonatomic,weak) IBOutlet UIScrollView*scrollView;

@property(nonatomic,weak) IBOutlet UIButton*sendButton;
-(IBAction)sendButtonTapped:(id)sender;

@end

@implementation STReporterRecapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [@"Störung Melden" uppercaseString];

    self.categoryLabel.text = self.currentReport.category.name;
    self.typeLabel.text = self.currentReport.type.name;
    self.descriptionLabel.text = self.currentReport.note;
    self.addressLabel.text = self.currentReport.fullAddress;
    
    [self registerForKeyboardNotifications];
    [self customizeAppearance];
    
}

-(void)customizeAppearance{
    UIFont* headerTitleFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.headerTitle.font"];
    UIFont* headerSubTitleFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.headerSubTitle.font"];
    UIFont* sectionTitleFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.sectionTitle.font"];
    UIFont* inputTextFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.inputText.font"];
    UIFont* buttonTextFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.buttonText.font"];
    UIFont* cellTextFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.cellText.font"];
    
    if (buttonTextFont) {
        self.sendButton.titleLabel.font = buttonTextFont;
    }
    if (sectionTitleFont) {
        self.infoHeaderLabel.font = sectionTitleFont;
        self.descriptionHeaderLabel.font = sectionTitleFont;
    }
    
    if (headerTitleFont) {
        self.categoryLabel.font = headerTitleFont;
    }
    if (headerSubTitleFont) {
        self.typeLabel.font = headerSubTitleFont;
    }
    if (cellTextFont) {
        self.descriptionLabel.font = cellTextFont;
        self.addressLabel.font = cellTextFont;
    }
    if (inputTextFont) {
        self.firstNameTextField.font = inputTextFont;
        self.lastNameTextField.font = inputTextFont;
    }
}

#pragma mark - Keyboard & textfield delegate

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:_activeField.frame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    UITextField *nextTextField = [self.view viewWithTag:textField.tag+1];
    if (nextTextField!=nil) {
        [nextTextField becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Input validation and mail composing

-(IBAction)sendButtonTapped:(id)sender{
    
    if (self.firstNameTextField.text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Bitte geben sie ihren Vornamen ein" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    if (self.lastNameTextField.text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Bitte geben sie ihren Nachnamen ein" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    self.currentReport.firstName = self.firstNameTextField.text;
    self.currentReport.lastName = self.lastNameTextField.text;
    
    [self composeEmail];

    
}

-(void)composeEmail{

    //have to be tested on real device - it crashed in simulator when using images
    
    if (!_mailComposer) {
        _mailComposer = [[MFMailComposeViewController alloc]init];
        _mailComposer.mailComposeDelegate = self;
    }
    NSMutableString*mutableString = [[NSMutableString alloc] init];
    
    if(self.currentReport.note){
        [mutableString appendString:[NSString stringWithFormat:@"<p>Bemerkung: %@</p><br>",self.currentReport.note]];

    }
    if(self.currentReport.category.name){
        [mutableString appendString:[NSString stringWithFormat:@"<p>Kategorie: %@</p>",self.currentReport.category.name]];
     
    }
    if(self.currentReport.type.name){
        [mutableString appendString:[NSString stringWithFormat:@"<p>Art: %@</p>",self.currentReport.type.name]];
  
    }
    if(self.currentReport.fullAddress){
        [mutableString appendString:[NSString stringWithFormat:@"<p>Adresse: %@</p>",self.currentReport.fullAddress]];

    }
    if(self.currentReport.latitude !=0.0){
        [mutableString appendString:[NSString stringWithFormat:@"<p>Lage (GPS): %f | %f</p>",self.currentReport.latitude, self.currentReport.longitude]];
  
    }
    if(self.currentReport.firstName){
        [mutableString appendString:[NSString stringWithFormat:@"<p>Vorname: %@</p>",self.currentReport.firstName]];

    }
    if(self.currentReport.lastName){
        [mutableString appendString:[NSString stringWithFormat:@"<p>Nachname: %@</p>",self.currentReport.lastName]];

    }
    
    
    [_mailComposer setSubject:@"Meldung"];
    [_mailComposer setToRecipients:@[[STAppSettingsManager sharedSettingsManager].reportingEmail]];
    [_mailComposer setMessageBody:mutableString isHTML:YES];
    
    for (UIImage* image in self.currentReport.photos) {
        NSData *jpegData = UIImageJPEGRepresentation(image, 0.7);
        NSString *fileName = @"meldung";
        fileName = [fileName stringByAppendingPathExtension:@"jpeg"];
        [_mailComposer addAttachmentData:jpegData mimeType:@"image/jpeg" fileName:fileName];
    }
    
    [self presentViewController:_mailComposer animated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller
             didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
        else{
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"reportComplete"];
            [self.navigationController pushViewController:viewController animated:YES];
        }

    }];

    
   }


@end
