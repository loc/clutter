//
//  CoreWrapper.m
//  Clutter
//
//  Created by Andy Locascio on 6/29/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import "CoreWrapper.h"
#import "core.h"

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

-(id)init {
    self = [super init];
    callbacks = [[NSMutableArray alloc] init];
    NSArray * urls = [[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask];
    NSLog(@"%@", urls);
    [self setUrl: [urls firstObject]];
    _watcher = new Watcher([[[self url] path] cStringUsingEncoding:NSUTF8StringEncoding], ^(Event e, file f){
        NSString* fileName = [[self class] cStringToNSString:f.fileName];
        NSURL* path = [[self url] URLByAppendingPathComponent:fileName];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (e & created) {
                
                [_delegate newFile:path];
            }
            if (e & renamed) {
                [_delegate renamedFile:[[self url] URLByAppendingPathComponent:[[self class] cStringToNSString:f.previousName]] toNewPath:path];
            }
        });
//        for (changeCallback callback in callbacks) {
//            callback();
//        }
    });
    
    return self;
}



-(void) runBlockOnChange: (changeCallback) callback {
    [callbacks addObject:callback];
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
        NSString* name = [NSString stringWithUTF8String:(*it)->fileName.c_str()];
        NSNumber * fileSize = [NSNumber numberWithUnsignedLongLong:(*it)->fileSize];
        NSArray* fields = [NSArray arrayWithObjects: name, fileSize, nil];
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

@end

