//
//  AreaDataSet.mm
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 5/04/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "AreaDataSet.h"

@implementation AreaDataSet
@synthesize min = _min, max = _max, displayed = _displayed;

-(id)initWithOwnerChart:(Chart*)chart min:(GRLineDataSet*)min max:(GRLineDataSet*)max {
	self = [super init];
	_chart = chart;
	_min = min;
	_max = max;
	return self;
}

-(void)setDisplayed:(BOOL)displayed {
	_displayed = displayed;
	[_chart setNeedsDisplay: YES];
}

@end
