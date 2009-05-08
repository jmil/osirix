//
//  Chart.mm
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 4/27/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "Chart.h"
#import <DCMPix.h>
#import <GRAxes.h>
#import <GRLineDataSet.h>
#import "AreaDataSet.h"
#import "Interface.h"
#import <ViewerController.h>
#import "ROIList.h"
#import <ROI.h>
#import "Options.h"

NSString* ChartChanged = @"ChartChanged";

@implementation Chart
@synthesize xMin = _xMin, xMax = _xMax;

-(void)awakeFromNib {
	[super awakeFromNib];
	
	_areaDataSets = [[NSMutableArray arrayWithCapacity:0] retain];
	
	[self setDelegate:self];
	[self setDataSource:self];

	[self setProperty:[NSNumber numberWithBool:NO] forKey:GRChartDrawBackground];
	[[self axes] setProperty:[NSFont labelFontOfSize:[NSFont smallSystemFontSize]] forKey:GRAxesLabelFont];
	[[self axes] setProperty:[NSArray array] forKey:GRAxesMinorLineDashPattern];
//	[[self axes] setProperty:[NSNumber numberWithFloat:0.5] forKey:GRAxesMinorLineWidth];
	[[self axes] setProperty:[NSNumber numberWithInt:1] forKey:GRAxesXMinorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:1] forKey:GRAxesFixedXMinorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:5] forKey:GRAxesXMajorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:5] forKey:GRAxesFixedXMajorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:10] forKey:GRAxesYMinorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:10] forKey:GRAxesFixedYMinorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:50] forKey:GRAxesYMajorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:50] forKey:GRAxesFixedYMajorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:50] forKey:GRAxesFixedYMajorUnit];
}

-(void)dealloc {
//	[_areaDataSets release];
	[super dealloc];
}

-(void)postChangedNotification {
	[[NSNotificationCenter defaultCenter] postNotificationName:ChartChanged object:self];
}

-(void)constrainXRangeFrom:(unsigned)min to:(unsigned)max {
	_xMin = min; _xMax = max;
	[[self axes] setProperty:[NSNumber numberWithFloat:_xMin] forKey:GRAxesXPlotMin];
	[[self axes] setProperty:[NSNumber numberWithFloat:_xMin] forKey:GRAxesFixedXPlotMin];
	[[self axes] setProperty:[NSNumber numberWithFloat:_xMax] forKey:GRAxesXPlotMax];
	[[self axes] setProperty:[NSNumber numberWithFloat:_xMax] forKey:GRAxesFixedXPlotMax];
	[self postChangedNotification];
}

-(GRLineDataSet*)createOwnedLineDataSet {
	GRLineDataSet* dataSet = [[GRLineDataSet alloc] initWithOwnerChart:self];
	[dataSet setProperty:[NSNumber numberWithBool:NO] forKey:GRDataSetDrawMarkers];
	return [dataSet autorelease];
}

-(AreaDataSet*)createOwnedAreaDataSetFrom:(GRLineDataSet*)min to:(GRLineDataSet*)max {
	return [[[AreaDataSet alloc] initWithOwnerChart:self min:min max:max] autorelease];
}

-(void)refresh:(ROIRec*)roiRec {
	// Set the color of the plot
	if (roiRec) {
		RGBColor rgb = [[roiRec roi] rgbcolor];
		NSColor* color = [NSColor colorWithDeviceRed:float(rgb.red)/0xffff green:float(rgb.green)/0xffff blue:float(rgb.blue)/0xffff alpha:1];
		[[roiRec minDataSet] setProperty:color forKey:GRDataSetPlotColor];
		[[roiRec meanDataSet] setProperty:color forKey:GRDataSetPlotColor];
		[[roiRec maxDataSet] setProperty:color forKey:GRDataSetPlotColor];
	}
	
	if (!roiRec || [roiRec displayed])
		[self setNeedsToReloadData:YES];
}

- (void)reloadDataInRange:(NSRange)fp8 {
	[super reloadDataInRange:fp8];
	[self postChangedNotification];
}

// GRChartView delegate/dataSource

-(NSInteger)chart:(GRChartView*)chart numberOfElementsForDataSet:(GRDataSet*)dataSet {
	return [[[_interface viewer] pixList] count];
}

-(double)chart:(GRChartView*)chart yValueForDataSet:(GRDataSet*)dataSet element:(NSInteger)element {
	ROISel roiSel; ROIRec* roiRec = [[_interface roiList] findRecordByDataSet:dataSet sel:&roiSel];
	float min = 0, mean = 0, max = 0; [[[[_interface viewer] pixList] objectAtIndex:element] computeROI:[roiRec roi] :&mean :NULL :NULL :&min :&max];
	
	if (roiSel == ROIMin)
		return min;
	if (roiSel == ROIMean)
		return mean;
	if (roiSel == ROIMax)
		return max;
	
	return sin(element); // TODO: change
}

-(NSString*)chart:(GRChartView*)chart yLabelForAxes:(GRAxes*)axes value:(double)value defaultLabel:(NSString*)defaultLabel {
	return [[_interface decimalFormatter] stringFromNumber:[NSNumber numberWithDouble:value]];
}

//+(BOOL)instancesRespondToSelector:(SEL)aSelector {
//	BOOL responds = [super instancesRespondToSelector:aSelector];
//	if (!responds) NSLog(@"+Chart doesn't respond to -  %@", NSStringFromSelector(aSelector));
//	return responds;
//}
//
//-(BOOL)respondsToSelector:(SEL)aSelector {
//	BOOL responds = [super respondsToSelector:aSelector];
//	if (!responds) NSLog(@"-Chart doesn't respond to - %@", NSStringFromSelector(aSelector));
//	return responds;
//}

// options

-(void)freeYRange {
	[[self axes] setProperty:NULL forKey:GRAxesYPlotMin]; // [NSNumber numberWithInt:0]
	[[self axes] setProperty:NULL forKey:GRAxesYPlotMax];
	[[self axes] setProperty:NULL forKey:GRAxesFixedYPlotMin];
	[[self axes] setProperty:NULL forKey:GRAxesFixedYPlotMax];
}

-(void)constrainYRangeFrom:(float)min {
	[[self axes] setProperty:[NSNumber numberWithFloat:min] forKey:GRAxesYPlotMin];
	[[self axes] setProperty:NULL forKey:GRAxesYPlotMax];
	[[self axes] setProperty:[NSNumber numberWithFloat:min] forKey:GRAxesFixedYPlotMin];
	[[self axes] setProperty:NULL forKey:GRAxesFixedYPlotMax];
}

-(void)constrainYRangeFrom:(float)min to:(float)max {
	// TODO: zero is interpreted as "default", find how to set to real zero
	min -= 0.00000001; max += 0.00000001;
	[[self axes] setProperty:[NSNumber numberWithFloat:min] forKey:GRAxesYPlotMin];
	[[self axes] setProperty:[NSNumber numberWithFloat:max] forKey:GRAxesYPlotMax];
	[[self axes] setProperty:[NSNumber numberWithFloat:min] forKey:GRAxesFixedYPlotMin];
	[[self axes] setProperty:[NSNumber numberWithFloat:max] forKey:GRAxesFixedYPlotMax];
}

// areas

-(void)addAreaDataSet:(AreaDataSet*)dataSet {
	[_areaDataSets addObject:[dataSet retain]];
	[self setNeedsDisplay:YES];
}

-(void)removeAreaDataSet:(AreaDataSet*)dataSet {
	[_areaDataSets removeObject:dataSet];
	[dataSet release];
}

-(void)setDrawBackground:(BOOL)drawBackground {
	_drawBackground = drawBackground;
	[self setNeedsDisplay:YES];
}

-(BOOL)drawBackground {
	return _drawBackground;
}

-(void)drawRect:(NSRect)dirtyRect {
	// update the view's structure
	[super drawRect:NSMakeRect(0, 0, 0, 0)];
	
	// draw first the background and the areas
	
	if (_drawBackground) {
		NSGraphicsContext* context = [NSGraphicsContext currentContext];
		[context saveGraphicsState];

		[(NSColor*)[[self axes] propertyForKey:GRAxesBackgroundColor] setFill];
		[NSBezierPath fillRect:[[self axes] plotRect]];

		[context restoreGraphicsState];
	}
	
	for (unsigned i = 0; i < [_areaDataSets count]; ++i)
		[[_areaDataSets objectAtIndex:i] drawRect: dirtyRect];
	
	[super drawRect:dirtyRect];
	
	[[_interface options] updateYRange];
	[[_interface options] updateXRange];
}

-(NSString*)csv:(BOOL)includeHeaders {
	NSMutableString* csv = [[[NSMutableString alloc] initWithCapacity:512] autorelease];
	
	if (includeHeaders) {
		[csv appendString:@"index\t"];
		for (unsigned i = 0; i < [[_interface roiList] countOfDisplayedROIs]; ++i) {
			NSMutableString* name = [[[[[[_interface roiList] displayedROIRec:i] roi] name] mutableCopy] autorelease];
			[name replaceOccurrencesOfString:@" " withString:@"_" options:0 range:NSMakeRange(0, [name length])];
			if ([[_interface options] mean])
				[csv appendFormat: @"%@_mean\t", name];
			if ([[_interface options] min] || [[_interface options] fill])
				[csv appendFormat: @"%@_min\t", name];
			if ([[_interface options] max] || [[_interface options] fill])
				[csv appendFormat: @"%@_max\t", name];
		}
	}
	
	[csv deleteCharactersInRange:NSMakeRange([csv length]-1, 1)];
	[csv appendString:@"\n"];
	
	for (int x = _xMin; x <= _xMax; ++x) {
		[csv appendFormat:@"%d\t", x];
		for (unsigned i = 0; i < [[_interface roiList] countOfDisplayedROIs]; ++i) {
			ROIRec* roiRec = [[_interface roiList] displayedROIRec:i];
			if ([[_interface options] mean])
				[csv appendFormat: @"%f\t", [self chart:self yValueForDataSet:[roiRec meanDataSet] element:x]];
			if ([[_interface options] min] || [[_interface options] fill])
				[csv appendFormat: @"%f\t", [self chart:self yValueForDataSet:[roiRec minDataSet] element:x]];
			if ([[_interface options] max] || [[_interface options] fill])
				[csv appendFormat: @"%f\t", [self chart:self yValueForDataSet:[roiRec maxDataSet] element:x]];
		}
		
		[csv deleteCharactersInRange:NSMakeRange([csv length]-1, 1)];
		[csv appendString:@"\n"];
	}
	
	return csv;
}

@end
