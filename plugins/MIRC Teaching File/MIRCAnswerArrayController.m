//
//  MIRCAnswerArrayController.m
//  TeachingFile
//
//  Created by Lance Pysher on 8/20/05.
//  Copyright 2005 Macrad, LLC. All rights reserved.
//

#import "MIRCAnswerArrayController.h"
#import "MIRCAnswer.h"


@implementation MIRCAnswerArrayController

/*
- (id)newObject{
	NSLog(@"new Answer");
	id answer = [super newObject];
	[answer setValue:[_controller question] forKey:@"question"];
	return answer;
}
*/

- (IBAction)answerAction:(id)sender{
	if ([sender isKindOfClass:[NSSegmentedControl class]]) {
		switch ([sender selectedSegment]) {
			case 0: [self add:sender];
					break;
			case 1: [self remove:sender];
					break;
		}
	}
}

- (IBAction)add:(id)sender{
	[super add:sender];
	NSLog(@"answers: %@", [self arrangedObjects]);
}

@end
