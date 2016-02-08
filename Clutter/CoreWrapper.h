//
//  CoreWrapper.h
//  Clutter
//
//  Created by Andy Locascio on 6/29/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "event.h"
#import "CLFile.h"

extern NSString* const CLNotificationPreviewToggle;

@protocol ClutterClient <NSObject>
- (void) newFile: (CLFile*) file;
- (void) renamedFile: (CLFile*) file;
@optional
- (void) modifiedFile: (CLFile*) file;
- (void) expirationChangedForFile:(CLFile*)file;
- (void) expiredFile:(CLFile*)file;
@end

typedef void(^changeCallback)();

@interface CoreWrapper : NSObject {
    NSMutableArray* callbacks;
}

@property (retain) NSURL* url;
@property (strong) NSURL* supportURL;
@property (nonatomic, strong) id <ClutterClient> delegate;

+ (CoreWrapper*)sharedInstance;
-(void) runBlockOnChange: (changeCallback) callback;
-(NSArray*) listFiles;
-(NSArray*) listArchives;
-(void)loop;
-(NSInteger) count;
-(void) moveFile:(CLFile*) file toFolder: (NSURL*) folder withName: (NSString*) name;
-(void) keepFile:(CLFile*) file forDays: (int) days withName: (NSString*) name;
-(void) extendFile:(CLFile*) file forDays: (int) days withName: (NSString*) name;
-(void) restoreFile:(CLFile*) file forDays: (int) days;
-(void) renameFile:(CLFile*) file toName: (NSString*) name;

+ (NSString*) getDisplayName: (NSString*) name;
+ (NSString*) timeLeftWords:(NSDate*) expiration;
+ (NSString*) timeSinceDaysWords:(NSDate*) expiration;
- (bool) analyticsEventWithCategory: (NSString*)category andAction:(NSString*) action;
- (bool) analyticsEventWithCategory: (NSString*)category andAction:(NSString*) action andLabel:(NSString*) label;
- (bool) analyticsEndTimer:(NSString*)category forEvent:(NSString*)name andLabel: (NSString*) label;
- (bool) analyticsStartTimer:(NSString*)category forEvent:(NSString*)name;
@end