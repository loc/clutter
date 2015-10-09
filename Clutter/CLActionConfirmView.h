//
//  CLActionConfirmView.h
//  Clutter
//
//  Created by Andy Locascio on 9/27/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CLSimpleButton.h"
#import "constants.h"

@interface CLActionConfirmView : NSView

@property (assign) id delegate;
@property (nonatomic, retain) CLSimpleButton* confirmButton;

- (void) enableButton: (BOOL) shouldEnable;

@end
