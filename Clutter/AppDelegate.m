//
//  AppDelegate.m
//  Clutter
//
//  Created by Andy Locascio on 6/28/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "CLMainController.h"

@implementation AppDelegate

- (void) awakeFromNib {

}
- (void) applicationDidFinishLaunching:(NSNotification *)notification  {
    controller = [[CLMainController alloc] init];
    [controller showWindow:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [[CoreWrapper sharedInstance] loop];
    });
}

//- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
//{
//    if ([[aTableColumn identifier] isEqual:@"Name"]) {
//        [aCell setBackgroundColor: [NSColor yellowColor]];
//        [aCell setDrawsBackground:YES];
//    }
//}



@end
