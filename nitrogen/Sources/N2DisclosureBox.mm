//
//  N2DisclosureBox.mm
//  Nitrogen Framework
//
//  Created by Joris Heuberger on 30/03/07.
//  Edited by Alessandro Volz since 21/05/09.
//  Copyright 2009 OsiriX Foundation. All rights reserved.
//

#import <Nitrogen/N2DisclosureBox.h>
#import <Nitrogen/N2DisclosureButtonCell.h>
#import <Nitrogen/N2Operators.h>

NSString* N2DisclosureBoxDidToggle = @"N2DisclosureBoxDidToggle";
NSString* N2DisclosureBoxWillExpand = @"N2DisclosureBoxWillExpand";
NSString* N2DisclosureBoxDidExpand = @"N2DisclosureBoxDidExpand";
NSString* N2DisclosureBoxDidCollapse = @"N2DisclosureBoxDidCollapse";

@implementation N2DisclosureBox

-(id)initWithTitle:(NSString*)title content:(NSView*)content {
    self = [super initWithFrame:NSZeroRect];
	
	// NSBox
	[self setTitlePosition:NSAtTop];
	[self setBorderType:NSBezelBorder];
	[self setBoxType:NSBoxPrimary];
	[self setAutoresizesSubviews:YES];
	
	if (_titleCell) [_titleCell release]; // [NSBox dealloc] will later release the object we will now create
	_titleCell = [[N2DisclosureButtonCell alloc] init];
	[_titleCell setTitle:title];
	[_titleCell setState:NSOffState];
	[_titleCell setTarget:self];
	[_titleCell setAction:@selector(toggle:)];
	
	_content = [content retain];
	[self setFrameFromContentFrame:NSZeroRect];
	
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

-(BOOL)enabled {
	return [_titleCell isEnabled];
}

-(void)setEnabled:(BOOL)flag {
	[_titleCell setEnabled:flag];
}

-(BOOL)isExpanded {
	return [_titleCell state] == NSOnState;
}

-(N2DisclosureButtonCell*)titleCell {
	return _titleCell;
}

-(void)toggle:(id)sender {
	if ([self isExpanded])
		[self expand:sender];
	else [self collapse:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:N2DisclosureBoxDidToggle object:self];
}

-(void)expand:(id)sender {
	if (_showingExpanded) return;
	[[NSNotificationCenter defaultCenter] postNotificationName:N2DisclosureBoxWillExpand object:self];
	_showingExpanded = YES;
	
	[self setFrameFromContentFrame:[_content bounds]];
	[self addSubview:_content];
	
	[_titleCell setState:NSOnState];
	[[NSNotificationCenter defaultCenter] postNotificationName:N2DisclosureBoxDidExpand object:self];
}

-(void)collapse:(id)sender {
	if (!_showingExpanded) return;
	_showingExpanded = NO;
	
	[_content removeFromSuperview];
	[self setFrameFromContentFrame:NSZeroRect];
	
	[_titleCell setState:NSOffState];
	[[NSNotificationCenter defaultCenter] postNotificationName:N2DisclosureBoxDidCollapse object:self];
}

-(void)setFrameFromContentFrame:(NSRect)contentFrame {
	NSRect frame = contentFrame + [self contentViewMargins]*2;
	
}

-(void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
	[super resizeSubviewsWithOldSize:oldBoundsSize];
	[_titleCell calcDrawInfo:[self frame]];
}

@end
