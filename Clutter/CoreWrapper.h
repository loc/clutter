//
//  CoreWrapper.h
//  Clutter
//
//  Created by Andy Locascio on 6/29/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^changeCallback)(void);

@interface CoreWrapper : NSObject {
    NSMutableArray * callbacks;
}

@property (retain) NSURL* url;

+ (CoreWrapper*)sharedInstance;
-(void) runBlockOnChange: (changeCallback) callback;;
-(NSArray*) listFiles;
-(void)loop;
-(NSInteger) count;

@end
