//
//  SBSView.m
//  StepByStepFramework
//  Created by Joris Heuberger on 30/03/07.
//  Modified by Alessandro Volz on 15/07/09.
//  Copyright 2007-2009. All rights reserved.
//

#import "SBSView.h"
#import "SBS.h"
#import "SBSStepView.h"

@implementation SBSView

-(id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];

	_stepViews = [[NSMutableArray arrayWithCapacity:0] retain];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidExpand:) name:@"DisclosureBoxDidExpand" object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewWillExpand:) name:@"DisclosureBoxWillExpand" object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidCollapse:) name:@"DisclosureBoxDidCollapse" object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidToggle:) name:@"DisclosureBoxDidToggle" object:NULL];
    
    return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_stepViews release];
	[super dealloc];
}

-(void)recomputeSubviewFramesAndAdjustSizes {
	static const CGFloat interStepViewYDelta = 1;
	NSRect frame = [self frame];

	CGFloat h = 0;
	for (int i = [_stepViews count]-1; i >= 0; --i)
		h += [[_stepViews objectAtIndex:i] frame].size.height+interStepViewYDelta;
		
	NSWindow* window = [self window];
	NSRect wf = [window frame], nwf = wf;
	NSRect wc = [window contentRectForFrameRect:wf], nwc = wc;
	nwc.size.height = h+frame.origin.y*2;
	nwf.size = [window frameRectForContentRect:nwc].size;
	nwf.origin.y -= nwf.size.height-wf.size.height;
	[window setFrame:nwf display:YES];

	// move StepViews
	CGFloat y = 0;
	for (int i = [_stepViews count]-1; i >= 0; --i) {
		SBSStepView* stepView = [_stepViews objectAtIndex:i];
		NSSize stepSize = [stepView frame].size;
		[stepView setFrame:NSMakeRect(0,y,frame.size.width,stepSize.height)];
		y += stepSize.height+interStepViewYDelta;
	}
	
	y -= interStepViewYDelta;
	
	// resize SBSView
	frame.size.height = y;
	[self setFrame:frame];
}

-(void)addStep:(SBSStep*)step; {
	SBSStepView* stepView = [[SBSStepView alloc] initWithStep:step];
	[_stepViews addObject:stepView];
	[self addSubview:stepView];
	[stepView release];
	
	[self recomputeSubviewFramesAndAdjustSizes];
}

-(SBSStepView*)stepViewForStep:(SBSStep*)step {
	for (unsigned i = 0; i < [_stepViews count]; ++i) {
		SBSStepView* stepView = [_stepViews objectAtIndex:i];
		if ([stepView step] == step)
			return stepView;
	}
	
	return NULL;
}

-(void)expandStep:(SBSStep*)step {
	[[self stepViewForStep:step] expand:self];
}

-(void)collapseStep:(SBSStep*)step {
	[[self stepViewForStep:step] collapse:self];
}

-(BOOL)isExpanded:(SBSStep*)step {
	return [[self stepViewForStep:step] isExpanded];
}

-(BOOL)isCollapsed:(SBSStep*)step {
	return ![[self stepViewForStep:step] isExpanded];
}

-(void)collapseAllExcept:(SBSStepView*)stepView {
	for (int i = [_stepViews count]-1; i >= 0; --i)
		if ([_stepViews objectAtIndex:i] != stepView)
			[self collapseStep:[[_stepViews objectAtIndex:i] step]];
}

-(void)stepViewWillExpand:(NSNotification*)notification {
	[self collapseAllExcept:[notification object]];
}

-(void)stepViewDidExpand:(NSNotification*)notification {
	[_controller setCurrentStep:[[notification object] step]];
}

-(void)stepViewDidCollapse:(NSNotification*)notification {
}

-(void)stepViewDidToggle:(NSNotification*)notification {
	[self recomputeSubviewFramesAndAdjustSizes];
}

-(void)setStep:(SBSStep*)step enabled:(BOOL)enabled; {
	[[self stepViewForStep:step] setEnabled:enabled];
}

@end
