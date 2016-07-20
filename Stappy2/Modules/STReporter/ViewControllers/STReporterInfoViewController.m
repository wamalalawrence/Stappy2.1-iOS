//
//  STReporterInfoViewController.m
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReporterInfoViewController.h"
#import "STReportCategory.h"
#import "STReportType.h"
#import "STReportTypeTableViewCell.h"
#import "STReporterRecapViewController.h"
#import "STAppSettingsManager.h"

@interface STReporterInfoViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController *_imagePicker;
    UIActionSheet *_actionSheet;
    UIImage *_image;
}
@property (nonatomic,strong) NSArray*categories;
@property (nonatomic,weak) IBOutlet UITableView*typeTable;
@property (nonatomic,weak) IBOutlet UILabel*tableHeaderLabel;
@property (nonatomic,weak) IBOutlet UILabel*textViewHeaderLabel;
@property (nonatomic,weak) IBOutlet UILabel*streetLabel;
@property (nonatomic,weak) IBOutlet UILabel*townLabel;
@property (nonatomic,weak) IBOutlet UITextView*noteTextView;
@property (nonatomic,weak) IBOutlet UIButton*nextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeTableViewHeightConstraint;
@property (nonatomic,weak) IBOutlet UIView*photoContainerView;
@property(nonatomic,weak) IBOutlet UIScrollView*scrollView;
@property (nonatomic,weak) IBOutlet UIButton*cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *cameraLabel;

@end

@implementation STReporterInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"Welche Störung?" ;
    
    self.categories = [STReportCategory allCategories];
    self.currentReport.category = self.categories[0];
    if (!self.currentReport.photos) {
        self.currentReport.photos = [NSMutableArray array];
    }
    [self.typeTable reloadData];
    
    //adjust table picker height based on category
    self.typeTableViewHeightConstraint.constant = 50*self.currentReport.category.types.count;
    
    //preselect fist type
    NSIndexPath*selectedPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.typeTable selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    self.currentReport.type = self.currentReport.category.types[0];
    
    self.tableHeaderLabel.text = self.currentReport.category.name;
    self.streetLabel.text = self.currentReport.street;
    self.townLabel.text = self.currentReport.town;
    
    [self registerForKeyboardNotifications];
    [self customizeAppearance];
}

-(void)customizeAppearance{

    UIFont* headerTitleFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.headerTitle.font"];
    UIFont* headerSubTitleFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.headerSubTitle.font"];
    UIFont* sectionTitleFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.sectionTitle.font"];
    UIFont* inputTextFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.inputText.font"];
    UIFont* buttonTextFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.buttonText.font"];
    
    if (headerTitleFont) {
        self.streetLabel.font = headerTitleFont;
    }
    if (headerSubTitleFont) {
        self.townLabel.font = headerSubTitleFont;
    }
    if (sectionTitleFont) {
        self.tableHeaderLabel.font = sectionTitleFont;
        self.textViewHeaderLabel.font = sectionTitleFont;
    }
    if (inputTextFont) {
        self.noteTextView.font = inputTextFont;
    }
    if (buttonTextFont) {
        self.nextButton.titleLabel.font = buttonTextFont;
        self.cameraLabel.font = buttonTextFont;
    }
}

#pragma mark - TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentReport.category.types.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    STReportTypeTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"typeCell"];
    [cell setupWithReportType:self.currentReport.category.types[indexPath.row]];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.currentReport.type = self.currentReport.category.types[indexPath.row];
}

#pragma mark - Keyboard & textview delegate

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    //limit number of characters and resign on return
    if ([text isEqualToString:@"\n"] || (textView.text.length + (text.length - range.length) > 140)) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    [self.scrollView scrollRectToVisible:self.noteTextView.superview.frame animated:YES];
 
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Photo action

- (IBAction)cameraButtonTapped:(id)sender
{
    if (self.currentReport.photos.count<4) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Stornieren"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Mach ein Foto", @"Aus der Fotos auswählen", nil];
            
            [_actionSheet showInView:self.view];
            
        } else {
            [self choosePhotoFromLibrary];
        }
    }
 }

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [self takePhoto];
        
    } else if (buttonIndex == 1) {
        
        [self choosePhotoFromLibrary];
    }
    
    _actionSheet = nil;
}

- (void)takePhoto
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = info[UIImagePickerControllerEditedImage];
    [self addImage:_image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addImage:(UIImage*)image{
    
    [self.currentReport.photos addObject:image];
    [self showImages];
}

-(void)showImages{
    
    for (id subView in self.photoContainerView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    //hide button description
    if (self.currentReport.photos.count>0) {
        self.cameraLabel.hidden = YES;
    }
    
    CGFloat imageWidthHeight = CGRectGetHeight(self.photoContainerView.frame)-10;
    int counter = 0;
    
    for (UIImage*image in self.currentReport.photos) {
        
        UIImageView*imageView = [[UIImageView alloc] initWithImage:image];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = CGRectMake((counter*(imageWidthHeight+5)), 5, imageWidthHeight, imageWidthHeight);
        counter++;
        [self.photoContainerView addSubview:imageView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"recapSegue"])
    {
        self.currentReport.note = self.noteTextView.text;
        STReporterRecapViewController *viewController = [segue destinationViewController];
        viewController.currentReport = self.currentReport;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
