//
//  N2Steps.mm
//  Nitrogen Framework
//
//  Created by Joris Heuberger on 02/04/07.
//  Edited by Alessandro Volz since 21/05/09.
//  Copyright 2007-2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2Steps.h>
#import <Nitrogen/N2Step.h>

NSString* N2StepsDidAddStepNotification = @"N2StepsDidAddStepNotification";
NSString* N2StepsWillRemoveStepNotification = @"N2StepsWillRemoveStepNotification";
NSString* N2StepsNotificationStep = @"N2StepsNotificationStep";

@implementation N2Steps
@synthesize delegate = _delegate, currentStep = _currentStep;//, view = _view;

-(id)init {
	self = [super init];
	
	return self;
}

-(void)addObject:(id)obj {
	[super addObject:obj];
	[[NSNotificationCenter defaultCenter] postNotificationName:N2StepsDidAddStepNotification object:self userInfo:[NSDictionary dictionaryWithObject:obj forKey:N2StepsNotificationStep]];
}

-(void)removeObject:(id)obj {
	[[NSNotificationCenter defaultCenter] postNotificationName:N2StepsWillRemoveStepNotification object:self userInfo:[NSDictionary dictionaryWithObject:obj forKey:N2StepsNotificationStep]];
	[super removeObject:obj];
}

// enables the steps until a necessary and non done step is encountered
-(void)enableDisableSteps {
	BOOL enable = YES;
	for (unsigned i = [[self content] indexOfObject:_currentStep]; i < [[self content] count]; ++i) {
		N2Step* step = [[self content] objectAtIndex:i];
		[step setIsEnabled:enable];
		if ([step isNecessary] && ![step isDone])
			enable = NO;
	}
}

-(void)setCurrentStep:(N2Step*)step {
	if (step == _currentStep)
		return;
	
	if (![[self content] containsObject:step])
		return;
	
	if (_currentStep)
		[_currentStep setIsActive:NO];
	
	_currentStep = step;
	
	[_currentStep setIsActive:YES];
	[self enableDisableSteps];
	
//	if (_delegate)
//		[_delegate stepByStep:self willBeginStep:[self currentStep]];
}

-(BOOL)hasNextStep {
	return [[self content] indexOfObject:_currentStep] < [[self content] count]-1;
}

-(BOOL)hasPreviousStep {
	return [[self content] indexOfObject:_currentStep] > 0;
}

-(IBAction)nextStep:(id)sender {
//	if (![_delegate stepByStep:self shouldValidateStep:_currentStep])
//		return;
	
//	[_delegate stepByStep:self validateStep:[self currentStep]];
	[_currentStep setIsDone:YES];

	if (![self hasNextStep])
		return;
	
	[self setCurrentStep:[[self content] objectAtIndex:[[self content] indexOfObject:_currentStep]+1]];
}

-(IBAction)previousStep:(id)sender {
	if (![self hasPreviousStep])
		return;
	
	[self setCurrentStep:[[self content] objectAtIndex:[[self content] indexOfObject:_currentStep]-1]];
}

-(IBAction)skipStep:(id)sender {
	if ([[self currentStep] isNecessary])
		return;
	
	if (![self hasNextStep])
		return;
	
	[self setCurrentStep:[[self content] objectAtIndex:[[self content] indexOfObject:_currentStep]+1]];
}

-(IBAction)stepValueChanged:(id)sender {
//	if (_delegate)
//		[_delegate stepByStep:self valueChanged:sender];
}

-(IBAction)reset:(id)sender; {
	for (unsigned i = 0; i < [[self content] count]; ++i)
		[[[self content] objectAtIndex:i] setIsDone:NO];
	
	[self setCurrentStep:[[self content] objectAtIndex:0]];
}

@end
