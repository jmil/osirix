//
//  N2LayoutManager.m
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/11/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2LayoutManager.h>
#import <Nitrogen/N2Operators.h>
#import <Nitrogen/N2View.h>
#include <algorithm>
#import <Nitrogen/N2Debug.h>

@implementation N2LayoutManager
@synthesize occupiesEntireSuperview = _occupiesEntireSuperview, forcesSuperviewSize = _forcesSuperviewSize, stretchesToFill = _stretchesToFill, foreColor = _foreColor;

-(id)initWithControlSize:(NSControlSize)size {
	self = [super init];
	
	switch (_controlSize = size) {
		case NSRegularControlSize:
			_padding = NSMakeRect(NSMakePoint(17,17), NSMakeSize(34));
			_separation = NSMakeSize(2,6);
			break;
		case NSSmallControlSize:
			_padding = NSMakeRect(NSMakePoint(10,10), NSMakeSize(20));
			_separation = NSMakeSize(2,4);
			break;
		case NSMiniControlSize:
			_padding = NSMakeRect(NSMakePoint(5,5), NSMakeSize(10));
			_separation = NSMakeSize(1,2);
			break;
	}
	
//	_fontSize = [NSFont systemFontSizeForControlSize:size];

	return self;
}

-(void)dealloc {
	if (_foreColor) [_foreColor release];
	if (_backColor) [_backColor release];
	[super dealloc];
}

-(void)adaptSubview:(NSView*)view {
	if (_foreColor && [view respondsToSelector:@selector(setTextColor:)])
		[(NSTextView*)view setTextColor:_foreColor];
	if (_backColor && [view respondsToSelector:@selector(setBackgroundColor:)])
		[(NSTextView*)view setBackgroundColor:_backColor];
	if (!_backColor && [view respondsToSelector:@selector(setDrawsBackground:)])
		[(NSTextView*)view setDrawsBackground:NO];
	//	if ([view respondsToSelector:@selector(setFont:)])
	//		[(NSTextView*)view setFont:[NSFont labelFontOfSize:_fontSize]];
	//	if ([view respondsToSelector:@selector(cell)])
	//		[[(NSControl*)view cell] setControlSize:_controlSize];
	
	//	if ([view respondsToSelector:@selector(setDrawsBackground:)])
	//		[(NSTextView*)view setDrawsBackground:YES];
	//	if ([view respondsToSelector:@selector(setBackgroundColor:)])
	//		[(NSTextView*)view setBackgroundColor:[NSColor blueColor]];
}

-(void)didAddSubview:(NSView*)view {
	[self adaptSubview:view];
	
	for (NSView* subview in [view subviews])
		if (![subview isKindOfClass:[N2View class]] || [(N2View*)subview layout] == NULL)
			[self didAddSubview:subview];
}

-(NSRect)marginFor:(NSView*)view {
	if ([view isKindOfClass:[NSTextView class]])
		return NSMakeRect(-3,0, -6,0);
	// TODO: others, specially buttons
	return NSMakeRect(0, 0, 0, 0);
}

-(void)recalculate:(N2View*)view {
	DLog(@"[N2LayoutManager recalculate]");
	
	NSRect bounds = [view bounds];
	if (!_occupiesEntireSuperview) {
		bounds.origin += _padding.origin;
		bounds.size -= _padding.size;
	}
	NSArray* content = [view content];
	
	CGFloat maxWidth = 0;
	CGFloat rowWidths[[content count]], rowViewCounts[[content count]];
	
	// detect needed width
	for (int i = [content count]-1; i >= 0; --i) {
		rowWidths[i] = 0;
		rowViewCounts[i] = 0;
		for (NSView* view in [content objectAtIndex:i])
			if ([view isKindOfClass:[NSView class]]) {
				++rowViewCounts[i];
				rowWidths[i] += ceilf([view frame].size.width)+_separation.width+[self marginFor:view].size.width;
			}
		rowWidths[i] -= _separation.width;
		maxWidth = std::max(maxWidth, rowWidths[i]);
	}
	
	if (_stretchesToFill)
		maxWidth = bounds.size.width;
	
	// move views
	CGFloat y = 0;
	for (int i = [content count]-1; i >= 0; --i) {
		NSArray* row = [content objectAtIndex:i];
		CGFloat xFactor = 1;
		if (_stretchesToFill)
			xFactor = (maxWidth-_separation.width*(rowViewCounts[i]-1))/rowWidths[i];
		CGFloat x = 0, maxHeight = 0;
		for (NSView* view in row)
			if ([view isKindOfClass:[NSView class]]) {
				NSRect frame = [view frame], viewMargin = [self marginFor:view];
				frame.origin = NSMakePoint(x,y)+bounds.origin+viewMargin.origin;
				if (xFactor != 0) frame.size.width *= xFactor;
				else frame.size.width = maxWidth;
				[view setFrame:frame];
				x += ceilf(frame.size.width)+_separation.width+viewMargin.size.width;
				maxHeight = std::max(maxHeight, ceilf([view frame].size.height)+viewMargin.size.height);
			}
		
//		CGFloat difference = bounds.size.width - x;
//		if (_occupiesEntireSuperview && difference > 0) {
//			CGFloat availableWidth = bounds.size.width - _separation.width*([row count]-1);
//			x = 0;
//			for (NSView* view in row) {
//				NSRect frame = [view frame];
//				frame.size.width *= 
//			}
//		}
	
		y += maxHeight+_separation.height;
	}
	
	NSSize size = NSMakeSize(maxWidth, y-_separation.height);
	if (!_occupiesEntireSuperview) {
		size += _padding.size;
		bounds.origin -= _padding.origin;
		bounds.size += _padding.size;
	}
	
//	size.width -= 2;
	NSWindow* window = [view window];
	if (_forcesSuperviewSize && !NSEqualSizes(size, [view bounds].size))
		if (view == [window contentView]) {
			NSRect frame = [window frame];
			NSSize oldFrameSize = frame.size;
			frame.size = [window frameRectForContentRect:NSMakeRect(NSZeroPoint, size)].size;
			frame.origin = frame.origin - (frame.size - oldFrameSize);
			[window setFrame:frame display:YES];
			[window setMinSize:[window frameRectForContentRect:NSMakeRect(0,0,[window minSize].width, size.height)].size]; // TODO: x minmax must be kept
			[window setMaxSize:[window frameRectForContentRect:NSMakeRect(0,0,[window maxSize].width, size.height)].size]; // TODO: x minmax must be kept
		} else [view setFrameSize:size];
}

-(void)setForeColor:(NSColor*)color {
	if (_foreColor) [_foreColor release];
	_foreColor = [color retain];
}

@end
