#pragma once

//
//  Chart.h
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 4/27/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GRChartView.h>
@class Interface, ROIRec;
@class GRLineDataSet;
//@class AreaDataSet;

extern NSString* ChartChanged;

@interface Chart : GRChartView {
	IBOutlet Interface* _interface;
	unsigned _xFrom, _xTo;
	NSMutableArray* _areaDataSets;
	BOOL _drawBackground;
}

@property(readonly) unsigned xFrom, xTo;
@property BOOL drawBackground;

-(GRLineDataSet*)createOwnedLineDataSet;
//-(AreaDataSet*)createOwnedAreaDataSetFrom:(GRLineDataSet*)min to:(GRLineDataSet*)max;
-(void)refresh:(ROIRec*)dataSet;
-(void)constrainXRangeFrom:(unsigned)from to:(unsigned)to;
-(void)freeYRange;
-(void)constrainYRangeFrom:(float)from;
-(void)constrainYRangeFrom:(float)from to:(float)to;

//-(void)addAreaDataSet:(AreaDataSet*)dataSet;
//-(void)removeAreaDataSet:(AreaDataSet*)dataSet;	

@end
