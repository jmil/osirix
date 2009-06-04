//
//  StepByStep.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 02/04/07.
//  Copyright 2007. All rights reserved.
//

#import "StepByStep.h"


@implementation StepByStep

- (id)init
{
	if(![super init]) return nil;

	steps = [[NSMutableArray arrayWithCapacity:0] retain];
	currentStepIndex = 0;
	return self;
}

- (id)delegate
{
	return delegate;
}
 
- (void)setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}


- (Step*)addStepWithTitle:(NSString*)aTitle enclosedView:(NSView*)aView;
{
	Step *step = [[Step alloc] initWithTitle:aTitle enclosedView:aView];
	[steps addObject:step];
	[view addStep:step];
	return step;
}

- (Step*)addOptionalStepWithTitle:(NSString*)aTitle enclosedView:(NSView*)aView;
{
	Step *step = [[Step alloc] initWithTitle:aTitle enclosedView:aView];
	[step setOptional];
	[steps addObject:step];
	[view addStep:step];
	return step;
}

// Use

- (void)showFirstStep;
{
	currentStepIndex = 0;
	[view expandStepAtIndex:0];
	[delegate willBeginStep:[self currentStep]];
	[view adjustWindow];
}

- (void)showCurrentStep;
{
	[view expandStepAtIndex:currentStepIndex];
	[delegate willBeginStep:[self currentStep]];
}

- (void)setCurrentStep:(Step*)step;
{
	if(![steps containsObject:step]) return;
	currentStepIndex = [steps indexOfObject:step];
	[self enableSteps];
	if(delegate)[delegate willBeginStep:[self currentStep]];
}

- (Step*)currentStep;
{
	return [steps objectAtIndex:currentStepIndex];
}

- (BOOL)hasNextStep;
{
	return currentStepIndex<[steps count]-1;
}

- (BOOL)hasPreviousStep;
{
	return currentStepIndex>0;
}

//- (Step*)nextStep;
//{
//	if(![self hasNextStep]) return nil;
//	return [steps objectAtIndex:currentStepIndex+1];
//}

- (IBAction)nextStep:(id)sender;
{
	if(![delegate shouldValidateStep:[self currentStep]]) return;
	
	if(![self hasNextStep])
	{
		// we are at the end of the step by step...
		[delegate validateStep:[self currentStep]];
	}
	else
	{
		[delegate validateStep:[self currentStep]];
		[[self currentStep] setIsDone:YES];
		currentStepIndex++;
		[view expandStepAtIndex:currentStepIndex];
		[delegate willBeginStep:[self currentStep]];
	}
	[view adjustWindow];
}

- (IBAction)previousStep:(id)sender;
{
	if(![self hasPreviousStep]) return;
	else
	{
		currentStepIndex--;
		[view expandStepAtIndex:currentStepIndex];
		[delegate willBeginStep:[self currentStep]];
	}
}

- (IBAction)skipStep:(id)sender;
{
	if([[self currentStep] isNecessary]) return;
	if(![self hasNextStep])
	{
		// we are at the end of the step by step...
		// do something
	}
	else
	{
		currentStepIndex++;
		[view expandStepAtIndex:currentStepIndex];
		[delegate willBeginStep:[self currentStep]];
	}
}

- (void)enableSteps;
{
	int i;
	BOOL disable = NO;
	
	[view setStepAtIndex:currentStepIndex enabled:YES];
	if([[self currentStep] isNecessary] && ![[self currentStep] isDone]) disable = YES;
		
	for(i=currentStepIndex+1; i<[steps count]; i++)
	{
		if(disable)
		{
			[view setStepAtIndex:i enabled:NO];
			[view collapseStepAtIndex:i];
		}
		else
			[view setStepAtIndex:i enabled:YES];
		if([[steps objectAtIndex:i] isNecessary] && ![[steps objectAtIndex:i] isDone]) disable = YES;
	}
	[view adjustWindow];
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

- (StepByStepView*)view;
{
	return view;
}

@end
