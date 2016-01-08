//
//  CLPreviewController.h
//  Clutter
//
//  Created by Andy Locascio on 9/12/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CLSimpleCheckbox.h"
#import "CoreWrapper.h"

extern NSString * const CLTextFieldDidBecomeFirstResponder;

@interface CLPreviewController : NSViewController <NSTextFieldDelegate>

@property IBOutlet NSImageView * thumbnailView;
@property IBOutlet NSTextField * name;
@property IBOutlet NSString * fileName;
@property CLSimpleCheckbox* checkbox;

-(void) filesSelected:(NSArray*) files;
-(void) renderPreviewFor:(NSURL*) fileUrl;
@end

@interface CLTextField : NSTextField
@end