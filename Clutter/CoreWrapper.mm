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
        for (changeCallback callback in callbacks) {
            callback();
        }
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


@end
