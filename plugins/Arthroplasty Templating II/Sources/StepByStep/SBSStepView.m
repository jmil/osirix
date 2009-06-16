//
//  StepView.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import "StepByStep/SBSStepView.h"
#import "StepByStep/SBSStep.h"


@implementation SBSStepView
@synthesize step = _step;

-(id)initWithStep:(SBSStep*)step {
	self = [super initWithTitle:[step title] content:[step enclosedView]];
	_step = [step retain];
	return self;
}

-(void)dealloc {
	[_step release];
	[super dealloc];
}

-(void)toggle:(id)sender {
	[super toggle:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StepViewDidToggle" object:self];
}

-(void)expand:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StepViewWillExpand" object:self];
	[super expand:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StepViewDidExpand" object:self];
}

-(void)collapse:(id)sender {
	[super collapse:sender];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"StepViewDidCollapse" object:self];
}

@end
