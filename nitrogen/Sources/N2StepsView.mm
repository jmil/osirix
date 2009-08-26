//
//  SBSView.m
//  Nitrogen Framework
// 
//  Created by Joris Heuberger on 30/03/07.
//  Modified by Alessandro Volz on 15/07/09.
//  Copyright 2007-2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2StepsView.h>
#import <Nitrogen/N2Steps.h>
#import <Nitrogen/N2StepView.h>
#import <Nitrogen/N2LayoutManager.h>

@implementation N2StepsView

-(id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
	[self awakeFromNib];
    return self;
}

-(void)awakeFromNib {
	[super awakeFromNib];
	
	//	_views = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
	//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewWillExpand:) name:N2DisclosureBoxWillExpandNotification object:NULL];
	//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidExpandCollapse:) name:N2DisclosureBoxDidExpandNotification object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidToggle:) name:N2DisclosureBoxDidToggleNotification object:NULL];
	//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidExpandCollapse:) name:N2DisclosureBoxDidCollapseNotification object:NULL];
    
	N2LayoutManager* layout = [[N2LayoutManager alloc] initWithControlSize:NSMiniControlSize];
	[layout setStretchesToFill:YES];
	[layout setForcesSuperviewSize:YES];
	[self setLayout:[layout autorelease]];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepsDidAddStep:) name:N2StepsDidAddStepNotification object:_steps];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepsWillRemoveStep:) name:N2StepsWillRemoveStepNotification object:_steps];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

/*-(void)recomputeSubviewFramesAndAdjustSizes {
	static const CGFloat interStepViewYDelta = 1;
	NSRect frame = [self frame];

	CGFloat h = 0;
	for (int i = [_views count]-1; i >= 0; --i)
		h += [[_views objectAtIndex:i] frame].size.height+interStepViewYDelta;
		
	NSWindow* window = [self window];
	NSRect wf = [window frame], nwf = wf;
	NSRect wc = [window contentRectForFrameRect:wf], nwc = wc;
	nwc.size.height = h+frame.origin.y*2;
	nwf.size = [window frameRectForContentRect:nwc].size;
	nwf.origin.y -= nwf.size.height-wf.size.height;
	[window setFrame:nwf display:YES];

	// move StepViews
	CGFloat y = 0;
	for (int i = [_views count]-1; i >= 0; --i) {
		N2StepView* stepView = [_views objectAtIndex:i];
		NSSize stepSize = [stepView frame].size;
		[stepView setFrame:NSMakeRect(0,y,frame.size.width,stepSize.height)];
		y += stepSize.height+interStepViewYDelta;
	}
	
	y -= interStepViewYDelta;
	
	// resize N2StepsView
	frame.size.height = y;
	[self setFrame:frame];
}*/

-(void)stepsDidAddStep:(NSNotification*)notification {
	N2Step* step = [[notification userInfo] objectForKey:N2StepsNotificationStep];
	N2StepView* view = [[[N2StepView alloc] initWithStep:step] autorelease];
	
	[self addRow];
	[self addSubview:view];
	
	[self recalculate];
}

-(N2StepView*)stepViewForStep:(N2Step*)step {
	for (NSUInteger i = 0; i < [_n2rows count]; ++i) {
		NSArray* row = [_n2rows objectAtIndex:i];
		for (N2StepView* view in row)
			if ([view isKindOfClass:[N2StepView class]] && [view step] == step)
				return view;
	}
	
	return NULL;
}

-(void)stepsWillRemoveStep:(NSNotification*)notification {
	N2Step* step = [[notification userInfo] objectForKey:N2StepsNotificationStep];
	N2StepView* view = [self stepViewForStep:step];
	
	[view removeFromSuperview];
	
	[self recalculate];
}

-(void)stepViewDidToggle:(NSNotification*)notification {
	[self recalculate];
}

@end
