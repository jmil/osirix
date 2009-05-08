//
//  AreaDataSet.mm
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 5/04/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "AreaDataSet.h"
#import <GRLineDataSet.h>
#import <GRAxes.h>
#import "Chart.h"

@implementation AreaDataSet
@synthesize min = _min, max = _max, displayed = _displayed;

-(id)initWithOwnerChart:(Chart*)chart min:(GRLineDataSet*)min max:(GRLineDataSet*)max {
	self = [super init];
	_chart = chart;
	_min = [min retain];
	_max = [max retain];
	return self;
}

- (void) dealloc {
	
	[_min release];
	[_max release];
	
	[super dealloc];
}

-(void)setDisplayed:(BOOL)displayed {
	_displayed = displayed;
	[_chart setNeedsDisplay: YES];
}

-(void)drawRect:(NSRect)dirtyRect {
	NSGraphicsContext* context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
	
	// only draw if displayed
	if (!_displayed)
		return;
	
	[[[_min propertyForKey: GRDataSetPlotColor] colorWithAlphaComponent: 0.25] setFill];
	
	NSBezierPath* path = [NSBezierPath bezierPath];
	
	for (int x = [_chart xMin]; x <= [_chart xMax]; ++x) {
		double y = [[_min dataSource] chart:_chart yValueForDataSet:_min element:x];
		NSPoint p = [[_chart axes] locationForXValue:x yValue:y];
		if ([path isEmpty])
			[path moveToPoint:p];
		else [path lineToPoint:p];
	}
	
	for (int x = [_chart xMax]; x >= [_chart xMin]; --x) {
		double y = [[_max dataSource] chart:_chart yValueForDataSet:_max element:x];
		NSPoint p = [[_chart axes] locationForXValue:x yValue:y];
		[path lineToPoint:p];
	}
	
	[path closePath];
	[path fill];
	
	[context restoreGraphicsState];
}

@end
