//
//  StepByStep.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 02/04/07.
//  Copyright 2007. All rights reserved.
//

#import "StepByStep/SBS.h"
#import "StepByStep/SBSStep.h"
#import "StepByStep/SBSView.h"

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

-(void)addStep:(Step*)step {
	[_steps addObject:step];
	[_view addStep:step];
	if ([_steps count] == 1)
		[self setCurrentStep:step];
}

// enables the steps until a necessary and non done step is encountered
-(void)enableDisableSteps {
	BOOL enable = YES;
	
	for (unsigned i = [_steps indexOfObject:_currentStep]; i < [_steps count]; ++i) {
		Step* step = [_steps objectAtIndex:i];
		[_view setStep:step enabled:enable];
		if (!enable)
			[_view collapseStep:step];
		if ([step isNecessary] && ![step isDone])
			enable = NO;
	}
}

-(void)setCurrentStep:(Step*)step {
	if (![_steps containsObject:step])
		return;
	
	if (_currentStep)
		[_view collapseStep:_currentStep];
	
	_currentStep = step;
	[_currentStep expandStep:_currentStep];
	[self enableDisableSteps];
	
	if (_delegate)
		[_delegate willBeginStep:[self currentStep]];
}

-(BOOL)hasNextStep {
	return [_steps indexOfObject:_currentStep] < [_steps count]-1;
}

-(BOOL)hasPreviousStep {
	return [_steps indexOfObject:_currentStep] > 0;
}

-(IBAction)nextStep:(id)sender {
	if (![_delegate shouldValidateStep:[self currentStep]])
		return;
	
	[_delegate validateStep:[self currentStep]];
	[[self currentStep] setIsDone:YES];

	if (![self hasNextStep])
		return;
	
	[self setCurrentStep:[_steps objectAtIndex:[_steps indexOfObject:_currentStep]+1]];
}

-(IBAction)previousStep:(id)sender {
	if (![self hasPreviousStep])
		return;
	
	_currentStepIndex--;
	[_view expandStepAtIndex:_currentStepIndex];
	[_delegate willBeginStep:[self currentStep]];
}

-(IBAction)skipStep:(id)sender {
	if ([[self currentStep] isNecessary])
		return;
	
	if (![self hasNextStep]) {
		// we are at the end of the step by step... do something
	} else {
		++_currentStepIndex;
		[_view expandStepAtIndex:_currentStepIndex];
		[_delegate willBeginStep:[self currentStep]];
	}
}

- (void)reset;
{
	int i;	
	for(i=0; i<[steps count]; i++)
	{
		[[steps objectAtIndex:i] setIsDone:NO];
	}
	currentStepIndex = 0;
	[self enableSteps];
}

- (SBSView*)view;
{
	return view;
}

@end
