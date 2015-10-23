//
//  CLPanel.h
//  
//
//  Created by Andy Locascio on 10/4/15.
//
//

#import <Cocoa/Cocoa.h>
#import "constants.h"


@interface CLPanel : NSWindow
@property (nonatomic, strong) NSView* panelView;
@property (nonatomic, strong) NSView* arrowView;
@property (nonatomic, assign) NSPoint point;
@property (nonatomic, assign) NSSize size;
- (instancetype) initWithContentSize: (NSSize)size relativeToPoint:(NSPoint)point;
- (void) reposition;

@end


@interface CLPanelView : NSView
@end

@interface CLArrowView : NSView

@end