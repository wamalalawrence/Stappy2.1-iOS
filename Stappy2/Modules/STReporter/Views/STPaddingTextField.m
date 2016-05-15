//
//  STPaddingTextField.m
//  Stappy2
//
//  Created by Pavel Nemecek on 11/05/16.
//  Copyright © 2016 endios GmbH. All rights reserved.
//

#import "STPaddingTextField.h"
#import "STAppSettingsManager.h"
#define kPaddingTextFieldPadding 5.0f

@implementation STPaddingTextField


-(CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, kPaddingTextFieldPadding, kPaddingTextFieldPadding);
}

-(CGRect)editingRectForBounds:(CGRect)bounds{
    return [self textRectForBounds:bounds];
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    // Set to any color of your preference
    UIFont* inputTextFont = [[STAppSettingsManager sharedSettingsManager] customFontForKey:@"reporter.inputText.font"];

    // We use self.font.pointSize in order to match the input text's font size
    
    [self.placeholder drawInRect:rect withAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:inputTextFont}];
    
  }

@end
