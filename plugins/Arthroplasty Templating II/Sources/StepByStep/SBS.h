//
//  StepByStep.h
//  StepByStepFramework
//  Created by Joris Heuberger on 02/04/07.
//  Copyright 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SBSStep, SBSView;

@interface SBS : NSObject {
	NSMutableArray* _steps;
	IBOutlet SBSView* _view;
	SBSStep* _currentStep;
	IBOutlet id _delegate;
}

@property(assign) id delegate;
@property(assign) SBSStep* currentStep;

-(void)addStep:(SBSStep*)step;
-(void)enableDisableSteps;

-(BOOL)hasNextStep;
-(BOOL)hasPreviousStep;

-(IBAction)nextStep:(id)sender;
-(IBAction)previousStep:(id)sender;
-(IBAction)skipStep:(id)sender;
-(IBAction)stepValueChanged:(id)sender;
-(IBAction)reset:(id)sender;

@end


@interface NSObject (StepByStepDelegateMethod)

-(void)stepByStep:(SBS*)sbs willBeginStep:(SBSStep*)step;
-(void)stepByStep:(SBS*)sbs valueChanged:(id)sender;
-(BOOL)stepByStep:(SBS*)sbs shouldValidateStep:(SBSStep*)step;
-(void)stepByStep:(SBS*)sbs validateStep:(SBSStep*)step;

@end