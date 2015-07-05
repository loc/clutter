//
//  CoreWrapper.h
//  Clutter
//
//  Created by Andy Locascio on 6/29/15.
//  Copyright (c) 2015 Bubble Tea Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreWrapper : NSObject

-(id)initWithCallback: (void(^)(void))callback;
-(NSArray*) listFiles;
-(void)loop;
-(NSInteger) count;

@end
