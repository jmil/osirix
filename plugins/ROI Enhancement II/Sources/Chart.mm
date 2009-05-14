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
#import <DCMView.h>
#import "Options.h"

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
}

-(void)dealloc {
	[_areaDataSets release]; _areaDataSets = NULL;
	[super dealloc];
}

-(void)resetCursorRects {
	[self addCursorRect:[self bounds] cursor:[NSCursor crosshairCursor]];
}

-(void)constrainXRangeFrom:(unsigned)min to:(unsigned)max {
	_xMin = min; _xMax = max;
	[[self axes] setProperty:[NSNumber numberWithFloat:_xMin] forKey:GRAxesXPlotMin];
	[[self axes] setProperty:[NSNumber numberWithFloat:_xMin] forKey:GRAxesFixedXPlotMin];
	[[self axes] setProperty:[NSNumber numberWithFloat:_xMax] forKey:GRAxesXPlotMax];
	[[self axes] setProperty:[NSNumber numberWithFloat:_xMax] forKey:GRAxesFixedXPlotMax];
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

-(void)mouseDown:(NSEvent*)theEvent {
	_tracking = YES;
	[NSCursor hide];
	
	[self mouseDragged:theEvent];
}

-(void)mouseDragged:(NSEvent*)theEvent {
	_mousePoint = [self convertPointFromBase:[theEvent locationInWindow]]; _plotValueX = -1;
	[self setNeedsDisplay:YES];
}

-(void)mouseUp:(NSEvent*)theEvent {
	_tracking = [theEvent clickCount] != 2;
	[NSCursor unhide];
	if (!_tracking)
		[self setNeedsDisplay:YES];
}

// GRChartView delegate/dataSource

-(NSInteger)chart:(GRChartView*)chart numberOfElementsForDataSet:(GRDataSet*)dataSet {
	if ([[_interface options] xRangeMode] == XRange4thDimension)
		return [[_interface viewer] maxMovieIndex];
	else
		return [[[_interface viewer] pixList] count];
}

-(void)yValueForROIRec:(ROIRec*)roiRec element:(NSInteger)element min:(float*)min mean:(float*)mean max:(float*)max {
	if ([[_interface options] xRangeMode] == XRange4thDimension) {
		[[[[_interface viewer] pixList: element] objectAtIndex:[[[_interface viewer] imageView] curImage]] computeROI:[roiRec roi] :mean :NULL :NULL :min :max];
	} else {
		if ([[[_interface viewer] imageView] flippedData])
			element = [[[_interface viewer] pixList] count]-element-1;
		[[[[_interface viewer] pixList] objectAtIndex:element] computeROI:[roiRec roi] :mean :NULL :NULL :min :max];
	}
}

-(double)chart:(GRChartView*)chart yValueForDataSet:(GRDataSet*)dataSet element:(NSInteger)element {
	ROISel roiSel; ROIRec* roiRec = [[_interface roiList] findRecordByDataSet:dataSet sel:&roiSel];
	
	float min = 0, mean = 0, max = 0;
	[self yValueForROIRec:roiRec element:element min:&min mean:&mean max:&max];
	
	if (roiSel == ROIMin)
		return min;
	if (roiSel == ROIMean)
		return mean;
	if (roiSel == ROIMax)
		return max;
	
	return 0;
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

-(void)setDrawsBackground:(BOOL)drawsBackground {
	_drawsBackground = drawsBackground;
	[self setNeedsDisplay:YES];
}

-(BOOL)drawsBackground {
	return _drawsBackground;
}

-(void)drawTrackingGizmoAtPoint:(NSPoint)point withValue:(float)value {
	NSGraphicsContext* context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
	
	static NSDictionary* attributes = [[NSDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize:[NSFont smallSystemFontSize]-2], NSFontAttributeName, NULL] retain];
	
	NSString* string = [[_interface floatFormatter] stringFromNumber:[NSNumber numberWithFloat:value]];
	NSSize size = [string sizeWithAttributes:attributes];
	
	[NSBezierPath strokeLineFromPoint:point toPoint:NSMakePoint(point.x+5, point.y)];
	[NSBezierPath setDefaultLineWidth: 0];
	[[[NSColor whiteColor] colorWithAlphaComponent:.5] setFill];
	NSRect rect = NSMakeRect(point.x+4, point.y+2, size.width, size.height);
	[[NSBezierPath bezierPathWithRect:NSMakeRect(rect.origin.x-2, rect.origin.y, rect.size.width+3, rect.size.height-1)] fill];
	[string drawInRect:rect withAttributes:attributes];
	
	[context restoreGraphicsState];
}

-(BOOL)computeLayout {
	BOOL retVal = [super computeLayout];
	
	NSRect r = [[self axes] plotRect];
	float p0x = [[self axes] xValueAtPoint: NSMakePoint(r.origin.x, r.origin.y)];
	float p0y = [[self axes] yValueAtPoint: NSMakePoint(r.origin.x, r.origin.y)];
	float p1x = [[self axes] xValueAtPoint: NSMakePoint(r.origin.x+r.size.width, r.origin.y+r.size.height)];
	float p1y = [[self axes] yValueAtPoint: NSMakePoint(r.origin.x+r.size.width, r.origin.y+r.size.height)];
	
	const int tickWidth = 4;
//	float maxTicksPerPixel = 1./tickWidth;
	
	const int multiplySequence[] = {5,2};
	const int multiplySequenceLength = sizeof(multiplySequence)/sizeof(int);
	
	const float valueWidth = p1x-p0x;
	
	int sequenceIndex = 0;
	int ticksEveryValue = 1;
	while (valueWidth/ticksEveryValue > r.size.width/tickWidth)
		ticksEveryValue *= multiplySequence[sequenceIndex++%multiplySequenceLength];
	
	[[self axes] setProperty:[NSNumber numberWithInt:ticksEveryValue] forKey:GRAxesXMinorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:ticksEveryValue] forKey:GRAxesFixedXMinorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:ticksEveryValue*5] forKey:GRAxesXMajorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:ticksEveryValue*5] forKey:GRAxesFixedXMajorUnit];	
	
	const float valueHeight = p1y-p0y;
	
	sequenceIndex = 0;
	ticksEveryValue = 1;
	while (valueHeight/ticksEveryValue > r.size.height/tickWidth)
		ticksEveryValue *= multiplySequence[sequenceIndex++%multiplySequenceLength];
	
	[[self axes] setProperty:[NSNumber numberWithInt:ticksEveryValue] forKey:GRAxesYMinorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:ticksEveryValue] forKey:GRAxesFixedYMinorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:ticksEveryValue*5] forKey:GRAxesYMajorUnit];
	[[self axes] setProperty:[NSNumber numberWithInt:ticksEveryValue*5] forKey:GRAxesFixedYMajorUnit];	
	
	return retVal | [super computeLayout]; // yes, again
}

-(void)drawRect:(NSRect)dirtyRect {
	// update the view's layout
	if ([self needsLayout])
		[self computeLayout];
	
	// draw first the background and the areas
	
	NSGraphicsContext* context = [NSGraphicsContext currentContext];

	if (_drawsBackground) {
		[context saveGraphicsState];
		[(NSColor*)[[self axes] propertyForKey:GRAxesBackgroundColor] setFill];
		[NSBezierPath fillRect:[[self axes] plotRect]];
		[context restoreGraphicsState];
	}
	
	for (unsigned i = 0; i < [_areaDataSets count]; ++i)
		[[_areaDataSets objectAtIndex:i] drawRect: dirtyRect];
	
	[super drawRect:dirtyRect];
	
	if (_tracking) {
		if (_plotValueX == -1)
			_plotValueX = round([[self axes] xValueAtPoint:_mousePoint]);
		float plotPointX = [[self axes] locationForXValue:_plotValueX yValue:0].x;
		if (_plotValueX >= _xMin && _plotValueX <= _xMax) {
			// line
			[context saveGraphicsState];
			[[NSBezierPath bezierPathWithRect:[[self axes] plotRect]] setClip];
			[[NSColor blackColor] setStroke];
			[NSBezierPath setDefaultLineWidth: 1];
			[NSBezierPath strokeLineFromPoint:NSMakePoint(plotPointX, [[self axes] plotRect].origin.y) toPoint:NSMakePoint(plotPointX, [[self axes] plotRect].origin.y+[[self axes] plotRect].size.height)];
			[context restoreGraphicsState];
			// values
			[context saveGraphicsState];
			[[NSColor blackColor] setStroke];
			[NSBezierPath setDefaultLineWidth: 1];
			for (unsigned i = 0; i < [[_interface roiList] countOfDisplayedROIs]; ++i) {
				ROIRec* roiRec = [[_interface roiList] displayedROIRec:i];
				
				float min = 0, mean = 0, max = 0;
				[self yValueForROIRec:roiRec element:_plotValueX min:&min mean:&mean max:&max];
				
				if ([[_interface options] min])
					[self drawTrackingGizmoAtPoint:[[self axes] locationForXValue:_plotValueX yValue:min] withValue:min];
				if ([[_interface options] mean])
					[self drawTrackingGizmoAtPoint:[[self axes] locationForXValue:_plotValueX yValue:mean] withValue:mean];
				if ([[_interface options] max])
					[self drawTrackingGizmoAtPoint:[[self axes] locationForXValue:_plotValueX yValue:max] withValue:max];
			}
			[context restoreGraphicsState];
		}
	}
	
	[[_interface options] updateYRange];
	[[_interface options] updateXRange];
}

-(NSString*)csv:(BOOL)includeHeaders {
	NSMutableString* csv = [[NSMutableString alloc] initWithCapacity:512];
	
	if (includeHeaders) {
		[csv appendString:@"\"index\","];
		for (unsigned i = 0; i < [[_interface roiList] countOfDisplayedROIs]; ++i) {
			NSMutableString* name = [[[[[[_interface roiList] displayedROIRec:i] roi] name] mutableCopy] autorelease];
			[name replaceOccurrencesOfString:@"\"" withString:@"\"\"" options:0 range:NSMakeRange(0, [name length])];
			if ([[_interface options] mean])
				[csv appendFormat: @"\"%@ mean\",", name];
			if ([[_interface options] min] || [[_interface options] fill])
				[csv appendFormat: @"\"%@ min\",", name];
			if ([[_interface options] max] || [[_interface options] fill])
				[csv appendFormat: @"\"%@ max\",", name];
		}

		[csv deleteCharactersInRange:NSMakeRange([csv length]-1, 1)];
		[csv appendString:@"\n"];
	}
	
	for (int x = _xMin; x <= _xMax; ++x) {
		[csv appendFormat:@"\"%d\",", x];
		for (unsigned i = 0; i < [[_interface roiList] countOfDisplayedROIs]; ++i) {
			ROIRec* roiRec = [[_interface roiList] displayedROIRec:i];
			if ([[_interface options] mean])
				[csv appendFormat: @"\"%f\",", [self chart:self yValueForDataSet:[roiRec meanDataSet] element:x]];
			if ([[_interface options] min] || [[_interface options] fill])
				[csv appendFormat: @"\"%f\",", [self chart:self yValueForDataSet:[roiRec minDataSet] element:x]];
			if ([[_interface options] max] || [[_interface options] fill])
				[csv appendFormat: @"\"%f\",", [self chart:self yValueForDataSet:[roiRec maxDataSet] element:x]];
		}
		
		[csv deleteCharactersInRange:NSMakeRange([csv length]-1, 1)];
		[csv appendString:@"\n"];
	}
	
	return [csv autorelease];
}

@end
