//
//  MIRCCaseController.m
//  TeachingFile
//
//  Created by Lance Pysher on 8/8/05.
//  Copyright 2005 Macrad, LLC. All rights reserved.
//

#import "MIRCCaseController.h"
#import "MIRCController.h"

@implementation MIRCCaseController

- (void)dealloc{
	[self save];
	[_caseName release];
	[super dealloc];
}



- (IBAction)controlAction: (id) sender{	
	if ([sender selectedSegment] == 0) {
		NSLog(@"add");
		[self add:self];
	}
	else if ([sender selectedSegment] == 1) {
			[self remove:self];
	}
}

- (void)save{
	NSLog(@"save Case");
	[mircController save];
}








@end
