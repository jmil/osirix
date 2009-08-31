//
//  SBSView.m
//  Nitrogen Framework
// 
//  Created by Joris Heuberger on 30/03/07.
//  Modified by Alessandro Volz on 15/07/09.
//  Copyright 2007-2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2StepsView.h>
#import <Nitrogen/N2Step.h>
#import <Nitrogen/N2Steps.h>
#import <Nitrogen/N2StepView.h>
#import <Nitrogen/N2LayoutManager.h>
#import <Nitrogen/N2DisclosureButtonCell.h>

@implementation N2StepsView
@synthesize foreColor = _foreColor, controlSize = _controlSize;

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
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidToggle:) name:N2DisclosureBoxDidToggleNotification object:NULL];
	//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewDidExpandCollapse:) name:N2DisclosureBoxDidCollapseNotification object:NULL];
    
	N2LayoutManager* layout = [[N2LayoutManager alloc] initWithControlSize:NSMiniControlSize];
	[layout setStretchesToFill:YES];
	[layout setForcesSuperviewSize:YES];
	[layout setSeparation:NSZeroSize];
	[self setLayout:[layout autorelease]];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepsDidAddStep:) name:N2StepsDidAddStepNotification object:_steps];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepsWillRemoveStep:) name:N2StepsWillRemoveStepNotification object:_steps];
	
	if (_steps)
		for (N2Step* step in [_steps content])
			[self stepsDidAddStep:[NSNotification notificationWithName:N2StepsDidAddStepNotification object:_steps userInfo:[NSDictionary dictionaryWithObject:step forKey:N2StepsNotificationStep]]];
	
	[self recalculate];
}

-(void)setForeColor:(NSColor*)color {
	if (_foreColor) [_foreColor release];
	_foreColor = [color retain];
	for (N2StepView* view in [self subviews])
		[[[view titleCell] attributes] setValue:[self foreColor] forKey:NSForegroundColorAttributeName];	
}

-(void)setControlSize:(NSControlSize)controlSize {
	_controlSize = controlSize;
	for (N2StepView* view in [self subviews])
		[[[view titleCell] attributes] setValue:[NSFont labelFontOfSize:[NSFont systemFontSizeForControlSize:controlSize]] forKey:NSFontAttributeName];	
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if (_foreColor) [_foreColor release];
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
	
	[[[view titleCell] attributes] addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															 [self foreColor], NSForegroundColorAttributeName,
															 [NSFont labelFontOfSize:[NSFont systemFontSizeForControlSize:[self controlSize]]], NSFontAttributeName,
															 NULL]];
	[_layout didAddSubview:[step enclosedView]];
	
	[view setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewFrameDidChange:) name:NSViewFrameDidChangeNotification object:view];
	
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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:view];
	[view removeFromSuperview];
	
	[self recalculate];
}

-(void)stepViewFrameDidChange:(NSNotification*)notification {
	[self recalculate];
}

@end
