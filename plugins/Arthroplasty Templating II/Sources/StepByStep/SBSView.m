//
//  SBSView.m
//  StepByStepFramework
//  Created by Joris Heuberger on 30/03/07.
//  Modified by Alessandro Volz on 15/07/09.
//  Copyright 2007-2009. All rights reserved.
//

#import "StepByStep/SBSView.h"
#import "StepByStep/SBS.h"
#import "StepByStep/SBSStepView.h"

@implementation SBSView

-(id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];

	_stepViews = [[NSMutableArray arrayWithCapacity:0] retain];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidExpandNotification:) name:@"StepViewDidExpand" object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewWillExpandNotification:) name:@"StepViewWillExpand" object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidCollapseNotification:) name:@"StepViewDidCollapse" object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidToggleNotification:) name:@"StepViewDidToggle" object:NULL];
    
    return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_stepViews release];
	[super dealloc];
}

-(void)recomputeSubviewFramesAndAdjustSizes {
	NSRect frame = [self frame];
	static const CGFloat interStepViewYDelta = 1;
	CGFloat y = 0; 
	
	// move StepViews
	for (int i = [_stepViews count]-1; i >= 0; --i) {
		SBSStepView* stepView = [_stepViews objectAtIndex:i];
		NSSize stepSize = [stepView frame].size;
		[stepView setFrame:NSMakeRect(0,y,frame.size.width,stepSize.height)];
		y += stepSize.height+interStepViewYDelta;
	}
	
	// resize SBSView
	y -= interStepViewYDelta;
	frame.size.height = y;
	[self setFrame:frame];
	
	// resize window
	NSSize size = [[[self window] contentView] frame].size;
	size.height = y+frame.origin.y*2;
	[[self window] setContentSize:size];
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

-(void)collapseAllExcept:(SBSStepView*)stepView {
	for (int i = [_stepViews count]-1; i >= 0; --i)
		if ([_stepViews objectAtIndex:i] != stepView)
			[self collapseStep:[[_stepViews objectAtIndex:i] step]];
}

-(void)stepViewWillExpandNotification:(NSNotification*)notification {
	[self collapseAllExcept:[notification object]];
}

-(void)stepViewDidExpandNotification:(NSNotification*)notification {
	[_controller setCurrentStep:[[notification object] step]];
}

-(void)stepViewDidCollapseNotification:(NSNotification*)notification {
}

-(void)stepViewDidToggleNotification:(NSNotification*)notification {
	[self recomputeSubviewFramesAndAdjustSizes];
}

-(void)setStep:(SBSStep*)step enabled:(BOOL)enabled; {
	[[self stepViewForStep:step] setEnabled:enabled];
}

@end
