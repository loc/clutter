//
//  CLPreviewController.m
//  Clutter
//
//  Created by Andy Locascio on 9/12/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLPreviewController.h"
@import QuickLook;

@interface CLPreviewController ()

@end

@implementation CLPreviewController

- (id) init {
    self = [super initWithNibName:@"Preview" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self thumbnailView] setWantsLayer:YES];
    
    // Do view setup here.
}

-(void) filesSelected:(NSArray*) files {
    NSLog(@"%@", files);
    [_name setStringValue:[[[files firstObject] objectForKey:@"url"] lastPathComponent]];
    NSUInteger othersCount = [files count] - 1;
    
    [self renderPreviewFor:[[files firstObject] objectForKey:@"url"]];
    
    if (othersCount > 0) {
        NSString * otherOrOthers = othersCount > 1 ? @"others" : @"other";
        [_name setStringValue:[NSString stringWithFormat:@"%@ & %d %@", [_name stringValue], othersCount, otherOrOthers]];
    }
}

-(void) renderPreviewFor:(NSURL*) fileUrl {
    
    NSSize imgSize = CGSizeMake(115, 95);
    NSImage * thumbnailImage;
    CGImageRef thumbRef = QLThumbnailImageCreate(kCFAllocatorDefault, (__bridge CFURLRef)(fileUrl), imgSize, nil);
    if (thumbRef) {
        thumbnailImage = [[NSImage alloc] initWithCGImage:thumbRef size:NSZeroSize];
    } else {
        thumbnailImage = [[NSWorkspace sharedWorkspace] iconForFile: [fileUrl path]];
        [thumbnailImage setSize:CGSizeMake(95, 95)];
    }
    
    NSShadow * shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:4.0f];
    [shadow setShadowColor:[NSColor blackColor]];
    
    [_thumbnailView setShadow:shadow];
    
    [[self thumbnailView] setImage:thumbnailImage];
}

@end
