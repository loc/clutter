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

@interface CLMainController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, ClutterClient> {
    IBOutlet NSSegmentedControl * tabSwitcher;
    IBOutlet NSTableView * tableView;
}

@property NSArray * filesList;


//- (id)initWithWindow:(CLPanel *)window;

@property (strong) CLDownloadView* downloadView;
@property (strong) CLExpiringView* expiringView;

@end

@interface CLDarkScroller : NSScroller
@end