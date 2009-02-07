//
//  ResultsView.h
//  ROI-Enhancement
//
//  Created by rossetantoine on Thu Jun 17 2004.
//  Copyright (c) 2004 Antoine Rosset. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface ResultsView : NSView {

	float   *minValues, *maxValues, *meanValues;
	long	arraySize;
}

-(void) setArrays: (long) nb :(float*) meanPtr :(float*)minPtr :(float*)maxPtr;

@end
