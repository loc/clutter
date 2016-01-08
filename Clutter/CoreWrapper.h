//
//  CoreWrapper.h
//  Clutter
//
//  Created by Andy Locascio on 6/29/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "event.h"

@protocol ClutterClient <NSObject>
- (void) newFile: (NSURL*) path;
- (void) renamedFile: (NSURL*) oldPath toNewPath: (NSURL*)newPath;
@optional
- (void) modifiedFile: (NSURL*) path;
- (void) expirationChangedForFile:(NSURL*)url;
- (void) expiredFile:(NSDictionary*)info;
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
-(void)loop;
-(NSInteger) count;
-(void) moveFile:(NSURL*) file toFolder: (NSURL*) folder withName: (NSString*) name;
-(void) keepFile:(NSURL*) file forDays: (int) days withName: (NSString*) name;

+ (NSString*) getDisplayName: (NSString*) name;
+ (NSString*) timeLeftWords:(NSDate*) expiration;
+ (NSString*) truncFileName:(NSString*)fileName withLength:(unsigned int)chars;

@end




