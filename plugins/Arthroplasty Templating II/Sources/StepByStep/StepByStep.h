//
//  StepByStep.h
//  StepByStepFramework
//
//  Created by Joris Heuberger on 02/04/07.
//  Copyright 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StepByStepView.h"

@interface StepByStep : NSObject {
	NSMutableArray *steps;
	IBOutlet StepByStepView *view;
	unsigned currentStepIndex;
	IBOutlet id delegate;
}

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

// Creation
- (Step*)addStepWithTitle:(NSString*)aTitle enclosedView:(NSView*)aView;
- (Step*)addOptionalStepWithTitle:(NSString*)aTitle enclosedView:(NSView*)aView;

- (void)showFirstStep;
- (void)showCurrentStep;
- (void)setCurrentStep:(Step*)step;
- (Step*)currentStep;

// Use
- (BOOL)hasNextStep;
- (BOOL)hasPreviousStep;
- (IBAction)nextStep:(id)sender;
- (IBAction)previousStep:(id)sender;
- (IBAction)skipStep:(id)sender;

- (void)enableSteps;

- (void)reset;

- (StepByStepView*)view;

@end

@interface NSObject (StepByStepDelegateMethod)

- (void)willBeginStep:(Step*)step;
- (BOOL)shouldValidateStep:(Step*)step;
- (void)validateStep:(Step*)step;

@end