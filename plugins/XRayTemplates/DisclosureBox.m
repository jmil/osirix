//
//  DisclosureBox.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import "DisclosureBox.h"

@implementation DisclosureButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
	{
		[self setButtonType:NSToggleButton];
		[self setBordered:NO];
		[self setImage:[DisclosureButton _createTriangleImageWithPoint1:NSMakePoint(1, 1) point2:NSMakePoint(1, 11) point3:NSMakePoint(11, 6)]];
		[self setAlternateImage:[DisclosureButton _createTriangleImageWithPoint1:NSMakePoint(1, 11) point2:NSMakePoint(6, 1) point3:NSMakePoint(11, 11)]];
		[self setClickedImage:[DisclosureButton _createTriangleImageWithPoint1:NSMakePoint(7, 12) point2:NSMakePoint(10, 2) point3:NSMakePoint(0, 4)]];
		
		tempImage = [DisclosureButton _createTriangleImageWithPoint1:NSMakePoint(1, 1) point2:NSMakePoint(1, 11) point3:NSMakePoint(11, 6)];
		tempAlternateImage = [DisclosureButton _createTriangleImageWithPoint1:NSMakePoint(1, 11) point2:NSMakePoint(6, 1) point3:NSMakePoint(11, 11)];
    }
    return self;
}

- (void)dealloc
{
//	[[self image] release];
//	[[self alternateImage] release];
	[tempImage release];
	[tempAlternateImage release];
	[clickedImage release];
	[super dealloc];
}

+ (NSImage*)_createTriangleImageWithPoint1:(NSPoint)p1 point2:(NSPoint)p2 point3:(NSPoint)p3;
{
	return [DisclosureButton _createTriangleImageWithPoint1:p1 point2:p2 point3:p3 color:[NSColor darkGrayColor]];
}

+ (NSImage*)_createTriangleImageWithPoint1:(NSPoint)p1 point2:(NSPoint)p2 point3:(NSPoint)p3 color:(NSColor*)color;
{
	NSImage *img = [[NSImage alloc] initWithSize:NSMakeSize(13, 13)];
	
	// colors
	NSColor *backgroundColor = [NSColor clearColor];
	NSColor *triangleColor = color;
	
	// draw
	[img setBackgroundColor:backgroundColor];
	[img lockFocus];
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:p1];
	[path lineToPoint:p2];
	[path lineToPoint:p3];
	[path lineToPoint:p1];
	[triangleColor set];
	[path fill];
	[img unlockFocus];
	
	return img;
}

- (void)setClickedImage:(NSImage*)img;
{
	if(clickedImage) [clickedImage release];
	clickedImage = img;
	[clickedImage retain];
}

- (void)mouseDown:(NSEvent *)theEvent;
{
	if([self state]==NSOffState)
		[self setAlternateImage:clickedImage];
	else
		[self setImage:clickedImage];
	[super mouseDown:theEvent];
	[self drawRect:[self frame]];
}

- (void)drawRect:(NSRect)rect
{
	if([self state]==NSOnState)
		[self setAlternateImage:tempAlternateImage];
	else
		[self setImage:tempImage];

	[super drawRect:rect];
}

- (void)setColor:(NSColor*)color;
{
	if([self image])[[self image] release];
	if([self alternateImage])[[self alternateImage] release];
	if(tempImage)[tempImage release];
	if(tempAlternateImage)[tempAlternateImage release];

	[self setImage:[DisclosureButton _createTriangleImageWithPoint1:NSMakePoint(1, 1) point2:NSMakePoint(1, 11) point3:NSMakePoint(11, 6) color:color]];
	[self setAlternateImage:[DisclosureButton _createTriangleImageWithPoint1:NSMakePoint(1, 11) point2:NSMakePoint(6, 1) point3:NSMakePoint(11, 11) color:color]];
	[self setClickedImage:[DisclosureButton _createTriangleImageWithPoint1:NSMakePoint(7, 12) point2:NSMakePoint(10, 2) point3:NSMakePoint(0, 4) color:color]];
	tempImage = [DisclosureButton _createTriangleImageWithPoint1:NSMakePoint(1, 1) point2:NSMakePoint(1, 11) point3:NSMakePoint(11, 6) color:color];
	tempAlternateImage = [DisclosureButton _createTriangleImageWithPoint1:NSMakePoint(1, 11) point2:NSMakePoint(6, 1) point3:NSMakePoint(11, 11) color:color];
}

@end

@implementation DisclosureBox

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
	{
		// Box
        [super setTitlePosition:NSNoTitle];
		[super setBorderType:NSBezelBorder];
		[super setBoxType:NSBoxPrimary];
		isExpanded = NO;
		
		// Disclosure Button
		disclosureButton = [[DisclosureButton alloc] initWithFrame:NSMakeRect(0, 0, 13, 13)];
		[self addSubview:disclosureButton];
		NSPoint disclosureButtonOrigin = NSMakePoint(9, [[self contentView] frame].size.height-[disclosureButton frame].size.height-2);
		[disclosureButton setFrameOrigin:disclosureButtonOrigin];
		[disclosureButton setAction:@selector(toggle:)];
		[disclosureButton setTarget:self];
		
		// Title
		titleTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
		[self addSubview:titleTextField];
		[titleTextField setEditable:NO];
		[titleTextField setBordered:NO];
		[titleTextField setDrawsBackground:NO];
		NSPoint titleTextFieldOrigin = NSMakePoint(disclosureButtonOrigin.x+[disclosureButton frame].size.width+5, [[self contentView] frame].size.height-[titleTextField frame].size.height);
		[titleTextField setFrameOrigin:titleTextFieldOrigin];
		
		enabledColor = [[NSColor blackColor] retain];
		disabledColor = [[NSColor grayColor] retain];
		
//		[self setAutoresizesSubviews:NO];
    }
    return self;
}

- (void)dealloc
{
	[disclosureButton release];
	[titleTextField release];
	if(enclosedView) [enclosedView release];
	[enabledColor release];
	[disabledColor release];
	[super dealloc];
}

- (void)setTitle:(NSString *)aString
{
	[titleTextField setStringValue:aString];
	[titleTextField sizeToFit];
}

- (void)setEnclosedView:(NSView*)view;
{
	if(enclosedView) [enclosedView release];
	enclosedView = view;
	[enclosedView retain];
}

- (void)toggle:(id)sender;
{
	if(!isExpanded)
		[self expand:sender];
	else
		[self collapse:sender];
	[[self window] display];
}

- (void)expand:(id)sender;
{
	if(enclosedView==nil) return;
	if(isExpanded) return;
		
	NSSize viewSize = [enclosedView frame].size;
	NSRect boxFrame = [self frame];
	NSRect disclosureButtonFrame = [disclosureButton frame];
	NSRect titleTextFieldFrame = [titleTextField frame];
	NSSize newBoxSize = boxFrame.size;
	NSPoint newBoxOrigin = boxFrame.origin;
	NSPoint newDisclosureButtonOrigin = disclosureButtonFrame.origin;
	NSPoint newTitleTextFieldOrigin = titleTextFieldFrame.origin;

	newBoxSize.height += viewSize.height;
	newBoxOrigin.y -= viewSize.height;
	newDisclosureButtonOrigin.y += viewSize.height;
	newTitleTextFieldOrigin.y += viewSize.height;
	[self addSubview:enclosedView];

//	NSMutableDictionary* animationDict = [NSMutableDictionary dictionaryWithCapacity:3];
//	[animationDict setObject:self forKey:NSViewAnimationTargetKey];
//	[animationDict setObject:[NSValue valueWithRect:boxFrame] forKey:NSViewAnimationStartFrameKey];
//	NSRect newBoxFrame = NSMakeRect(newBoxOrigin.x, newBoxOrigin.y, newBoxSize.width, newBoxSize.height);
//	[animationDict setObject:[NSValue valueWithRect:newBoxFrame] forKey:NSViewAnimationEndFrameKey];
//
//	NSViewAnimation *theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:animationDict, nil]];
//    [theAnim setDuration:.5];
//    [theAnim setAnimationCurve:NSAnimationEaseIn];
//    [theAnim startAnimation];
//    [theAnim release];

	[self setFrameOrigin:newBoxOrigin];
	[self setFrameSize:newBoxSize];
	
	[disclosureButton setFrameOrigin:newDisclosureButtonOrigin];
	[titleTextField setFrameOrigin:newTitleTextFieldOrigin];

	isExpanded = YES;
	[disclosureButton setState:NSOnState];
}

- (void)collapse:(id)sender;
{
	if(enclosedView==nil) return;
	if(!isExpanded) return;
	
	NSSize viewSize = [enclosedView frame].size;
	NSRect boxFrame = [self frame];
	NSRect disclosureButtonFrame = [disclosureButton frame];
	NSRect titleTextFieldFrame = [titleTextField frame];
	NSSize newBoxSize = boxFrame.size;
	NSPoint newBoxOrigin = boxFrame.origin;
	NSPoint newDisclosureButtonOrigin = disclosureButtonFrame.origin;
	NSPoint newTitleTextFieldOrigin = titleTextFieldFrame.origin;
	
	newBoxSize.height -= viewSize.height;
	newBoxOrigin.y += viewSize.height;
	newDisclosureButtonOrigin.y -= viewSize.height;
	newTitleTextFieldOrigin.y -= viewSize.height;
	[enclosedView removeFromSuperview];

	[self setFrameOrigin:newBoxOrigin];
	[self setFrameSize:newBoxSize];
		
	[disclosureButton setFrameOrigin:newDisclosureButtonOrigin];
	[titleTextField setFrameOrigin:newTitleTextFieldOrigin];

	isExpanded = NO;
	[disclosureButton setState:NSOffState];
}

- (BOOL)isExpanded;
{
	return isExpanded;
}

- (void)setEnabled:(BOOL)flag;
{
	[disclosureButton setEnabled:flag];
	NSColor *color;
	if(flag)
		color = enabledColor;
	else
		color = disabledColor;
	[titleTextField setTextColor:color];
}

- (void)setColor:(NSColor*)color;
{
	[disclosureButton setColor:color];
	[titleTextField setTextColor:color];
	
	if(enabledColor)[enabledColor release];
	if(disabledColor)[disabledColor release];
	enabledColor = [color retain];
	disabledColor = [color retain];
}

- (void)setDisabledColor:(NSColor*)color;
{
	if(disabledColor)[disabledColor release];
	disabledColor = [color retain];
}

@end
