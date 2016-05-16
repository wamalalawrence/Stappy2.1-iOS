//
//  STReportAddressSearchViewController.m
//  Stappy2
//
//  Created by Pavel Nemecek on 10/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STReportAddressSearchViewController.h"
#import "STReportAddressTableViewCell.h"
#import "STRequestsHandler.h"
#import "STAppSettingsManager.h"

@interface STReportAddressSearchViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property(nonatomic,strong) NSArray*searchResults;
@property(nonatomic,weak) IBOutlet UITableView*tableView;
@property(nonatomic,weak) IBOutlet UITextField*textField;
@property(nonatomic,weak) IBOutlet UIButton*searchButton;
-(IBAction)searchButtonTapped:(id)sender;
@end

@implementation STReportAddressSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [@"Ort der Störung?" uppercaseString];
    
    self.searchResults = @[];
    [self.textField becomeFirstResponder];
    
    [self customizeAppearance];
}

-(void)customizeAppearance{
    UIFont* buttonTextFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.buttonText.font"];
    UIFont* inputText = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.inputText.font"];
    
    if (buttonTextFont) {
        self.searchButton.titleLabel.font = buttonTextFont;
    }
    if (inputText) {
        self.textField.font = inputText;
    }
}

#pragma mark - Tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    STReportAddressTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    [cell setupWithPrediction:self.searchResults[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    STPrediction*prediction = self.searchResults[indexPath.row];
    if (_delegate) {
        [_delegate searchControllerDidSelectPrediction:prediction];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString*searchTerm = [self searchTermFromString:[textField.text stringByReplacingCharactersInRange:range withString:string]];
  
    if ([searchTerm length] >=3) {
        [self performSearchWithTerm:searchTerm];
           }
    else{
        [self clearSearchResults];
    }
    return YES;
}

-(void)clearSearchResults{
    self.searchResults = @[];
    [self.tableView reloadData];
}

// encode and trim string before sending it to API
-(NSString*)searchTermFromString:(NSString*)string{
   
    NSString* searchTerm = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    searchTerm = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return searchTerm;
}

-(void)performSearchWithTerm:(NSString*)term{
    [[STRequestsHandler sharedInstance] searchForAddress:term completion:^(NSArray *predictions, NSError *error) {
       
        if (predictions) {
            self.searchResults = predictions;
            [self.tableView reloadData];
        }
        else{
            [self clearSearchResults];
        }
    }];
}

-(IBAction)searchButtonTapped:(id)sender{
    [self.textField resignFirstResponder];
    if (self.textField.text.length>0) {
        [self performSearchWithTerm:[self searchTermFromString:self.textField.text]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
