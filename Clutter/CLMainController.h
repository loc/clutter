//
//  CLMainController.h
//  Clutter
//
//  Created by Andy Locascio on 9/3/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CoreWrapper.h"
#import "CLDownloadView.h"
#import "CLExpiringView.h"
#import "CLSegmentedControl.h"
#import "CLFile.h"

extern NSString* const CLViewModeUnsorted;
extern NSString* const CLViewModeFresh;
extern NSString* const CLViewModeExpired;
extern NSString* const CLViewModeAll;

extern NSString* const CLNotificationViewModeChanged;
extern NSString* const CLNotificationPreviewToggle;


@interface CLMainController : NSWindowController <NSTableViewDataSource,NSTableViewDelegate,ClutterClient,CLConfirmController,  NSUserNotificationCenterDelegate> {
    IBOutlet NSSegmentedControl * tabSwitcher;
    IBOutlet NSTableView * tableView;
    dispatch_source_t expirationDebounceSource;
}

// cache the files from the coreWrapper
@property NSArray * filesList;

@property NSArray* filesAdded;
@property NSArray* filesExpiredQueue;

@property (nonatomic) NSString* viewMode;


//- (id)initWithWindow:(CLPanel *)window;

@property (strong) CLDownloadView* downloadView;
@property (strong) CLSegmentedControl* viewModeControl;
@property (strong) CLExpiringView* expiringView;

@end

@interface CLDarkScroller : NSScroller
@end