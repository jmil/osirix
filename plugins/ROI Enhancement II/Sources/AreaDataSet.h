#pragma once

//
//  AreaDataSet.h
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 5/04/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GRDataSet.h>
@class GRChartView, GRLineDataSet;

@interface AreaDataSet : GRDataSet {
	GRLineDataSet* _min;
	GRLineDataSet* _max;
}

-(id)initWithOwnerChart:(GRChartView*)chart min:(GRLineDataSet*)min max:(GRLineDataSet*)max;

@end
