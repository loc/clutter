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

@interface CLFile (CLFileAdditions)

- (instancetype) initWithCoreFile: (file*) f;

@end

@implementation CLFile (CLFileAdditions)

- (instancetype) initWithCoreFile: (file*) f {
    self = [super init];
    self.inode = f->inode;
    self.expiration = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:f->expiring];
    self.size = f->fileSize;
    self.url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:(f->path + f->fileName).c_str()]];
    self.lastModified = [[NSDate alloc] initWithTimeIntervalSince1970:f->last_modification];
    if (f->expiring < 0) {
        self.expiration = NULL;
    }
    
    return self;
}

@end



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
    CLFile* file = [[CLFile alloc] initWithCoreFile:f];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (e & created) {
            
            [[wrapper delegate] newFile:file];
        }
        if (e & renamed) {
            [[wrapper delegate] renamedFile:file];
        }
        if (e & expirationChanged) {
            // maybe we don't need this if we just refresh on every open?
//            [[wrapper delegate] expirationChangedForFile:[wrapper url]];
        }
        if (e & restored) {
            
        }
    });
    
    if (e & expired) {
        // put into application support

        [[wrapper delegate] expiredFile:file];
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
    return [self convertFilesVectorToArray:list];
}

-(NSArray*) listArchives {
    std::vector<file*>* list = _watcher->listArchives();
    NSArray* archiveList = [self convertFilesVectorToArray:list];
    
    [archiveList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [(CLFile*)obj setArchived:YES];
    }];
    
    return archiveList;
}

-(NSArray*) convertFilesVectorToArray: (std::vector<file*>*) list {
    NSMutableArray* convertedList = [[NSMutableArray alloc] init];
    
    for (auto it = list->begin(); it != list->end(); it++) {
        file* f = (file*)*it;
        CLFile* file = [[CLFile alloc] initWithCoreFile:f];
        [convertedList addObject:file];
    }
    
    delete list;
    return convertedList;
}



-(void) moveFile:(CLFile*) file toFolder: (NSURL*) folder withName: (NSString*) name {
    struct file* f = _watcher->fileFromName([file.name UTF8String]);
    if (getDisplayName(f->fileName) != [name UTF8String]) {
        _watcher->rename(f, [name UTF8String]);
    }
    
    _watcher->move(f, [[NSString stringWithFormat:@"%@/", [folder path]] UTF8String]);
}

-(void) keepFile:(CLFile*) file forDays: (int) days withName: (NSString*) name {
    struct file* f = _watcher->fileFromName([file.name UTF8String]);
    if (getDisplayName(f->fileName) != [name UTF8String]) {
        _watcher->rename(f, [name UTF8String]);
    }
    _watcher->keep(f, days);
}

-(void) extendFile:(CLFile*) file forDays: (int) days withName: (NSString*) name {
    struct file* f = _watcher->fileFromName([file.name UTF8String]);
    if (getDisplayName(f->fileName) != [name UTF8String]) {
        _watcher->rename(f, [name UTF8String]);
    }
    _watcher->extend(f, days);
}

-(void) expireFile:(CLFile*) file {
    struct file* f = _watcher->fileFromName([file.name UTF8String]);
    _watcher->expire(f);
}

-(void) restoreFile:(CLFile*) file forDays: (int) days {
    struct file* f = _watcher->archiveFromInode(file.inode);
    _watcher->restore(f, days);
}

-(void) renameFile:(CLFile*) file toName: (NSString*) name {
    struct file* f = _watcher->fileFromName([file.name UTF8String]);
    if (getDisplayName(f->fileName) != [name UTF8String]) {
        _watcher->rename(f, [name UTF8String]);
    }
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

+ (NSString*) timeSinceDaysWords:(NSDate*) expiration {
    string words = timeSinceDaysWords([expiration timeIntervalSinceReferenceDate]);
    return [self cStringToNSString:words];
}

@end

