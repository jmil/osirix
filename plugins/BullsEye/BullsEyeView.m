//
//  BullsEyeView.m
//  BullsEye
//
//  Created by Antoine Rosset on 18.11.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "BullsEyeView.h"


@implementation BullsEyeView

- (void) dealloc
{
	[segments release];
	
	[super dealloc];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame: frame];
    if (self)
	{
		segments = [[NSMutableArray alloc] init];
		
		for( int i = 0 ; i < 16; i++)
			[segments addObject: [NSMutableDictionary dictionary]];
    }
    return self;
}

- (void) mouseDown:(NSEvent *) theEvent
{
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint local_point = [self convertPoint:event_location fromView:nil];

	float r = 0.5;
	float g = 0.5;
	float b = 0;
	
	for( NSMutableDictionary *seg in segments)
	{
		if( [[seg objectForKey: @"drawing"] containsPoint: local_point])
		{
			[seg setObject: [NSColor colorWithDeviceRed: r green: g blue: b alpha: 1.0] forKey: @"color"];
			
			[seg setObject: [NSString stringWithFormat: @"test"] forKey: @"text"];
		}
	}
	
	[self setNeedsDisplay: YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
	// Set up
	
	NSRect frame = [self frame];
	
	frame.origin.x += 5;
	frame.origin.y += 5;
	
	frame.size.height -= 10;
	frame.size.width -= 10;
	
	if( frame.size.height > frame.size.width)
		frame.size.height = frame.size.width;
	else 
		frame.size.width = frame.size.height;
	
	NSPoint center = NSMakePoint( [self frame].origin.x + [self frame].size.width/2., [self frame].origin.y + [self frame].size.height/2.);
	float radius = frame.size.width/2.;
	
	int a = 0;
	float segRadius = 0;
	for( int i = 0 ; i < 6; i++)
	{
		NSBezierPath* s = [[[NSBezierPath alloc] init] autorelease];
		[s appendBezierPathWithArcWithCenter: center radius: radius startAngle: segRadius+60 endAngle: segRadius clockwise: YES];
		[s appendBezierPathWithArcWithCenter: center radius: radius*5/7 startAngle: segRadius endAngle: segRadius+60];
		[s closePath];
		[s setLineWidth: 0.5];
		[s setLineJoinStyle:NSRoundLineJoinStyle];
		
		segRadius += 60;
		
		[[segments objectAtIndex: a++] setObject: s forKey: @"drawing"];
	}
	segRadius = 0;
	for( int i = 0 ; i < 6; i++)
	{
		NSBezierPath* s = [[[NSBezierPath alloc] init] autorelease];
		[s appendBezierPathWithArcWithCenter: center radius: radius*5/7 startAngle: segRadius+60 endAngle: segRadius clockwise: YES];
		[s appendBezierPathWithArcWithCenter: center radius: radius*3/7 startAngle: segRadius endAngle: segRadius+60];
		[s closePath];
		[s setLineWidth: 0.5];
		[s setLineJoinStyle:NSRoundLineJoinStyle];
		
		segRadius += 60;
		
		[[segments objectAtIndex: a++] setObject: s forKey: @"drawing"];
	}
	segRadius = 45;
	for( int i = 0 ; i < 4; i++)
	{
		NSBezierPath* s = [[[NSBezierPath alloc] init] autorelease];
		[s appendBezierPathWithArcWithCenter: center radius: radius*3/7 startAngle: segRadius+90 endAngle: segRadius clockwise: YES];
		[s appendBezierPathWithArcWithCenter: center radius: radius*1/7 startAngle: segRadius endAngle: segRadius+90];
		[s closePath];
		[s setLineWidth: 0.5];
		[s setLineJoinStyle:NSRoundLineJoinStyle];
		
		segRadius += 90;
		
		[[segments objectAtIndex: a++] setObject: s forKey: @"drawing"];
	}
	
	// Drawing
	
   for( int i = 0; i < [segments count]; i++)
   {
		NSDictionary* s = [segments objectAtIndex: i];
		
		[[s objectForKey: @"color"] set];
		[[s objectForKey: @"drawing"] fill];
		[[NSColor blackColor] set];
		[[s objectForKey: @"drawing"] stroke];
		
		NSSize size = [[s objectForKey: @"text"] sizeWithAttributes: nil];
		NSRect bounds = [[s objectForKey: @"drawing"] bounds];
		
		NSPoint p = NSMakePoint( bounds.origin.x + bounds.size.width/2 - size.width/2, bounds.origin.y + bounds.size.height/2 - size.height/2);
		[[s objectForKey: @"text"] drawAtPoint: p withAttributes: nil];
   }
}

@end
