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
@class AreaDataSet;

@interface Chart : GRChartView {
	IBOutlet Interface* _interface;
	int _xMin, _xMax;
	NSMutableArray* _areaDataSets;
	BOOL _drawBackground;
	BOOL _tracking;
	NSPoint _mousePoint;
	float _plotValueX;
}

@property(readonly) int xMin, xMax;
@property BOOL drawBackground;

-(GRLineDataSet*)createOwnedLineDataSet;
-(AreaDataSet*)createOwnedAreaDataSetFrom:(GRLineDataSet*)min to:(GRLineDataSet*)max;
-(void)refresh:(ROIRec*)dataSet;
-(void)constrainXRangeFrom:(unsigned)from to:(unsigned)to;
-(void)freeYRange;
-(void)constrainYRangeFrom:(float)min;
-(void)constrainYRangeFrom:(float)min to:(float)max;

-(void)addAreaDataSet:(AreaDataSet*)dataSet;
-(void)removeAreaDataSet:(AreaDataSet*)dataSet;

-(double)chart:(GRChartView*)chart yValueForDataSet:(GRDataSet*)dataSet element:(NSInteger)element;

-(NSString*)csv:(BOOL)includeHeaders;

@end
