//
//  CLDownloadView.m
//  Clutter
//
//  Created by Andy Locascio on 11/7/15.
//  Copyright © 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLDownloadView.h"
#import "CLGenericFlippedView.h"
#import "CLMainController.h"

@interface CLDownloadView ()

@end

@implementation CLDownloadView

- (void)loadView {
    self.view = [[CLGenericFlippedView alloc] init];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _preview = [[CLPreviewController alloc] init];
    [_preview setConfirmDelegate:self];
    _moveActionView = [[CLFileActionView alloc] initWithTitle:@"Move:"];
    [_moveActionView setDelegate:self];
    [_moveActionView setBackgroundColor:[NSColor clRGB(223,225,228)]];
    [_moveActionView setHasFolderPicker:YES];
    
    _keepActionView = [[CLFileActionView alloc] initWithTitle:@"Keep:"];
    [_keepActionView setDelegate:self];
    [_keepActionView setBackgroundColor:[NSColor clRGB(242,242,243)]];
    
    NSArray* folderUrls = [self getDefaultFolders];
    NSMutableArray* folderNames = [[NSMutableArray alloc] initWithCapacity:[folderUrls count]];
    [folderUrls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [folderNames addObject:[(NSURL*) obj lastPathComponent]];
    }];
    
    [_moveActionView setLabels:folderNames andValues:folderUrls];
    [_keepActionView setLabels:@[@"1 day", @"2 weeks", @"1 month", @"Forever"] andValues:@[@1, @14, @30, @-1]];
    
    
    _confirmActionView = [[CLActionConfirmView alloc] init];
    [_confirmActionView setTarget:self];
    [_confirmActionView setAction:@selector(confirmed)];
    
    [self.view addSubview:_preview.view];
    [self.view addSubview:_moveActionView];
    [self.view addSubview:_keepActionView];
    [self.view addSubview:_confirmActionView];
    
    [_moveActionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_confirmActionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_keepActionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_preview.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    // Do view setup here.
    
    NSDictionary* views = @{@"move": _moveActionView,
                            @"keep": _keepActionView,
                            @"confirm": _confirmActionView,
                            @"preview": _preview.view};
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[confirm]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[keep]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[move]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[preview]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[preview][move][keep][confirm(==55)]|" options:0 metrics:nil views:views]];

    [_moveActionView.heightAnchor constraintEqualToAnchor:_keepActionView.heightAnchor].active = YES;
    [_preview.view.heightAnchor constraintEqualToAnchor:_moveActionView.heightAnchor multiplier:1.6].active = YES;
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"activeFileChanged" object:nil queue:nil usingBlock:^(NSNotification *note){
        
        CLFile* file = (CLFile*)note.object;
        [self updatePanelWithFile:file];
        [self.confirmActionView enableButton:NO];
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CLNotificationViewModeChanged object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSString* tableMode = [note object];
        
        if (tableMode == CLViewModeFresh) {
            [_keepActionView setTitle:@"Extend:"];
        } else if (tableMode == CLViewModeExpired) {
            [_keepActionView.titleLabel setStringValue:@"Restore:"];
            [_keepActionView setTitle:@"Restore:"];
        } else {
            [_keepActionView setTitle:@"Keep:"];
        }
    }];
    
//    NSArray* previewWidthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_preview(>=150)][_moveActionView(75)][_keepActionView(75)][_confirmActionView(55)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_preview)];
//    [NSLayoutConstraint activateConstraints:previewWidthConstraints];
}

- (NSArray*) getDefaultFolders {
    NSFileManager* manager = [NSFileManager defaultManager];
    NSInteger directories[] = {NSDocumentDirectory, NSPicturesDirectory, NSDesktopDirectory, NSMusicDirectory};
    NSArray * managerUrls;
    NSMutableArray * folders = [[NSMutableArray alloc] init];
    
    for (int i=0; i < 4; i++) {
        managerUrls = [manager URLsForDirectory:directories[i] inDomains:NSUserDomainMask];
        [folders addObject:[managerUrls firstObject]];
    }
    
    return folders;
}

- (void) confirmed {
    if (self.activeFile == nil) {
        [_moveActionView clearSelection];
        [_keepActionView clearSelection];
    }
    else {
        // TODO: better validation?
        NSString* newName = [_preview.currentText stringByReplacingOccurrencesOfString:@"/" withString:@""];
        
        if ([_moveActionView isSelected]) {
            NSURL* folder = [_moveActionView getSelectedValue];
            [[CoreWrapper sharedInstance] moveFile:self.activeFile toFolder:folder withName:newName];
        } else if ([_keepActionView isSelected]) {
            NSNumber* days = [_keepActionView getSelectedValue];
            
            // hopefully there's a better way!
            AppDelegate* delegate = (AppDelegate*)[NSApp delegate];
            CLMainController* mainController = (CLMainController*)delegate.controller;
            if (mainController.viewMode == CLViewModeUnsorted) {
                [[CoreWrapper sharedInstance] keepFile:self.activeFile forDays:[days unsignedIntegerValue] withName:newName];
            } else if (mainController.viewMode == CLViewModeFresh) {
                [[CoreWrapper sharedInstance] extendFile:self.activeFile forDays:[days unsignedIntegerValue] withName:newName];
            } else if (mainController.viewMode == CLViewModeExpired) {
                [[CoreWrapper sharedInstance] restoreFile:self.activeFile forDays:[days unsignedIntegerValue]];
            }
            
            
            //            NSLog(@"days: %@", days);
        } else {
            [[CoreWrapper sharedInstance] renameFile:self.activeFile toName:newName];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CLNotificationConfirmClicked object:self.activeFile];
    }
}

- (void) shouldUpdateConfirm {
    [self.confirmActionView enableButton:[self.keepActionView isSelected] || [self.moveActionView isSelected] || [self.preview hasUserChangedFileName]];
}

// file action methods
- (void)actionChanged:(NSString *)label from:(id)sender {
    if (sender == _moveActionView) {
        [_keepActionView clearSelection];
    } else {
        [_moveActionView clearSelection];
    }
    [self shouldUpdateConfirm];
}
- (void) folderPicked:(NSURL *)folder from:(id)sender {
    
}

- (void) updatePanelWithFile: (CLFile*) file {
    [_preview filesSelected: [NSArray arrayWithObject:file]];
    [_moveActionView clearSelection];
    [_keepActionView clearSelection];
    [self setActiveFile:file];
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] togglePanel:YES];
}

@end
