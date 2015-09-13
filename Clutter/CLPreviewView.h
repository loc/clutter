//
//  CLPreviewView.h
//  Clutter
//
//  Created by Andy Locascio on 8/29/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CoreWrapper.h"

@interface CLPreviewView : NSView

- (void) renderPreviewFor:(NSURL*) file;

@end
