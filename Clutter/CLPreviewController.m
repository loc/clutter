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
    [self.view addSubview:_checkbox];
    
//    [self.name ]
    [[NSNotificationCenter defaultCenter] addObserverForName:CLTextFieldDidBecomeFirstResponder
                                                      object:self.name
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      
                                                      NSTextField *textField = [note object];
                                                      [textField setAttributedStringValue:[self styleNameText:self.fileName andTruncate:NO]];
                                                      
                                                  }];
    
    // Do view setup here.
}

-(void) filesSelected:(NSArray*) files {
    NSLog(@"%@", files);
    NSString * fileName = [[[files firstObject] objectForKey:@"url"] lastPathComponent];
    
    self.fileName = [[CoreWrapper class] getDisplayName:fileName];
    [_name setAttributedStringValue:[self styleNameText:self.fileName andTruncate:YES]];
    [_name setToolTip:self.fileName];
    
    [self renderPreviewFor:[[files firstObject] objectForKey:@"url"]];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSLog(@"%@", [textField stringValue]);
    [textField setAttributedStringValue:[self styleNameText:[textField stringValue] andTruncate:NO]];
}
- (void)controlTextDidEndEditing:(NSNotification *)obj {
    NSTextField *textField = [obj object];
    [textField setBackgroundColor:[NSColor clearColor]];
    [textField setAttributedStringValue:[self styleNameText:[textField stringValue] andTruncate:YES]];
}
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertTab:) || commandSelector == @selector(insertNewline:)) {
        [textView setSelectedRange:NSMakeRange([[textView string] length],0)];
        [[NSApp keyWindow] makeFirstResponder:[textView superview]];
        return YES;
    }
    return NO;
}

- (NSAttributedString*) styleNameText: (NSString*)fileName andTruncate: (bool)shouldTrunc  {
    NSString* name;
    if (shouldTrunc) {
        name = [CoreWrapper truncFileName:fileName withLength:20];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLTextFieldDidBecomeFirstResponder object:self];
    
    return YES;
}

@end
