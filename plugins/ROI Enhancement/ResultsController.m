//
//  ResultsController.m
//  ResultsController
//
//  Created by rossetantoine on Tue Jun 15 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "ResultsController.h"

@implementation ResultsController

- (void)awakeFromNib
{
	NSLog( @"Nib loaded!");
}

- (id) initWithName:(NSString*) name
{
	self = [super initWithWindowNibName:@"ResultsROI"];
	
	[[self window] setDelegate:self];   //In order to receive the windowWillClose notification!
	
	[roiName setStringValue: name];
	
	return self;
}

- (void)windowWillClose:(NSNotification *)notification
{
	NSLog(@"Window will close.... and release his memory...");
	
	[self release];
}

- (ResultsView*) resultsView {return view;}

- (void) dealloc
{
    NSLog(@"My window is deallocating a pointer");
	
	[super dealloc];
}
@end
