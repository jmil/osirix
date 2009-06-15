//
//  DisclosureBox.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import "DisclosureBox.h"
#include <algorithm>

@interface ATButtonCell : NSButtonCell
@end
@implementation ATButtonCell

-(NSSize)cellSizeForBounds:(NSRect)bounds {
	NSSize size = [super cellSizeForBounds:bounds];
//	NSSize textSize = [[self title] sizeWithAttributes:NULL];
//	
//	size.width += textSize.width;
//	size.height = std::max(size.height, textSize.height);
//	
	return size;
}

-(NSRect)imageRectForBounds:(NSRect)bounds {
	NSSize size = [super cellSizeForBounds:bounds];
	return NSMakeRect(bounds.origin.x, bounds.origin.y, size.width, size.height);//NSRect rect = [self titleRectForBounds:<#(NSRect)theRect#>];
}

-(NSRect)titleRectForBounds:(NSRect)bounds {
	NSSize size = [super cellSizeForBounds:bounds];
	NSSize textSize = [[self title] sizeWithAttributes:NULL];
	return NSMakeRect(bounds.origin.x+bounds.size.width, bounds.origin.y, textSize.width, textSize.height);//NSRect rect = [self titleRectForBounds:<#(NSRect)theRect#>];
}

//-(NSRect)drawTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView {
//	NSDictionary* attributes = NULL;
//	[[self title] drawInRect:frame withAttributes:attributes];
//	NSSize size = [[self title] sizeWithAttributes:attributes];
//	return NSMakeRect(frame.origin.x, frame.origin.y, size.width, size.height);
//}

@end

@implementation DisclosureBox

-(id)initWithTitle:(NSString*)title content:(NSView*)content {
    self = [super initWithFrame:NSZeroRect];
	
	// NSBox
	[super setTitlePosition:NSAtTop];
	[super setBorderType:NSBezelBorder];
	[super setBoxType:NSBoxPrimary];

	_titleCell = [[ATButtonCell alloc] init];
	[_titleCell setBezelStyle:NSDisclosureBezelStyle];
	[_titleCell setControlSize:NSSmallControlSize];
	[_titleCell setTitle:@"WTF?1"];
	[self setTitle:@"WTF?2"];
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
