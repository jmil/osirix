//
//  AreaDataSet.mm
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 5/04/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "AreaDataSet.h"

@implementation AreaDataSet

-(id)initWithOwnerChart:(GRChartView*)chart min:(GRLineDataSet*)min max:(GRLineDataSet*)max {
	self = [super initWithOwnerChart: chart];
	_min = min;
	_max = max;
	
	
	
	return self;
}

/*-(CDAnonymousStruct1)xIntervalAtIndex:(unsigned)index {
	NSLog(@"xIntervalAtIndex");
	CDAnonymousStruct1 retVal;
	retVal._field1 = 2.1;
	retVal._field2 = index*index;
	return retVal;
}

-(BOOL)supportsRangesOnAxis:(unsigned)axis {
	return NO;
//	BOOL r = [super supportsRangesOnAxis: axis];
//	NSLog(@"%x supportsRangesOnAxis:%d = %d", self, axis, r);
//	return r;
}*/

@end
