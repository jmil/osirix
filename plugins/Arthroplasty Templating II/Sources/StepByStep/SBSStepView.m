//
//  StepView.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import "SBSStepView.h"
#import "SBSStep.h"


@implementation SBSStepView
@synthesize step = _step;

-(id)initWithStep:(SBSStep*)step {
	self = [super initWithTitle:[step title] content:[step enclosedView]];
	_step = [step retain];
	return self;
}

@end
