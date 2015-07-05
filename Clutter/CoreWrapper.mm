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

-(id)initWithCallback: (void(^)(void))callback {
    self = [super init];
    _watcher = new Watcher("/Users/Andy/Downloads/", ^(Event e, file f){
            callback();
        });
    
    return self;
}

-(NSInteger) count {
    return _watcher->count();
}

-(void) loop {
    _watcher->loop();
}

-(NSArray*) listFiles {
    std::vector<file>* list = _watcher->listFiles();
    NSMutableArray* convertedList = [[NSMutableArray alloc] init];
    
    for (auto it = list->begin(); it != list->end(); it++) {
        NSString* name = [NSString stringWithUTF8String:it->fileName.c_str()];
        NSArray* fields = [NSArray arrayWithObjects: name, nil];
        [convertedList addObject:fields];
    }
    
    //delete list;
    return convertedList;
}


@end
