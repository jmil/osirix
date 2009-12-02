//
//  NSView+N2.m
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/11/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2View.h>
#import <Nitrogen/N2Layout.h>
// #import <Nitrogen/N2Operators.h>

NSString* N2ViewBoundsSizeDidChangeNotification = @"N2ViewBoundsSizeDidChangeNotification";
NSString* N2ViewBoundsSizeDidChangeNotificationOldBoundsSize = @"oldBoundsSize";

@implementation N2View
@synthesize controlSize = _controlSize, minSize = _minSize, maxSize = _maxSize, layout = _layout, foreColor = _foreColor, backColor = _backColor;

-(void)dealloc {
	[self setForeColor:NULL];
	[self setBackColor:NULL];
	[self setLayout:NULL];
	[super dealloc];
}

-(void)resizeSubviews {
	[self resizeSubviewsWithOldSize:[self bounds].size];
}

-(void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
	[_layout layOut];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:N2ViewBoundsSizeDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithSize:oldBoundsSize] forKey:N2ViewBoundsSizeDidChangeNotificationOldBoundsSize]]];
}

-(void)formatSubview:(NSView*)view {
	if (view) {
		if (_foreColor && [view respondsToSelector:@selector(setTextColor:)])
			[view performSelector:@selector(setTextColor:) withObject:_foreColor];
		if (_backColor && [view respondsToSelector:@selector(setBackgroundColor:)])
			[view performSelector:@selector(setBackgroundColor:) withObject:_backColor];
		else if ([view respondsToSelector:@selector(setDrawsBackground:)])
			[(NSText*)view setDrawsBackground:NO];
	} else
		view = self;
	
	for (NSView* subview in [view subviews])
		if (![subview isKindOfClass:[N2View class]] || [(N2View*)subview layout] == NULL)
			[self formatSubview:subview];
	if ([view respondsToSelector:@selector(additionalSubviews)])
		for (NSView* subview in [view performSelector:@selector(additionalSubviews)])
			if (![subview isKindOfClass:[N2View class]] || [(N2View*)subview layout] == NULL)
				[self formatSubview:subview];
}

-(void)didAddSubview:(NSView*)view {
	[self formatSubview:view];
}

-(void)setForeColor:(NSColor*)color {
	[_foreColor release];
	_foreColor = [color retain];
	for (NSView* view in [self subviews])
		[self formatSubview:view];
}

@end

