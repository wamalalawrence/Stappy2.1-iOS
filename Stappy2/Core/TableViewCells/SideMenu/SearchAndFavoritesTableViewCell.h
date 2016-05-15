//
//  SearchAndFavoritesTableViewCell.h
//  Schwedt
//
//  Created by Andrei Neag on 11.02.2016.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STMainModel;

@interface SearchAndFavoritesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic)STMainModel *mainModelObject;

@end
