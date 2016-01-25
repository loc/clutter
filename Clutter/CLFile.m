//
//  CLFile.m
//  Clutter
//
//  Created by Andy Locascio on 1/10/16.
//  Copyright © 2016 Bubble Tea Apps. All rights reserved.
//

#import "CLFile.h"
#import "CoreWrapper.h"
@import Quartz;


@interface CLFile ()
@property (strong, readwrite) NSString* name;
@property (strong, readwrite) NSString* archiveName;
@property (strong, readwrite) NSURL* archiveURL;
@property (strong, readwrite) NSString* previousName;
@property (strong, readwrite) NSString* displayName;
@end

@interface CLFile (QLPreviewItem) <QLPreviewItem>

@end

@implementation CLFile

- (NSURL *)previewItemURL {
    return [self resolvedURL];
}
- (NSString *)previewItemTitle {
    return self.name;
}

- (void) setURL:(NSURL *)url {
    self->_url = url;
    [self setName:[url lastPathComponent]];
    [self setArchiveURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%lu%@", self.inode, self.name] relativeToURL:[[[CoreWrapper sharedInstance] supportURL] URLByAppendingPathComponent:@"Archives" isDirectory:YES]]];
}

- (void) setName:(NSString *)name {
    _name = name;
    [self setDisplayName:[[CoreWrapper class] getDisplayName:name]];
}

- (void) setArchiveURL:(NSURL *)archiveURL {
    [self setArchiveName:[archiveURL lastPathComponent]];
    _archiveURL = archiveURL;
}

- (void) setPreviousURL:(NSURL *)previousURL {
    [self setPreviousName:[previousURL lastPathComponent]];
    _previousURL = previousURL;
}

- (void) generateThumbnail {
    
}

- (NSURL*) resolvedURL {
    return self.isArchived ? self.archiveURL : self.url;
}

- (NSString*) truncName:(NSString*)name forChars:(unsigned int)chars {
    NSUInteger fileExtensionIndex = ([name rangeOfString:@"." options:NSBackwardsSearch]).location;
    if (chars < [name length]) {
    
        // if no extension just chunk that sucker
        if (fileExtensionIndex == NSNotFound) {
            return [NSString stringWithFormat:@"%@...", [name substringToIndex:chars]];
        }
        
        NSString* nameNoExt = [name substringToIndex:fileExtensionIndex];
        NSString* ext = [name substringFromIndex:fileExtensionIndex+1];
        
        if ([nameNoExt length] > chars - [ext length]) {
            return [NSString stringWithFormat:@"%@...%@", [nameNoExt substringToIndex:chars - [ext length]], ext];
        }
    }
    
    return name;
}

- (NSString*) truncName:(unsigned int)chars {
    return [self truncName:self.name forChars:chars];
}

@end
