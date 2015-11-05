//
//  FinderSync.m
//  FinderExtension
//
//  Created by Andy Locascio on 10/25/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "FinderSync.h"

@interface FinderSync ()

@property NSURL *myFolderURL;

@end

CFDataRef messageReceived(CFMessagePortRef port,
                    SInt32 messageID,
                    CFDataRef data,
                    void *info) {
    FinderSync* finderSync = (__bridge FinderSync*)info;
    
    if (messageID == CLRefreshExpirationMessageType) {
        NSString* fileName = (NSString*)CFBridgingRelease(CFStringCreateFromExternalRepresentation(nil, data, kCFStringEncodingUTF8));
        NSURL* url = [NSURL fileURLWithPath:[[[finderSync myFolderURL] URLByAppendingPathComponent:fileName] path]];
        [finderSync requestBadgeIdentifierForURL:url];
    }
    
    return nil;
};

@implementation FinderSync

- (instancetype)init {
    self = [super init];

    NSLog(@"%s launched from %@ ; compiled at %s", __PRETTY_FUNCTION__, [[NSBundle mainBundle] bundlePath], __TIME__);
    
    NSString* localPort = [@"com.bubble.tea.Clutter." stringByAppendingString:[[NSProcessInfo processInfo] globallyUniqueString]];
    
    _urls = [[NSMutableDictionary alloc] init];
    
    CFMessagePortContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    _sendPort = CFMessagePortCreateRemote(nil, CFSTR("com.bubble.tea.Clutter.ToMain"));
    _recvPort = CFMessagePortCreateLocal(nil, (CFStringRef)localPort, messageReceived, &context, nil);
    
    if (_recvPort && !_recvRunLoopSource) {
        _recvRunLoopSource = CFMessagePortCreateRunLoopSource(nil, _recvPort, 0);
        CFRunLoopAddSource(CFRunLoopGetCurrent(),
                           _recvRunLoopSource,
                           kCFRunLoopCommonModes);
        CFDataRef data = (__bridge CFDataRef)[(NSString*)CFMessagePortGetName(_recvPort) dataUsingEncoding:NSUTF8StringEncoding];
        CFMessagePortSendRequest(_sendPort, CLListeningAtPortMessageType, data, 3, 3, nil, nil);
    }

    CFDataRef nilData = CFDataCreate(nil, nil, 0);
    CFDataRef returnData;
    CFMessagePortSendRequest(_sendPort, CLRequestDirectoryMessageType, nilData, 3, 3, kCFRunLoopDefaultMode, &returnData);
//    NSString* directory = (NSString*)CFBridgingRelease(CFStringCreateFromExternalRepresentation(nil, returnData, NSUTF8StringEncoding));
    NSString* directory = (__bridge NSString*)CFStringCreateWithBytes(nil, CFDataGetBytePtr(returnData), CFDataGetLength(returnData), kCFStringEncodingUTF8, true);
    
    CFRelease(returnData);
    
    NSLog(@"directory %@", directory);
    
    self.myFolderURL = [NSURL fileURLWithPath:directory isDirectory:YES];
    NSLog(@"%@", self.myFolderURL);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [FIFinderSyncController defaultController].directoryURLs = [NSSet setWithObject:self.myFolderURL];
    });
    
    // Set up images for our badge identifiers. For demonstration purposes, this uses off-the-shelf images.
    [[FIFinderSyncController defaultController] setBadgeImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"green_circle_badge" ofType:@"png"]] label:@"Expires later" forBadgeIdentifier:@"Later"];
    [[FIFinderSyncController defaultController] setBadgeImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"yellow_triangle_badge" ofType:@"png"]] label:@"Expiring soon" forBadgeIdentifier:@"Soon"];
    [[FIFinderSyncController defaultController] setBadgeImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"red_square_badge" ofType:@"png"]] label:@"Expiring today" forBadgeIdentifier:@"Now"];
    
    [NSTimer scheduledTimerWithTimeInterval:60*60 target:self selector:@selector(refreshBadges) userInfo:nil repeats:YES];
    
    return self;
}

- (void) refreshBadges {
    id this = self;
    [_urls enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        [this requestBadgeIdentifierForURL:[NSURL fileURLWithPath:(NSString*)key]];
    }];
}

#pragma mark - Primary Finder Sync protocol methods

- (void)beginObservingDirectoryAtURL:(NSURL *)url {
    // The user is now seeing the container's contents.
    // If they see it in more than one view at a time, we're only told once.
    NSLog(@"beginObservingDirectoryAtURL:%@", url.filePathURL);
    
}

- (void)endObservingDirectoryAtURL:(NSURL *)url {
    // The user is no longer seeing the container's contents.
    NSLog(@"endObservingDirectoryAtURL:%@", url.filePathURL);
    [_urls removeAllObjects];
}

- (BOOL) isFileInMyWatchFolder: (NSURL*) url {
    return [[url.filePathURL URLByDeletingLastPathComponent] isEqual:[self.myFolderURL filePathURL]];
}

- (void)requestBadgeIdentifierForURL:(NSURL *)url {
    
    if (![self isFileInMyWatchFolder:url]) {
        return;
    }
    NSLog(@"requestBadgeIdentifierForURL:%@", url.filePathURL);
    NSString* path = [[url filePathURL] path];
    if ([_urls objectForKey:path] == nil) {
        [_urls setValue:@1 forKey:path];
    }
    
    time_t now = CFAbsoluteTimeGetCurrent();
    NSString* badgeIdentifier = @"";
//    data = CFDataCreate(nil, [[url.path dataUsingEncoding:NSUnicodeStringEncoding] bytes], [url.path lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]);
    
    time_t expiration = [self queryExpirationDate: url.filePathURL];
        
    if (expiration > 0) {
        if (expiration - now < dayInSeconds) {
            badgeIdentifier = @"Now";
        } else if (expiration - now < weekInSeconds) {
            badgeIdentifier = @"Soon";
        } else {
            badgeIdentifier = @"Later";
        }
    }
    if ([badgeIdentifier length]) {
        [[FIFinderSyncController defaultController] setBadgeIdentifier:badgeIdentifier forURL:url];
    }
}

- (long) queryExpirationDate:(NSURL*) url {
    time_t expiration = -1;
    CFDataRef data = (CFDataRef)CFBridgingRetain([url.lastPathComponent dataUsingEncoding:NSUTF8StringEncoding]);
    CFDataRef returnData = [self _queryApp:data forType:CLRequestExpirationMessageType];
    if (CFDataGetLength(returnData)) {
        memcpy(&expiration, CFDataGetBytePtr(returnData), sizeof(time_t));
    }
    
    CFRelease(returnData);
    CFRelease(data);
    return expiration;
}

- (NSString*) queryExpirationDateInWords:(NSURL*) url {
    NSString *words;
    
    CFDataRef data = (CFDataRef)CFBridgingRetain([url.lastPathComponent dataUsingEncoding:NSUTF8StringEncoding]);
    CFDataRef returnData = [self _queryApp:data forType:CLRequestExpirationInWordsMessageType];
    if (returnData != nil && CFDataGetLength(returnData)) {
        words = (NSString*)CFBridgingRelease(CFStringCreateWithBytes(nil, CFDataGetBytePtr(returnData), CFDataGetLength(returnData), kCFStringEncodingUTF8, false));
        CFRelease(returnData);
    }
    
    CFRelease(data);
    return words;
}

- (CFDataRef) _queryApp:(CFDataRef) data forType:(MessageType) messageType {
    CFDataRef returnData;
    CFStringRef loopMode = kCFRunLoopDefaultMode;
    CFDataRef* returnDataPointer = &returnData;
    SInt32 wasOkay = -1;
    
//    if (ReturnTypeForMessageType(messageType) == CLNoReturnType) {
//        returnDataPointer = nil;
//        loopMode = nil;
//    }
    
    if (_sendPort) {
         wasOkay = CFMessagePortSendRequest(_sendPort, messageType, data, 3, 3, loopMode, returnDataPointer);
    }
    if (wasOkay == kCFMessagePortSuccess)
        return returnData;
    else return nil;
}

#pragma mark - Menu and toolbar item support

- (NSMenu *)menuForMenuKind:(FIMenuKind)whichMenu {
    // Produce a menu for the extension.
    
    
    if (whichMenu == FIMenuKindContextualMenuForItems) {
        NSArray* items = [[FIFinderSyncController defaultController] selectedItemURLs];
        NSString* words;
        NSMenu *menu = [[NSMenu alloc] init];
        NSMenu* subMenu = [[NSMenu alloc] init];
        NSString* extensionPhrase = @"Expire in...";
        
        for (NSURL* item in items) {
            if (![self isFileInMyWatchFolder:item]) {
                return nil;
            }
        }
        
        if ([items count] == 1) {
            words = [self queryExpirationDateInWords: [[items firstObject] filePathURL]];
            if ([words length]) {
                extensionPhrase = @"Extend expiration...";
                [menu addItemWithTitle:[@"Expires in: " stringByAppendingString:words] action:nil keyEquivalent:@""];
                [[menu itemAtIndex:0] setEnabled:NO];
            }
        }
        	
        NSMenuItem* extendMenu = [[NSMenuItem alloc] initWithTitle:extensionPhrase action:nil keyEquivalent:@""];
        [[subMenu addItemWithTitle:@"1 day" action:@selector(extend:) keyEquivalent:@""] setTag:1];
        [[subMenu addItemWithTitle:@"2 weeks" action:@selector(extend:) keyEquivalent:@""] setTag:1 * 14];
        [[subMenu addItemWithTitle:@"1 month" action:@selector(extend:) keyEquivalent:@""] setTag:1 * 30];
        [[subMenu addItemWithTitle:@"Forever" action:@selector(extend:) keyEquivalent:@""] setTag:-1];
        
        [menu addItem:extendMenu];
        [menu setSubmenu:subMenu forItem:extendMenu];
        
        return menu;
    }
    
    return nil;
}

- (void) extend:(id) sender {
    long days = [sender tag];
    NSArray* items = [[FIFinderSyncController defaultController] selectedItemURLs];
    
    NSMutableData *data = [NSMutableData dataWithData:[[[items firstObject] lastPathComponent] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendBytes:&days length:sizeof(long)];
    if (_sendPort) {
        CFMessagePortSendRequest(_sendPort, CLExtensionMessageType, (CFDataRef)data, 3, 3, nil, nil);
    }
}

- (void)dealloc {
    NSLog(@"dealloced");
    if (_recvPort && _recvRunLoopSource) {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _recvRunLoopSource, kCFRunLoopCommonModes);
        CFDataRef data = (__bridge CFDataRef)[(NSString*)CFMessagePortGetName(_recvPort) dataUsingEncoding:NSUTF8StringEncoding];
        CFMessagePortSendRequest(_sendPort, CLStoppedListeningAtPortMessageType, data, 3, 3, nil, nil);
        CFRelease(_recvRunLoopSource);
        _recvRunLoopSource = nil;
    }
}

@end

