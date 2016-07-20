//
//  STFahrplanEnteredLocationDisplay.h
//  Stappy2
//
//  Created by Andrej Albrecht on 10.03.16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STFahrplanEnteredLocationDisplayCellTVC;

@protocol STFahrplanEnteredLocationDisplayDelegate
-(void)enteredLocationDisplay:(STFahrplanEnteredLocationDisplayCellTVC*)enteredLocationDisplay nextAction:(id)sender;
-(void)enteredLocationDisplay:(STFahrplanEnteredLocationDisplayCellTVC*)enteredLocationDisplay locationAction:(id)sender;
-(void)enteredLocationDisplay:(STFahrplanEnteredLocationDisplayCellTVC*)enteredLocationDisplay originAction:(id)sender;
-(void)enteredLocationDisplay:(STFahrplanEnteredLocationDisplayCellTVC*)enteredLocationDisplay destinationAction:(id)sender;
@end


@interface STFahrplanEnteredLocationDisplayCellTVC : UITableViewCell
@property(nonatomic,strong)id<STFahrplanEnteredLocationDisplayDelegate> delegate;
@end
