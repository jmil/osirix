//
//  DisclosureBox.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import "DisclosureBox.h"
#include <algorithm>

@interface ATDisclosureButtonCell : NSButtonCell
@end
@implementation ATDisclosureButtonCell

-(id)init {
	self = [super init];
	[self setBezelStyle:NSDisclosureBezelStyle];
	[self setButtonType:NSOnOffButton];
	[self setState:NSOnState];
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
	
	if (_titleCell) [_titleCell release]; // [NSBox dealloc] will release ours
	_titleCell = [[ATDisclosureButtonCell alloc] init];
	[_titleCell setTitle:title];
	[_titleCell setState:NSOffState];
	[_titleCell setTarget:self];
	[_titleCell setAction:@selector(toggle:)];
	
	_contentHeight = [content bounds].size.height;
	_content = [content retain];
	[self setFrameFromContentFrame:NSMakeRect(0,0,0,0)];
	
    return self;
}

-(void)dealloc {
	[_content release];
	[super dealloc];
}

-(void)mouseDown:(NSEvent*)event {
	if (NSPointInRect([event locationInWindow], [self convertRect:[self titleRect] toView:NULL]))
		[_titleCell trackMouse:event inRect:[self titleRect] ofView:self untilMouseUp:YES];
	else [super mouseDown:event];
}

-(void)setEnabled:(BOOL)flag {
	[_titleCell setEnabled:flag];
}

-(BOOL)isExpanded {
	return [_titleCell state] == NSOnState;
}

-(void)toggle:(id)sender {
	if ([self isExpanded])
		[self expand:sender];
	else [self collapse:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DisclosureBoxDidToggle" object:self];
}

-(void)expand:(id)sender {
	if (_showingExpanded) return;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DisclosureBoxWillExpand" object:self];
	_showingExpanded = YES;
	
	[self addSubview:_content];
	NSSize frameSize = [self frame].size;
	frameSize.height += _contentHeight;
	[self setFrameSize:frameSize];
//	[self setBounds:NSMakeRect(0,0,frameSize.width, frameSize.height)];
	[_titleCell calcDrawInfo:[self frame]];
	
	[_titleCell setState:NSOnState];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DisclosureBoxDidExpand" object:self];
}

-(void)collapse:(id)sender {
	if (!_showingExpanded) return;
	_showingExpanded = NO;
	
	NSSize size = [self bounds].size;
	[_content removeFromSuperview];
	size.height -= _contentHeight;
	[self setFrameSize:size];
//	[self setBounds:NSMakeRect(0,0,size.width, size.height)];
	[_titleCell calcDrawInfo:[self frame]];
	
	[_titleCell setState:NSOffState];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DisclosureBoxDidCollapse" object:self];
}


@end
