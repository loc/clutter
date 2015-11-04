//
//  FinderSync.h
//  FinderExtension
//
//  Created by Andy Locascio on 10/25/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FinderSync/FinderSync.h>
#import "event.h"

#define dayInSeconds 24 * 60 * 60
#define dayInMilliseconds dayInSeconds * 1000
#define weekInSeconds dayInSeconds * 7

@interface FinderSync : FIFinderSync

@property (assign) CFMessagePortRef sendPort;
@property (assign) CFMessagePortRef recvPort;
@property (assign) CFRunLoopSourceRef recvRunLoopSource;
@property (strong) NSMutableDictionary* urls;

@end
