#pragma once

//
//  AreaDataSet.h
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 5/04/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GRLineDataSet, GRChartView, Chart;

@interface AreaDataSet : NSObject {
	GRLineDataSet* _min;
	GRLineDataSet* _max;
	Chart* _chart;
	BOOL _displayed;
}

@property(readonly) GRLineDataSet* min;
@property(readonly) GRLineDataSet* max;
@property BOOL displayed;

-(id)initWithOwnerChart:(Chart*)chart min:(GRLineDataSet*)min max:(GRLineDataSet*)max;

@end
