//
//  STDetailActionsDataSource.h
//  Stappy2
//
//  Created by Pavel Nemecek on 22/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface STDetailActionsDataSource : NSObject<UICollectionViewDataSource>

- (id)initWithItems:(NSArray *)items cellIdentifier:(NSString *)cellIdentifier dataModel:(id)dataModel;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
