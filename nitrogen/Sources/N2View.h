//
//  NSView+N2.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/11/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class N2Layout;

extern NSString* N2ViewBoundsSizeDidChangeNotification;
extern NSString* N2ViewBoundsSizeDidChangeNotificationOldBoundsSize;

@interface N2View : NSView {
	NSControlSize _controlSize;
	NSSize _minSize, _maxSize;
	N2Layout* _layout;
	NSColor* _foreColor;
	NSColor* _backColor;
}

@property NSControlSize controlSize;
@property NSSize minSize, maxSize;
@property(retain) N2Layout* layout;
@property(retain) NSColor* foreColor;
@property(retain) NSColor* backColor;

-(void)formatSubview:(NSView*)view;
-(void)resizeSubviews;

@end

