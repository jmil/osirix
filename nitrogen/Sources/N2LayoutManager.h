//
//  N2LayoutManager.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/11/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class N2View;

@interface N2LayoutManager : NSObject {
	NSControlSize _controlSize;
	NSRect _padding;
	NSSize _separation;
//	CGFloat _fontSize;
	BOOL _occupiesEntireSuperview;
	NSColor* _foreColor;
	NSColor* _backColor;
	BOOL _forcesSuperviewSize, _stretchesToFill;
}

@property BOOL occupiesEntireSuperview;
@property BOOL stretchesToFill;
@property BOOL forcesSuperviewSize;
@property(retain) NSColor* foreColor;

-(id)initWithControlSize:(NSControlSize)size;
-(void)recalculate:(N2View*)view;
-(void)didAddSubview:(NSView*)view;
//-(void)willRemoveSubview:(NSView*)view;

@end
