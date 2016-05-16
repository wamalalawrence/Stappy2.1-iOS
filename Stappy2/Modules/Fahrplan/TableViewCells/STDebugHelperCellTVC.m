//
//  STDebugHelperCellTVC.m
//  Schwedt
//
//  Created by Andrej Albrecht on 03.02.16.
//  Copyright © 2016 Cynthia Codrea. All rights reserved.
//

#import "STDebugHelperCellTVC.h"
#import "STDebugEntry.h"

@interface STDebugHelperCellTVC ()
@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end

@implementation STDebugHelperCellTVC

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDebugEntry:(STDebugEntry *)debugEntry
{
    _debugEntry = debugEntry;
    
    [self.keyLabel setText:debugEntry.key];
    [self.valueLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)[debugEntry.coutner intValue]]];
}


@end
