//
//  CLFile.h
//  Obj-C equivalent of the file c++ class in the core
//
//  Created by Andy Locascio on 1/10/16.
//  Copyright © 2016 Bubble Tea Apps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CLFile : NSObject

@property long inode;
@property unsigned long long size;
@property (strong) NSDate* expiration;
@property (strong) NSDate* lastModified;
@property (strong) NSString* downloadURL;
@property (strong, nonatomic, setter=setURL:) NSURL* url;
@property (strong, nonatomic) NSURL* previousURL;
@property (strong, nonatomic, readonly) NSString* name;
@property (strong, nonatomic, readonly) NSString* displayName;
@property (strong, nonatomic, readonly) NSString* previousName;
@property (strong, nonatomic, readonly) NSURL* archiveURL;
@property (strong, readonly) NSString* archiveName;
@property (getter=isArchived) BOOL archived;

@property (strong) NSImage* thumbnail;

- (void) generateThumbnail;
- (NSString*) truncName:(unsigned int)chars;
- (NSString*) truncName:(NSString*)name forChars:(unsigned int)chars;
- (NSURL*) resolvedURL;

@end