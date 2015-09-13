//
//  CLPreviewController.h
//  Clutter
//
//  Created by Andy Locascio on 9/12/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CLPreviewController : NSViewController

@property IBOutlet NSImageView * thumbnailView;
@property IBOutlet NSTextField * name;

-(void) filesSelected:(NSArray*) files;
-(void) renderPreviewFor:(NSURL*) fileUrl;
@end
