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
#import <Nitrogen/N2ColumnLayout.h>
#import <Nitrogen/N2DisclosureButtonCell.h>
#import <Nitrogen/N2ColumnDescriptor.h>

@implementation N2StepsView

-(id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
	[self awakeFromNib];
    return self;
}

-(void)awakeFromNib {
	NSArray* columnDescriptors = [NSArray arrayWithObject:[N2ColumnDescriptor descriptor]];
	N2ColumnLayout* layout = [[[N2ColumnLayout alloc] initForView:self columnDescriptors:columnDescriptors controlSize:NSMiniControlSize] autorelease];
	[layout setForcesSuperviewHeight:YES];
	[layout setSeparation:NSZeroSize];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepsDidAddStep:) name:N2StepsDidAddStepNotification object:_steps];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepsWillRemoveStep:) name:N2StepsWillRemoveStepNotification object:_steps];
	
	if (_steps)
		for (N2Step* step in [_steps content])
			[self stepsDidAddStep:[NSNotification notificationWithName:N2StepsDidAddStepNotification object:_steps userInfo:[NSDictionary dictionaryWithObject:step forKey:N2StepsNotificationStep]]];
	
	[[self layout] layOut];
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
	
	[view setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepViewFrameDidChange:) name:NSViewFrameDidChangeNotification object:view];
	
	[(N2ColumnLayout*)_layout appendLine:[NSArray arrayWithObject:view]];
	
	[self layOut];
}

-(N2StepView*)stepViewForStep:(N2Step*)step {
	for (NSView* view in [self subviews])
		if ([view isKindOfClass:[N2StepView class]] && [(N2StepView*)view step] == step)
			return (N2StepView*)view;
	return NULL;
}

-(void)stepsWillRemoveStep:(NSNotification*)notification {
	N2Step* step = [[notification userInfo] objectForKey:N2StepsNotificationStep];
	N2StepView* view = [self stepViewForStep:step];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:view];
	[view removeFromSuperview];
	
	[[self layout] layOut];
}

-(void)stepViewFrameDidChange:(NSNotification*)notification {
	[[self layout] layOut];
}

-(void)layOut {
	[_layout layOut];
}

-(NSSize)optimalSize {
	return [_layout optimalSize];
}

-(NSSize)optimalSizeForWidth:(CGFloat)width {
	return [_layout optimalSizeForWidth:width];
}

@end
