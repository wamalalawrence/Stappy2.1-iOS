//
//  STRegionPickerSearchViewController.m
//  EndiosRegionPicker
//
//  Created by Thorsten Binnewies on 20.04.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STRegionPickerSearchViewController.h"
#import "STRegionPickerSearchTableViewCell.h"

#define kNavBarTintColor [UIColor colorWithRed:26.0/255.0 green:96.0/255.0 blue:166.0/255.0 alpha:1.0]
//
#define kRegPickerJSONIdentifierRegions @"regions"
#define kRegPickerJSONIdentifierID @"id"
#define kRegPickerJSONIdentifierName @"name"
#define kRegPickerJSONIdentifierXPos @"xPos"
#define kRegPickerJSONIdentifierYPos @"yPos"
#define kRegPickerJSONIdentifierShortcut @"shortcut"
#define kRegPickerJSONIdentifierZipCodes @"zipCodes"
#define kRegPickerJSONIdentifierButton @"button"
//
#define kRegPickerMapImage @"map.png"
#define kRegPickerBackgroundImage @"image_content_bg_national_blur.jpg"
#define kRegPickerNavBarIcon @"icon_content_badge_map_germany.png"
#define kRegPickerNavBarIconWithBadge @"icon_content_badge_map_germany_cutted.png"
#define kRegPickerRegionsFile @"regions-suewag.json"
#define kRegPickerAnnotationFont [UIFont fontWithName:@"RWEHeadline-MediumCondensed" size:50.0f * scale]
#define kRegPickerFont [UIFont fontWithName:@"RWEHeadline-MediumCondensed" size:18]
#define kRegionPickerInputFont [UIFont fontWithName:@"RWEHeadline-RegularCondensed" size:15]
#define kRegPickerSearchForegroundColor [UIColor colorWithRed:66.0/255.0 green:80.0/255.0 blue:75.0/255.0 alpha:1.0]
#define kRegPickerSearchBackgroundColor [UIColor colorWithRed:44.0/255.0 green:60.0/255.0 blue:55.0/255.0 alpha:1.0]
#define kRegPickerSelectColor [UIColor colorWithRed:254.0/255.0 green:197.0/255.0 blue:3.0/255.0 alpha:1.0]
#define kRegPickerTextColor [UIColor whiteColor]
//
#define kRegPickerSearchClearButtonImage @"icon_content_clear_text.png"

@interface STRegionPickerSearchViewController ()

@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) UINib *cellNIB;

@end

@implementation STRegionPickerSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.searchTextField.delegate = self;
    self.searchResults = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.cellNIB = [UINib nibWithNibName:@"STRegionPickerSearchTableViewCell" bundle:nil];
    [self.tableView registerNib:self.cellNIB forCellReuseIdentifier:@"searchCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self adjustInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - interface

- (void)adjustInterface {

    self.backgroundImageView.image = [UIImage imageNamed:kRegPickerBackgroundImage];
    
    self.titleLabel.textColor = kRegPickerTextColor;
    self.titleLabel.font = kRegPickerFont;

    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton.frame = CGRectMake(0, 0, 20, 20);
    [clearButton setImage:[UIImage imageNamed:kRegPickerSearchClearButtonImage] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearTextField) forControlEvents:UIControlEventTouchUpInside];
    self.searchTextField.rightView = clearButton;
    self.searchTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    self.searchView.backgroundColor = kRegPickerSearchBackgroundColor;
    self.searchTextField.font = kRegionPickerInputFont;
    self.searchTextField.backgroundColor = kRegPickerSearchForegroundColor;
    self.searchTextField.tintColor = kRegPickerSelectColor;
    
}

#pragma mark - text field delegate

- (void)clearTextField {
    self.searchTextField.text = @"";
    [self.searchResults removeAllObjects];
    [self.tableView reloadData];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *searchString;
    if (!string || [string isEqualToString:@""]) {
        searchString = [textField.text substringWithRange:NSMakeRange(0, textField.text.length-1)];
    } else {
        searchString = [NSString stringWithFormat:@"%@%@", textField.text, string];
    }
    [self findRegionsWithSearchString:searchString];
    
    return YES;
    
}

- (void)findRegionsWithSearchString:(NSString*)searchString {
    [self.searchResults removeAllObjects];
    for (NSDictionary *regDict in self.allRegions) {
        NSString *testString = [[regDict objectForKey:kRegPickerJSONIdentifierName] lowercaseString];
        if ([testString hasPrefix:[searchString lowercaseString]]) {
            [self.searchResults addObject:regDict];
            continue;
        }
        testString = [[regDict objectForKey:kRegPickerJSONIdentifierShortcut] lowercaseString];
        if ([testString hasPrefix:[searchString lowercaseString]]) {
            [self.searchResults addObject:regDict];
            continue;
        }
        NSArray *zipArray = [regDict objectForKey:kRegPickerJSONIdentifierZipCodes];
        for (NSNumber *zip in zipArray) {
            NSString *zipStr = [NSString stringWithFormat:@"%@", zip];
            if ([zipStr hasPrefix:searchString]) {
                [self.searchResults addObject:regDict];
                break;
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.searchResults count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *regDict = [self.searchResults objectAtIndex:indexPath.row];
    
    STRegionPickerSearchTableViewCell *cell = (STRegionPickerSearchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    if (cell == nil) {
        NSArray* topLevelObjects = [self.cellNIB instantiateWithOwner:nil options:0];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.titleTextLabel.text = [regDict objectForKey:kRegPickerJSONIdentifierName];
    cell.shortTextLabel.text = [regDict objectForKey:kRegPickerJSONIdentifierShortcut];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *resDict = [self.searchResults objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(searchFinished:)]) {
        [self.delegate searchFinished:resDict];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - button actions

- (IBAction)cancelButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(searchFinished:)]) {
        [self.delegate searchFinished:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonTapped:(id)sender {

}

#pragma mark - helper



@end
