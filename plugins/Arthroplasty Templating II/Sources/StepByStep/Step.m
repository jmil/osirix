//
//  Step.m
//  StepByStepFramework
//
//  Created by Joris Heuberger on 02/04/07.
//  Copyright 2007. All rights reserved.
//

#import "Step.h"


@implementation Step

- (id)initWithTitle:(NSString*)aTitle enclosedView:(NSView*)aView;
{
	if(![super init]) return nil;
	enclosedView = [aView retain];
	title = [aTitle retain];
	isNecessary = YES;
	isDone = NO;
	return self;
}

- (void)dealloc
{
	[enclosedView release];
	[title release];
	[super dealloc];
}

- (void)setOptional;
{
	isNecessary = NO;
}

- (NSView*)enclosedView;
{
	return enclosedView;
}

- (NSString*)title;
{
	return title;
}

- (BOOL)isNecessary;
{
	return isNecessary;
}

- (void)setIsDone:(BOOL)done;
{
	isDone = done;
}

- (BOOL)isDone;
{
	return isDone;
}

@end
