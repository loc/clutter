//
//  CLDownloadView.m
//  Clutter
//
//  Created by Andy Locascio on 11/7/15.
//  Copyright © 2015 Bubble Tea Apps. All rights reserved.
//

#import "CLDownloadView.h"
#import "CLGenericFlippedView.h"

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
    [_keepActionView setLabels:@[@"1 day", @"2 weeks", @"1 month", @"Forever"] andValues:@[@1, @14, @30, [NSNull null]]];
    
    
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
        
        NSString* fileName = (NSString*)note.object;
        [self updatePanelWithFile:[[[CoreWrapper sharedInstance] url] URLByAppendingPathComponent:fileName]];
        
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
        NSString* newName = [_preview.name.stringValue stringByReplacingOccurrencesOfString:@"/" withString:@""];
        
        if ([_moveActionView isSelected]) {
            NSURL* folder = [_moveActionView getSelectedValue];
            [[CoreWrapper sharedInstance] moveFile:[self activeFile] toFolder:folder withName:newName];
        } else if ([_keepActionView isSelected]) {
            NSNumber* days = [_keepActionView getSelectedValue];
            [[CoreWrapper sharedInstance] keepFile:[self activeFile] forDays:[days unsignedIntegerValue] withName:newName];
            //            NSLog(@"days: %@", days);
        }
        [self setActiveFile:nil];
    }
    
    [(AppDelegate*)[NSApp delegate] togglePanel:NO];
}

// file action methods
- (void)actionChanged:(NSString *)label from:(id)sender {
    if (!label) {
        [_confirmActionView enableButton:NO];
        return;
    }
    if (sender == _moveActionView) {
        [_keepActionView clearSelection];
    } else {
        [_moveActionView clearSelection];
        // _keepActionView
    }
    [_confirmActionView enableButton:YES];
}
- (void) folderPicked:(NSURL *)folder from:(id)sender {
    
}

- (void) updatePanelWithFile: (NSURL*) path {
    NSDictionary * dict = @{
                            @"url": path,
                            @"size": @1
                            };
    [_preview filesSelected: [NSArray arrayWithObject:dict]];
    [self setActiveFile:path];
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] togglePanel:YES];
}

@end
