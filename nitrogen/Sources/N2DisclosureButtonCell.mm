//
//  N2DisclosureButtonCell.mm
//  Nitrogen Framework
//
//  Created by Joris Heuberger on 30/03/07.
//  Edited by Alessandro Volz since 21/05/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2DisclosureButtonCell.h>

@implementation N2DisclosureButtonCell
@synthesize attributes = _attributes;

-(id)init {
	self = [super init];
	[self setBezelStyle:NSDisclosureBezelStyle];
	[self setButtonType:NSOnOffButton];
	[self setState:NSOnState];
	[self setControlSize:NSSmallControlSize];
	[self sendActionOn:NSLeftMouseDownMask];
	
	_attributes = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
//						[NSColor whiteColor], NSForegroundColorAttributeName,
//						[NSFont labelFontOfSize:[NSFont smallSystemFontSize]], NSFontAttributeName,
					NULL] retain];
	
	return self;
}

-(void)dealloc {
	[_attributes release];
	[super dealloc];
}

-(NSRect)titleRectForBounds:(NSRect)bounds {
	NSSize size = [super cellSizeForBounds:bounds];
	NSSize textSize = [self textSize];
	return NSMakeRect(bounds.origin.x+bounds.size.width, bounds.origin.y, textSize.width, textSize.height);
}

-(NSSize)textSize {
	return [[self title] sizeWithAttributes:_attributes];
}

-(NSRect)drawTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView {
	[[self title] drawInRect:frame withAttributes:_attributes];
	return frame;
}

@end
