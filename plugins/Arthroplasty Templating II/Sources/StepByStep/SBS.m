//
//  StepByStep.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 02/04/07.
//  Copyright 2007. All rights reserved.
//

#import "SBS.h"
#import "SBSStep.h"
#import "SBSView.h"

@implementation SBS
@synthesize delegate = _delegate, currentStep = _currentStep;

-(id)init {
	self = [super init];

	_steps = [[NSMutableArray arrayWithCapacity:8] retain];
	
	return self;
}

-(void)dealloc {
	[_steps release];
	[super dealloc];
}

-(void)addStep:(SBSStep*)step {
	[_steps addObject:step];
	[_view addStep:step];
	if ([_steps count] == 1)
		[self setCurrentStep:step];
}

// enables the steps until a necessary and non done step is encountered
-(void)enableDisableSteps {
	BOOL enable = YES;
	
	for (unsigned i = [_steps indexOfObject:_currentStep]; i < [_steps count]; ++i) {
		SBSStep* step = [_steps objectAtIndex:i];
		[_view setStep:step enabled:enable];
		if (!enable && [_view isExpanded:step])
			[_view collapseStep:step];
		if ([step isNecessary] && ![step isDone])
			enable = NO;
	}
}

-(void)setCurrentStep:(SBSStep*)step {
	if (step == _currentStep)
		return;
	
	if (![_steps containsObject:step])
		return;
	
	if (_currentStep && [_view isExpanded:_currentStep])
		[_view collapseStep:_currentStep];
	
	_currentStep = step;
	if ([_view isCollapsed:_currentStep])
		[_view expandStep:_currentStep];
	
	[self enableDisableSteps];
	[_view recomputeSubviewFramesAndAdjustSizes];
	
	if (_delegate)
		[_delegate stepByStep:self willBeginStep:[self currentStep]];
}

-(BOOL)hasNextStep {
	return [_steps indexOfObject:_currentStep] < [_steps count]-1;
}

-(BOOL)hasPreviousStep {
	return [_steps indexOfObject:_currentStep] > 0;
}

-(IBAction)nextStep:(id)sender {
	if (![_delegate stepByStep:self shouldValidateStep:[self currentStep]])
		return;
	
	[_delegate stepByStep:self validateStep:[self currentStep]];
	[[self currentStep] setIsDone:YES];

	if (![self hasNextStep])
		return;
	
	[self setCurrentStep:[_steps objectAtIndex:[_steps indexOfObject:_currentStep]+1]];
}

-(IBAction)previousStep:(id)sender {
	if (![self hasPreviousStep])
		return;
	
	[self setCurrentStep:[_steps objectAtIndex:[_steps indexOfObject:_currentStep]-1]];
}

-(IBAction)skipStep:(id)sender {
	if ([[self currentStep] isNecessary])
		return;
	
	if (![self hasNextStep])
		return;
	
	[self setCurrentStep:[_steps objectAtIndex:[_steps indexOfObject:_currentStep]+1]];
}

-(IBAction)reset:(id)sender; {
	for (unsigned i = 0; i < [_steps count]; ++i)
		[[_steps objectAtIndex:i] setIsDone:NO];
	
	[self setCurrentStep:[_steps objectAtIndex:0]];
}

@end
