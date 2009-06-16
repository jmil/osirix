//
//  DisclosureBox.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import "StepByStep/DisclosureBox.h"
#include <algorithm>

@interface ATButtonCell : NSButtonCell
@end
@implementation ATButtonCell

-(id)init {
	self = [super init];
	[self setBezelStyle:NSDisclosureBezelStyle];
	[self setControlSize:NSSmallControlSize];
	[self sendActionOn:NSLeftMouseDownMask];
	return self;
}

-(NSDictionary*)attributes {
	static const NSDictionary* attributes = [[NSDictionary dictionaryWithObjectsAndKeys:
												[NSColor whiteColor], NSForegroundColorAttributeName,
												[NSFont labelFontOfSize:[NSFont smallSystemFontSize]], NSFontAttributeName,
											  NULL] retain];
	return attributes;
}

-(NSRect)imageRectForBounds:(NSRect)bounds {
	NSSize size = [super cellSizeForBounds:bounds];
	return NSMakeRect(bounds.origin.x, bounds.origin.y, size.width, size.height);
}

-(NSRect)titleRectForBounds:(NSRect)bounds {
	NSSize size = [super cellSizeForBounds:bounds];
	NSSize textSize = [[self title] sizeWithAttributes:[self attributes]];
	return NSMakeRect(bounds.origin.x+bounds.size.width, bounds.origin.y, textSize.width, textSize.height);
}

-(NSRect)drawTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView {
	[[self title] drawInRect:frame withAttributes:[self attributes]];
	return frame;
}

@end

@implementation DisclosureBox

-(id)initWithTitle:(NSString*)title content:(NSView*)content {
    self = [super initWithFrame:NSZeroRect];
	
	// NSBox
	[super setTitlePosition:NSAtTop];
	[super setBorderType:NSBezelBorder];
	[super setBoxType:NSBoxPrimary];

	_titleCell = [[ATButtonCell alloc] init];
	[_titleCell setTitle:title];
	[_titleCell setTarget:self];
	[_titleCell setAction:@selector(toggle:)];
	
	[self setContentView:content];
	[self setFrameFromContentFrame:[[self contentView] frame]];
	
	[self setTitle:title];
	
    return self;
}

-(void)dealloc {
	[_titleCell release];
	[super dealloc];
}

-(id)titleCell {
	return _titleCell;
}

-(void)mouseDown:(NSEvent*)event {
	if (NSPointInRect([event locationInWindow], [self convertRect:[self titleRect] toView:NULL])) {
		[_titleCell setIntValue:![_titleCell intValue]];
		[self setNeedsDisplay:YES];
		[[_titleCell target] performSelector:[_titleCell action] withObject:_titleCell];
	} else [super mouseDown:event];
}

-(void)setEnabled:(BOOL)flag {
	[_button setEnabled:flag];
}

-(BOOL)isExpanded {
	return [_titleCell intValue] != 0;
}

-(void)toggle:(id)sender {
	if ([self isExpanded])
		[self expand:sender];
	else [self collapse:sender];
}

-(void)expand:(id)sender {
	NSSize viewSize = [[self contentView] frame].size;
	[[self contentView] setHidden:NO];
	
	NSRect frame = [self frame];
	frame.size.height += viewSize.height;
	frame.origin.y -= viewSize.height;
	[self setFrame:frame];
}

-(void)collapse:(id)sender {
	NSSize viewSize = [[self contentView] frame].size;
	[[self contentView] setHidden:YES];

	NSRect frame = [self frame];
	frame.size.height -= viewSize.height;
	frame.origin.y += viewSize.height;
	[self setFrame:frame];
}

@end
