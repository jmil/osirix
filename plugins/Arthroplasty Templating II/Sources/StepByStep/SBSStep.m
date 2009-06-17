//
//  Step.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 02/04/07.
//  Copyright 2007. All rights reserved.
//

#import "SBSStep.h"


@implementation SBSStep
@synthesize enclosedView = _enclosedView, title = _title, isNecessary = _isNecessary, isDone = _isDone;

-(id)initWithTitle:(NSString*)aTitle enclosedView:(NSView*)aView {
	_enclosedView = [aView retain];
	_title = [aTitle retain];
	
	_isNecessary = YES;
	_isDone = NO;
	
	return self;
}

-(void)dealloc {
	[_enclosedView release];
	[_title release];
	[super dealloc];
}

@end
