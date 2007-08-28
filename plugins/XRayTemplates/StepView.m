//
//  StepView.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import "StepView.h"


@implementation StepView

- (id)init
{
	NSRect minFrame = NSMakeRect(0.0, 0.0, 100.0, 35.0);
	self = [super initWithFrame:minFrame];
	return self;
}

- (id)initWithStep:(Step*)aStep;
{
	[self init];
	[self setStep:aStep];
	return self;
}

- (void)setStep:(Step*)aStep;
{
	step = [aStep retain];
	[self setEnclosedView:[step enclosedView]];
	[self setTitle:[step title]];
}

- (Step*)step;
{
	return step;
}

- (void)dealloc
{
	if(step)[step release];
	[super dealloc];
}

- (void)toggle:(id)sender;
{
	[super toggle:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StepViewDidToggle" object:self];
}

- (void)expand:(id)sender;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StepViewWillExpand" object:self];
	[super expand:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StepViewDidExpand" object:self];
}

- (void)collapse:(id)sender;
{
	[super collapse:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StepViewDidCollapse" object:self];
}

@end
