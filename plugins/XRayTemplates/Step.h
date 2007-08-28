//
//  Step.h
//  StepByStepFramework
//
//  Created by Joris Heuberger on 02/04/07.
//  Copyright 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Step : NSObject {
	NSView *enclosedView;
	NSString *title;
	BOOL isNecessary;
	BOOL isDone;
}

- (id)initWithTitle:(NSString*)aTitle enclosedView:(NSView*)aView;

- (void)setOptional;

- (NSView*)enclosedView;
- (NSString*)title;
- (BOOL)isNecessary;

- (void)setIsDone:(BOOL)done;
- (BOOL)isDone;

//- (Step*)previousStep;
//- (Step*)nextStep;
//- (BOOL)hasPreviousStep;
//- (BOOL)hasNextStep;

@end
