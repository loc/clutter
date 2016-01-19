//
//  CLDownloadView.h
//  Clutter
//
//  Created by Andy Locascio on 11/7/15.
//  Copyright © 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "CLTableRowView.h"
#import "CLResizeView.h"
#import "CLPreviewController.h"
#import "CLFileActionView.h"
#import "CLActionConfirmView.h"
#import "CoreWrapper.h"

@interface CLDownloadView : NSViewController <CLFileActionDelegate>

@property (nonatomic, retain) IBOutlet CLPreviewController *preview;
@property (nonatomic, retain) CLFileActionView* moveActionView;
@property (nonatomic, retain) CLFileActionView* keepActionView;
@property (nonatomic, retain) CLActionConfirmView* confirmActionView;
@property (nonatomic, retain) CLFile* activeFile;

@property BOOL isFileActionSelected;

- (void) updatePanelWithFile: (CLFile*) path;

@end


