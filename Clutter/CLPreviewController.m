//
//  CLPreviewController.m
//  Clutter
//
//  Created by Andy Locascio on 9/12/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLPreviewController.h"
#import "constants.h"
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
    [_name setFocusRingType:NSFocusRingTypeNone];
    
    // Do view setup here.
}

-(void) filesSelected:(NSArray*) files {
    NSLog(@"%@", files);
    NSString * fileName = [[[files firstObject] objectForKey:@"url"] lastPathComponent];

    [_name setAttributedStringValue:[self styleNameText:fileName]];
    
    [self renderPreviewFor:[[files firstObject] objectForKey:@"url"]];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSLog(@"%@", [textField stringValue]);
    [textField setAttributedStringValue:[self styleNameText:[textField stringValue]]];
}
- (void)controlTextDidEndEditing:(NSNotification *)obj {
    NSTextField *textField = [obj object];
    [textField setBackgroundColor:[NSColor clearColor]];
}
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertTab:) || commandSelector == @selector(insertNewline:)) {
        [textView setSelectedRange:NSMakeRange([[textView string] length],0)];
        [[NSApp keyWindow] makeFirstResponder:[textView superview]];
        return YES;
    }
    return NO;
}

- (NSAttributedString*) styleNameText: (NSString*)name {
    NSUInteger fileExtensionIndex = ([name rangeOfString:@"." options:NSBackwardsSearch]).location;
    NSFont * SeravekExtraLight = [NSFont fontWithName:@"Seravek-ExtraLight" size:24.0];
    NSFont * SeravekRegular = [NSFont fontWithName:@"Seravek" size:24.0];
    NSDictionary * fontAttrs = [NSDictionary dictionaryWithObjects:@[@1, SeravekExtraLight, [NSColor clMainText]]
                                                           forKeys:@[NSKernAttributeName, NSFontAttributeName, NSForegroundColorAttributeName ]];
    NSMutableAttributedString * nameStyledString = [[NSMutableAttributedString alloc] initWithString:name attributes:fontAttrs];
    
    if (fileExtensionIndex == NSNotFound) {
        fileExtensionIndex = [name length];
    }
    
    [nameStyledString beginEditing];
    [nameStyledString addAttribute:NSFontAttributeName value:SeravekRegular range:NSMakeRange(0, fileExtensionIndex)];
    [nameStyledString endEditing];
    
    return nameStyledString;
}

-(void) renderPreviewFor:(NSURL*) fileUrl {
    
    NSSize imgSize = CGSizeMake(136, 136);
    NSImage * thumbnailImage;
    CGImageRef thumbRef = QLThumbnailImageCreate(kCFAllocatorDefault, (__bridge CFURLRef)(fileUrl), imgSize, nil);
    if (thumbRef) {
        thumbnailImage = [[NSImage alloc] initWithCGImage:thumbRef size:NSZeroSize];
    } else {
        thumbnailImage = [[NSWorkspace sharedWorkspace] iconForFile: [fileUrl path]];
        [thumbnailImage setSize:CGSizeMake(136, 136)];
    }
    
    NSShadow * shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:3.0f];
    [shadow setShadowColor:[NSColor clRGBA(0,0,0,.4)]];
    
    [_thumbnailView setShadow:shadow];
    
    [[self thumbnailView] setImage:thumbnailImage];
}

@end

@implementation CLTextField
- (void) awakeFromNib {
    NSTrackingArea * area = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:area];
}
- (void)mouseEntered:(NSEvent *)theEvent {
    [self setBackgroundColor:[NSColor clRGBA(255,255,255,.15)]];
}
- (void)mouseExited:(NSEvent *)theEvent {
    NSResponder * firstResponder = [[NSApp keyWindow] firstResponder];
    BOOL isFieldSelected = [(id)firstResponder delegate] == self;
    double opacity = isFieldSelected ? 0.3 : 0.0;
    [self setBackgroundColor:[NSColor clRGBA(255,255,255,opacity)]];
}

- (BOOL) becomeFirstResponder {
    [self setBackgroundColor:[NSColor clRGBA(255,255,255,.3)]];
    return YES;
}

@end
