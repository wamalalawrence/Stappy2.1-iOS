//
//  STAdressSearchResultCellTVC.h
//  Stappy2
//
//  Created by Andrej Albrecht on 20.01.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STFahrplanLocation;

@interface STAdressSearchResultCellTVC : UITableViewCell

@property(strong,nonatomic) STFahrplanLocation *location;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
