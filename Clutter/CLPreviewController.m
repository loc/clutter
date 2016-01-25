//
//  CLPreviewController.m
//  Clutter
//
//  Created by Andy Locascio on 9/12/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLPreviewController.h"
#import "constants.h"
#import "AppDelegate.h"
@import QuickLook;
@import Quartz;

@interface CLPreviewController ()

@end

@interface CLFile (QLPreviewItem) <QLPreviewItem>

@end

@implementation CLPreviewController

NSString * const CLTextFieldDidBecomeFirstResponder = @"CLTextFieldDidBecomeFirstResponder";

- (id) init {
    self = [super initWithNibName:@"Preview" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self thumbnailView] setWantsLayer:YES];
    [_name setFocusRingType:NSFocusRingTypeNone];
    
    _checkbox = [[CLSimpleCheckbox alloc] initWithFrame:NSMakeRect(28, 50, 280, 25)];
    [_checkbox setButtonType:NSSwitchButton];
    [_checkbox setTitle:@"Remember for the next hour"];
//    [self.view addSubview:_checkbox];
    
//    [self.name ]
    [[NSNotificationCenter defaultCenter] addObserverForName:CLTextFieldDidBecomeFirstResponder
                                                      object:self.file
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      
                                                      NSTextField *textField = [note object];
                                                      [textField setAttributedStringValue:[self styleNameText:self.currentText andTruncate:NO]];
                                                      
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CLNotificationPreviewToggle object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        if ([[QLPreviewPanel sharedPreviewPanel] isVisible]) {
            [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
        } else {
            [[QLPreviewPanel sharedPreviewPanel] updateController];
            [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
        }
    }];
    
    // Do view setup here.
}



-(void) filesSelected:(NSArray*) files {
    NSLog(@"%@", files);
    self.file = (CLFile*)[files firstObject];
    
    if (self.previewPanel) {
        [self.previewPanel reloadData];
    }
    
    self.originalText = self.currentText = self.file.displayName;
    [_name setAttributedStringValue:[self styleNameText:self.file.displayName andTruncate:YES]];
    [_name setToolTip:self.file.name];
    
    [self renderPreviewFor:self.file];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    if (!textField.editable) return;
    NSLog(@"%@", [textField stringValue]);
    [textField setAttributedStringValue:[self styleNameText:[textField stringValue] andTruncate:NO]];
}
- (void)controlTextDidEndEditing:(NSNotification *)obj {
    NSTextField *textField = [obj object];
    if (!textField.editable) return;
    
    [textField setBackgroundColor:[NSColor clearColor]];
    
    if ([[textField stringValue] length] > 0) {
        if (![[textField stringValue] isEqualToString:self.currentText]) {
            self.currentText = [textField stringValue];
        }
        
        [self.confirmDelegate shouldUpdateConfirm];
    }
    
    [textField setAttributedStringValue:[self styleNameText:self.currentText andTruncate:YES]];
}
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertTab:) || commandSelector == @selector(insertNewline:)) {
        [textView setSelectedRange:NSMakeRange([[textView string] length],0)];
        [[NSApp keyWindow] makeFirstResponder:[textView superview]];
        return YES;
    }
    return NO;
}

- (BOOL) hasUserChangedFileName {
    return ![self.currentText isEqualToString:self.file.displayName];
}

- (NSAttributedString*) styleNameText: (NSString*)fileName andTruncate: (bool)shouldTrunc  {
    NSString* name;
    if (shouldTrunc) {
        name = [self.file truncName:fileName forChars:23];
    } else {
        name = fileName;
    }
    
    NSUInteger fileExtensionIndex = ([name rangeOfString:@"." options:NSBackwardsSearch]).location;
    NSFont * SeravekExtraLight = [NSFont fontWithName:@"Seravek-ExtraLight" size:24.0];
    NSFont * SeravekRegular = [NSFont fontWithName:@"Seravek" size:24.0];
    NSDictionary * fontAttrs = [NSDictionary dictionaryWithObjects:@[@1, SeravekExtraLight, [NSColor clMainText]]
                                                           forKeys:@[NSKernAttributeName, NSFontAttributeName, NSForegroundColorAttributeName ]];
    NSMutableAttributedString * nameStyledString = [[NSMutableAttributedString alloc] initWithString:name attributes:fontAttrs];
    
    NSRange highlightRange;
    
    
    if (fileExtensionIndex == NSNotFound) {
        fileExtensionIndex = [name length];
    }
    
    if (![fileName isEqualToString:name]) {
        // if the string was truncated
        highlightRange = NSMakeRange(0, fileExtensionIndex - 2);
    } else {
        highlightRange = NSMakeRange(0, fileExtensionIndex);
    }
    
    [nameStyledString beginEditing];
    [nameStyledString addAttribute:NSFontAttributeName value:SeravekRegular range:highlightRange];
    [nameStyledString endEditing];
    
    return nameStyledString;
}

-(void) renderPreviewFor:(CLFile*) file {
    
    [[self thumbnailView] setImage:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSSize imgSize = CGSizeMake(136, 136);
        NSImage * thumbnailImage;
        CGImageRef thumbRef = QLThumbnailImageCreate(kCFAllocatorDefault, (__bridge CFURLRef)([file resolvedURL]), imgSize, nil);
        if (thumbRef) {
            thumbnailImage = [[NSImage alloc] initWithCGImage:thumbRef size:NSZeroSize];
        } else {
            thumbnailImage = [[NSWorkspace sharedWorkspace] iconForFile: [[file resolvedURL] path]];
            [thumbnailImage setSize:CGSizeMake(136, 136)];
        }
        
        NSShadow * shadow = [[NSShadow alloc] init];
        [shadow setShadowBlurRadius:3.0f];
        [shadow setShadowColor:[NSColor clRGBA(0,0,0,.4)]];
        
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [_thumbnailView setShadow:shadow];
            [[self thumbnailView] setImage:thumbnailImage];
        });
        CGImageRelease(thumbRef);
    });
    
}

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
    return 1;
}


- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
    return self.file.url;
}

- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id<QLPreviewItem>)item {
    NSRect windowRelative = [self.view convertRect:self.thumbnailView.frame fromView:nil];
    AppDelegate* delegate = (AppDelegate*)[NSApp delegate];
//    return r windowRelative;
    return [delegate.window convertRectToScreen:windowRelative];
}

- (id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id<QLPreviewItem>)item contentRect:(NSRect *)contentRect {
    return self.thumbnailView.image;
}

//- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
//    return YES;
//}
//
//- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel {
//    [[QLPreviewPanel sharedPreviewPanel] setDelegate:self];
//    [[QLPreviewPanel sharedPreviewPanel] setDataSource:self];
//}
//
//- (void)endPreviewPanelControl:(QLPreviewPanel *)panel {
//    
//}

@end

@implementation CLTextField
- (void) awakeFromNib {
    NSTrackingArea * area = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:area];
}
- (void)mouseEntered:(NSEvent *)theEvent {
    if (!self.editable) return;
    [self setBackgroundColor:[NSColor clRGBA(255,255,255,.15)]];
}
- (void)mouseExited:(NSEvent *)theEvent {
    if (!self.editable) return;
    NSResponder * firstResponder = [[NSApp keyWindow] firstResponder];
    BOOL isFieldSelected = [(id)firstResponder delegate] == self;
    double opacity = isFieldSelected ? 0.3 : 0.0;
    [self setBackgroundColor:[NSColor clRGBA(255,255,255,opacity)]];
}

- (BOOL) becomeFirstResponder {
    if (!self.editable) return NO;
    [self setBackgroundColor:[NSColor clRGBA(255,255,255,.3)]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLTextFieldDidBecomeFirstResponder object:self];
    
    return YES;
}

@end
