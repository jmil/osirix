//
//  N2ButtonCell.mm
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/25/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2ButtonCell.h>
#import <Nitrogen/NSString+N2.h>
#import <Nitrogen/N2Operators.h>


@implementation N2ButtonCell

-(void)awakeFromNib {
	[self setShowsBorderOnlyWhileMouseInside:NO];
	_keyEq = [[self keyEquivalent] retain];
}

-(void)dealloc {
	if (_keyEq) [_keyEq release]; _keyEq = NULL;
	[super dealloc];
}

-(void)drawBezelWithFrame:(NSRect)frame inView:(NSButton*)view {
	if (_keyEq && [_keyEq length] && [_keyEq characterAtIndex:0] == '\r') {
		NSGraphicsContext* context = [NSGraphicsContext currentContext];
		[context saveGraphicsState];
		
		[[NSColor colorWithCalibratedRed:.5 green:.66 blue:1 alpha:.75] setFill];
		[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 0, 1) xRadius:frame.size.height/2 yRadius:frame.size.height/2] fill];
		
		[context restoreGraphicsState];
	}
	
	[super drawBezelWithFrame:frame inView:view];
}

@end
