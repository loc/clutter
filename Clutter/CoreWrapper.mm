//
//  CoreWrapper.m
//  Clutter
//
//  Created by Andy Locascio on 6/29/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CoreWrapper.h"
#import "core.h"
#import "cltime.h"

@interface CoreWrapper ()

@property (nonatomic, assign) Watcher * watcher;

@end

@implementation CoreWrapper

+ (CoreWrapper*)sharedInstance
{
    static CoreWrapper * _sharedInstance;
    @synchronized(self)
    {
        if (!_sharedInstance) {
            _sharedInstance = [[self alloc] init];
        }
        return _sharedInstance;
    }
}

string handleEvents(Event e, file *f) {
    CoreWrapper* wrapper = [CoreWrapper sharedInstance];
    NSString* fileName = [[wrapper class] cStringToNSString:f->fileName];
    NSURL* fileURL = [[wrapper url] URLByAppendingPathComponent:fileName];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (e & created) {
            
            [[wrapper delegate] newFile:fileURL];
        }
        if (e & renamed) {
            [[wrapper delegate] renamedFile:[[wrapper url] URLByAppendingPathComponent:[[wrapper class] cStringToNSString:f->previousName]] toNewPath:fileURL];
        }
        if (e & expirationChanged) {
            [[wrapper delegate] expirationChangedForFile:[wrapper url]];
        }
    });
    
    if (e & removeRequestEvent) {
        // put into application support
        
        NSURL* archiveDirectory = [[wrapper supportURL] URLByAppendingPathComponent:@"Archives" isDirectory:YES];
        [[NSFileManager defaultManager] createDirectoryAtPath:[archiveDirectory path] withIntermediateDirectories:YES attributes:nil error:nil];
        
        if ([[NSFileManager defaultManager] isReadableFileAtPath:[fileURL path]]) {
            NSString* uniqueFileName = [fileName stringByAppendingFormat:@"%llu", f->inode];
            NSURL* newURL = [archiveDirectory URLByAppendingPathComponent:uniqueFileName];
            NSError* error;
            [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:newURL error:&error];
            
            NSString* informativeText = [NSByteCountFormatter stringFromByteCount:f->fileSize countStyle:NSByteCountFormatterCountStyleFile];
            if (f->downloadedFrom.length()) {
                informativeText = [informativeText stringByAppendingFormat:@" - %s", f->downloadedFrom.c_str()];
            }
            
            NSUserNotification* notification = [[NSUserNotification alloc] init];
            [notification setTitle:@"A file has expired"];
            [notification setSubtitle:fileName];
            [notification setInformativeText:informativeText];
            [notification setActionButtonTitle: @"Restore"];
            [notification setOtherButtonTitle: @"Okay"];
            [notification setHasActionButton: YES];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
    }
    
    return "";
}

-(id)init {
    self = [super init];
    callbacks = [[NSMutableArray alloc] init];
    NSArray * urls = [[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask];
    NSLog(@"%@", urls);
    [self setUrl:[urls firstObject]];
    
    NSString* supportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString* execName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"];
    NSURL* mainSupportDir = [NSURL fileURLWithPath:supportPath isDirectory:YES];
    _supportURL = [mainSupportDir URLByAppendingPathComponent:execName isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtPath:[_supportURL path] withIntermediateDirectories:YES attributes:nil error:nil];
    
    _watcher = new Watcher([[[self url] path] cStringUsingEncoding:NSUTF8StringEncoding], [[_supportURL path] cStringUsingEncoding:NSUTF8StringEncoding], handleEvents);
    
    return self;
}

-(NSInteger) count {
    return _watcher->count();
}

-(void) loop {
    _watcher->loop();
}

-(NSArray*) listFiles {
    std::vector<file*>* list = _watcher->listFiles();
    NSMutableArray* convertedList = [[NSMutableArray alloc] init];
    
    for (auto it = list->begin(); it != list->end(); it++) {
        file* f = (file*)*it;
        NSString* name = [NSString stringWithUTF8String:f->fileName.c_str()];
        NSNumber * fileSize = [NSNumber numberWithUnsignedLongLong:f->fileSize];
        id expiration = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:f->expiring];
        if (f->expiring < 0) {
            expiration = [NSNull null];
        }
        
        NSDictionary* fields = NSDictionaryOfVariableBindings(name, fileSize, expiration);
        
        [convertedList addObject:fields];
    }
    
    //delete list;
    return convertedList;
}

-(void) moveFile:(NSURL*) fileURL toFolder: (NSURL*) folder withName: (NSString*) name {
    struct file* f = _watcher->fileFromName([[fileURL lastPathComponent] UTF8String]);
    if (getDisplayName(f->fileName) != [name UTF8String]) {
        _watcher->rename(f, [name UTF8String]);
    }
    
    _watcher->move(f, [[NSString stringWithFormat:@"%@/", [folder path]] UTF8String]);
}

-(void) keepFile:(NSURL*) fileURL forDays: (int) days withName: (NSString*) name {
    struct file* f = _watcher->fileFromName([[fileURL lastPathComponent] UTF8String]);
    if (getDisplayName(f->fileName) != [name UTF8String]) {
        _watcher->rename(f, [name UTF8String]);
    }
    _watcher->keep(f, days);
}

+ (NSString*) cStringToNSString: (string) str {
    return [NSString stringWithUTF8String:str.c_str()];
}

+ (NSString*) getDisplayName: (NSString*) name {
    return [self cStringToNSString:getDisplayName([name UTF8String])];
}

+ (NSString*) timeLeftWords:(NSDate*) expiration {
    string words = timeLeftWords([expiration timeIntervalSinceReferenceDate]);
    return [self cStringToNSString:words];
}

@end

