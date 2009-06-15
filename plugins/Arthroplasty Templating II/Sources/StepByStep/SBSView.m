//
//  SBSView.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import "SBSView.h"
#import "StepByStep.h"

@implementation SBSView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
	{
        stepViews = [[NSMutableArray arrayWithCapacity:0] retain];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidExpandNotification:) name:@"StepViewDidExpand" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewWillExpandNotification:) name:@"StepViewWillExpand" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidCollapseNotification:) name:@"StepViewDidCollapse" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidToggleNotification:) name:@"StepViewDidToggle" object:nil];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[stepViews release];
	[super dealloc];
}

#define SPACE_BETWEEN_STEPVIEWS 3

- (void)addStep:(Step*)step; {
	StepView *stepView = [[StepView alloc] initWithStep:step];
	NSRect newFrame = [stepView frame];
	newFrame.size.width = [self frame].size.width;
	[stepView setFrame:newFrame];
	
	// now we need to move each StepView
//	int i;
//	NSRect frameI;
//	float newStepHeight = [stepView frame].size.height + SPACE_BETWEEN_STEPVIEWS;
//	for(i=[stepViews count]-1; i>=0; i--)
//	{
//		frameI = [[stepViews objectAtIndex:i] frame];
//		frameI.origin.y += newStepHeight;
//		[[stepViews objectAtIndex:i] setFrameOrigin:frameI.origin];
//	}

	[stepViews addObject:stepView];
	[self addSubview:stepView];
	[self computeStepViewFrames];
	
	[stepView release];
}


- (void)collapseAllExcept:(StepView*)stepView {
	for (int i = [stepViews count]-1; i >= 0; --i) {
		StepView* currentStepView = [stepViews objectAtIndex:i];
		if(![currentStepView isEqualTo:stepView] && [currentStepView isExpanded])
			[currentStepView collapse:self];
	}
}

- (void)computeStepViewFrames;
{
	int i;
	
	NSRect frameI, frame0;
	frame0 = [[stepViews lastObject] frame];
	frame0.origin.y = 0.0;
	frame0.size.width = [self frame].size.width;
	[[stepViews lastObject] setFrame:frame0];

	for(i=[stepViews count]-2; i>=0; i--)
	{
		frameI = [[stepViews objectAtIndex:i] frame];
		frameI.origin.y = frame0.origin.y + frame0.size.height + SPACE_BETWEEN_STEPVIEWS;
		frameI.size.width = [self frame].size.width;
		[[stepViews objectAtIndex:i] setFrame:frameI];
		frame0 = frameI;
	}

	float height = [[stepViews objectAtIndex:0] frame].origin.y + [[stepViews objectAtIndex:0] frame].size.height;
//	float viewHeight = [self frame].size.height;
	
//	float shift = viewHeight - height;	
//	for(i=[stepViews count]-1; i>=0; i--)
//	{
//		frameI = [[stepViews objectAtIndex:i] frame];
//		frameI.origin.y += shift;
//		[[stepViews objectAtIndex:i] setFrame:frameI];
//	}

	NSRect newFrame = [self frame];
	newFrame.size.height = height;
	float originShift = [self frame].size.height - newFrame.size.height;
	newFrame.origin.y += originShift;
	[self setFrame:newFrame];
}

- (void)adjustWindow;
{
	NSRect newWindowFrame = [[self window] frame];
	newWindowFrame.size.height = [self frame].size.height+60;

	float originShift = [[self window] frame].size.height - newWindowFrame.size.height;
	newWindowFrame.origin.y += originShift;
	[[self window] setFrame:newWindowFrame display:YES animate:NO];
	[[self window] display];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
	[super resizeSubviewsWithOldSize:oldBoundsSize];
	
	int i;
	NSRect frameI;

	float height = [[stepViews objectAtIndex:0] frame].origin.y + [[stepViews objectAtIndex:0] frame].size.height;
	float viewHeight = [self frame].size.height;
	float shift = viewHeight - height;
	
	for(i=[stepViews count]-1; i>=0; i--)
	{
		frameI = [[stepViews objectAtIndex:i] frame];
		frameI.origin.y += shift;
		frameI.size.width = [self frame].size.width;
		[[stepViews objectAtIndex:i] setFrame:frameI];
	}
}

- (void)expandStepAtIndex:(unsigned)index {
	[[stepViews objectAtIndex:index] expand:self];
}

- (void)collapseStepAtIndex:(unsigned)index {
	[[stepViews objectAtIndex:index] collapse:self];
}

- (void)stepViewWillExpandNotification:(NSNotification*)notification;
{
	[self collapseAllExcept:[notification object]];
}

- (void)stepViewDidExpandNotification:(NSNotification*)notification;
{
	[controller setCurrentStep:[[notification object] step]];
	[self computeStepViewFrames];
}

- (void)stepViewDidCollapseNotification:(NSNotification*)notification;
{
	[self computeStepViewFrames];
}

- (void)stepViewDidToggleNotification:(NSNotification*)notification;
{
	[self adjustWindow];
}

- (void)setStepAtIndex:(unsigned)index enabled:(BOOL)enabled;
{
	[[stepViews objectAtIndex:index] setEnabled:enabled];
}

@end
