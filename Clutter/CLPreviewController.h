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
#import "CLFile.h"

extern NSString * const CLTextFieldDidBecomeFirstResponder;

@protocol CLConfirmController <NSObject>
- (void) shouldUpdateConfirm;
@end

@interface CLPreviewController : NSViewController <NSTextFieldDelegate>

@property IBOutlet NSImageView * thumbnailView;
@property IBOutlet NSTextField * name;
@property IBOutlet CLFile * file;
@property IBOutlet NSString * originalText;
@property IBOutlet NSString * currentText;
@property CLSimpleCheckbox* checkbox;
@property id<CLConfirmController> confirmDelegate;
@property () BOOL allowFileNameEditing;

-(void) filesSelected:(NSArray*) files;
-(void) renderPreviewFor:(CLFile*) fileUrl;
-(BOOL) hasUserChangedFileName;
@end

@interface CLTextField : NSTextField
@end