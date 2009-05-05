//
//  Options.mm
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 4/28/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "Options.h"
#import "Chart.h"
#import "Interface.h"
#import "ROIList.h"
#import <GRAxes.h>

@implementation Options
@synthesize userDefaults = _userDefaults;

-(void)saveUserDefaults {
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:_userDefaults forName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
}

-(BOOL)defaultBool:(NSString*)key otherwise:(BOOL)otherwise {
	NSNumber* value = [_userDefaults valueForKey:key];
	if (value)
		return [value boolValue];
	return otherwise;
}

-(void)setDefaultBool:(BOOL)value forKey:(NSString*)key {
	[_userDefaults setValue:[NSNumber numberWithBool:value] forKey:key];
	[self saveUserDefaults];
}

-(int)defaultFloat:(NSString*)key otherwise:(float)otherwise {
	NSNumber* value = [_userDefaults valueForKey:key];
	if (value)
		return [value floatValue];
	return otherwise;
}

-(void)setDefaultFloat:(float)value forKey:(NSString*)key {
	[_userDefaults setValue:[NSNumber numberWithFloat:value] forKey:key];
	[self saveUserDefaults];
}

-(NSColor*)defaultColor:(NSString*)key otherwise:(NSColor*)otherwise {
	NSData* value = [_userDefaults valueForKey:key];
	if (value)
		return [NSUnarchiver unarchiveObjectWithData:value];
	return otherwise;
}

-(void)setDefaultColor:(NSColor*)value forKey:(NSString*)key {
	[_userDefaults setValue:[NSArchiver archivedDataWithRootObject:value] forKey:key];
	[self saveUserDefaults];
}

-(void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chartChanged:) name:ChartChanged object:[_interface chart]];
	
	_userDefaults = [[[[NSUserDefaults standardUserDefaults] persistentDomainForName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]] mutableCopy] retain];
	if (!_userDefaults) _userDefaults = [[NSMutableDictionary alloc] init];
	
	// curves
	[_meanCurve setState:[self defaultBool:@"curves.mean" otherwise:[_meanCurve state]]];
	[_minCurve setState:[self defaultBool:@"curves.min" otherwise:[_minCurve state]]];
	[_maxCurve setState:[self defaultBool:@"curves.max" otherwise:[_maxCurve state]]];
	[_minmaxFill setState:[self defaultBool:@"curves.minmax.fill" otherwise:[_minmaxFill state]]];
	
	// ranges
	[_logscaleYRange setState:[self defaultBool:@"ranges.y.logscale" otherwise:[_logscaleYRange state]]];
	[_constrainYRange setState:[self defaultBool:@"ranges.y.constrain" otherwise:[_constrainYRange state]]];
	if ([_constrainYRange state]) {
		[_yRangeMin setFloatValue:[self defaultFloat:@"ranges.y.min" otherwise:0]];
		[_yRangeMax setFloatValue:[self defaultFloat:@"ranges.y.max" otherwise:0]];
	}
	
	// decorations
	[_xAxis setState:[self defaultBool:@"decorations.x.axis" otherwise:[_xAxis state]]];
	[_xTicks setState:[self defaultBool:@"decorations.x.ticks" otherwise:[_xTicks state]]];
	[_xGrid setState:[self defaultBool:@"decorations.x.grid" otherwise:[_xGrid state]]];
	[_xLabels setState:[self defaultBool:@"decorations.x.labels" otherwise:[_xLabels state]]];
	[_yAxis setState:[self defaultBool:@"decorations.y.axis" otherwise:[_yAxis state]]];
	[_yTicks setState:[self defaultBool:@"decorations.y.ticks" otherwise:[_yTicks state]]];
	[_yGrid setState:[self defaultBool:@"decorations.y.grid" otherwise:[_yGrid state]]];
	[_yLabels setState:[self defaultBool:@"decorations.y.labels" otherwise:[_yLabels state]]];
	[_background setState:[self defaultBool:@"decorations.background" otherwise:[_background state]]];
	
	[_majorLineColor setColor:[self defaultColor:@"decorations.majorlinecolor" otherwise:[_majorLineColor color]]];
	[_minorLineColor setColor:[self defaultColor:@"decorations.minorlinecolor" otherwise:[_minorLineColor color]]];
	[_backgroundColor setColor:[self defaultColor:@"decorations.background.color" otherwise:[_backgroundColor color]]];
	
	[self curvesChanged:NULL];
	
	[self yRangeChanged:NULL];
	[self decorationsChanged:NULL];

	[self chartChanged:NULL];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

-(void)chartChanged:(NSNotification*)notification {
	[self yRangeChanged:NULL]; // update the displayed numeric range
}

-(IBAction)curvesChanged:(id)sender {
	[[_interface roiList] changedMin:[_minCurve state] mean:[_meanCurve state] max:[_maxCurve state] fill:[_minmaxFill state]];
	
	if (sender == _meanCurve)
		[self setDefaultBool:[_meanCurve state] forKey:@"curves.mean"];
	if (sender == _minCurve)
		[self setDefaultBool:[_minCurve state] forKey:@"curves.min"];
	if (sender == _maxCurve)
		[self setDefaultBool:[_maxCurve state] forKey:@"curves.max"];
	if (sender == _minmaxFill)
		[self setDefaultBool:[_minmaxFill state] forKey:@"curves.minmax.fill"];
}

-(IBAction)xRangeChanged:(id)sender {
}

-(IBAction)yRangeChanged:(id)sender {
	BOOL logscale = [_logscaleYRange state];
	BOOL constrain = [_constrainYRange state];
	
	// affect the GUI
	[_constrainYRange setEnabled:!logscale];
	[_yRangeMin setEnabled:!logscale && constrain];
	[_yRangeMax setEnabled:!logscale && constrain];
	
	[[[_interface chart] axes] setProperty:(logscale? GRAxesLog10Scale : GRAxesLinearScale) forKey:GRAxesYAxisScale];

	// affect the range
	if (logscale) {
		[[_interface chart] constrainYRangeFrom:1];
	} else
		if (constrain)
			[[_interface chart] constrainYRangeFrom:[_yRangeMin floatValue] to:[_yRangeMax floatValue]];
		else [[_interface chart] freeYRange];
	
	[self updateYRange];
	
	// defaults
	[self setDefaultBool:constrain forKey:@"ranges.y.constrain"];
	[self setDefaultBool:[_logscaleYRange state] forKey:@"ranges.y.logscale"];
	if (constrain) {
		[self setDefaultFloat:[_yRangeMin floatValue] forKey:@"ranges.y.min"];
		[self setDefaultFloat:[_yRangeMax floatValue] forKey:@"ranges.y.max"];
	}
}

-(void)updateYRange {
	if ([_logscaleYRange state] || ![_constrainYRange state]) { // display current range
		NSRect r = [[[_interface chart] axes] plotRect];
		[_yRangeMin setFloatValue:[[[_interface chart] axes] yValueAtPoint: NSMakePoint(r.origin.x, r.origin.y)]];
		[_yRangeMax setFloatValue:[[[_interface chart] axes] yValueAtPoint: NSMakePoint(r.origin.x, r.origin.y+r.size.height)]];
	}
}

-(IBAction)decorationsChanged:(id)sender {
	Chart* chart = [_interface chart];
	GRAxes* axes = [chart axes];
	
	if (!sender || sender == _xAxis) {
		BOOL active = [_xAxis state];
		[axes setProperty:[NSNumber numberWithBool:active] forKey:GRAxesDrawXAxis];
		[_xTicks setEnabled:active];
		[_xGrid setEnabled:active];
	}
	
	if (!sender || sender == _xTicks) {
		[axes setProperty:[NSNumber numberWithBool:[_xTicks state]] forKey:GRAxesDrawXMajorTicks];
		[axes setProperty:[NSNumber numberWithBool:[_xTicks state]] forKey:GRAxesDrawXMinorTicks];
	}
	
	if (!sender || sender == _xGrid) {
		[axes setProperty:[NSNumber numberWithBool:[_xGrid state]] forKey:GRAxesDrawXMajorLines];
		[axes setProperty:[NSNumber numberWithBool:[_xGrid state]] forKey:GRAxesDrawXMinorLines];
	}
	
	[_xLabels setEnabled:[_xAxis state] && ([_xTicks state] || [_xGrid state])];
	if (!sender || sender == _xLabels || sender == _xTicks || sender == _xGrid || sender == _xAxis)
		[axes setProperty:[NSNumber numberWithBool:[_xLabels state] && ([_xAxis state] && ([_xTicks state] || [_xGrid state]))] forKey:GRAxesDrawXLabels];
	
	if (!sender || sender == _yAxis) {
		BOOL state = [_yAxis state];
		[axes setProperty:[NSNumber numberWithBool:state] forKey:GRAxesDrawYAxis];
		[_yTicks setEnabled:state];
		[_yGrid setEnabled:state];
	}
	
	if (!sender || sender == _yTicks) {
		[axes setProperty:[NSNumber numberWithBool:[_yTicks state]] forKey:GRAxesDrawYMajorTicks];
		[axes setProperty:[NSNumber numberWithBool:[_yTicks state]] forKey:GRAxesDrawYMinorTicks];
	}
	
	if (!sender || sender == _yGrid) {
		[axes setProperty:[NSNumber numberWithBool:[_yGrid state]] forKey:GRAxesDrawYMajorLines];
		[axes setProperty:[NSNumber numberWithBool:[_yGrid state]] forKey:GRAxesDrawYMinorLines];
	}
	
	[_yLabels setEnabled:[_yAxis state] && ([_yTicks state] || [_yGrid state])];
	if (!sender || sender == _yLabels || sender == _yTicks || sender == _yGrid || sender == _yAxis)
		[axes setProperty:[NSNumber numberWithBool:[_yLabels state] && ([_yAxis state] && ([_yTicks state] || [_yGrid state]))] forKey:GRAxesDrawYLabels];
	
	if (!sender || sender == _majorLineColor)
		[axes setProperty:[_majorLineColor color] forKey:GRAxesMajorLineColor];
	
	if (!sender || sender == _minorLineColor)
		[axes setProperty:[_minorLineColor color] forKey:GRAxesMinorLineColor];
	
	if (!sender || sender == _background) {
		BOOL state = [_background state];
		[chart setDrawBackground:state];
		[_backgroundColor setEnabled:state];
	}
	
	if (!sender || sender == _backgroundColor)
		[axes setProperty:[_backgroundColor color] forKey:GRAxesBackgroundColor];

	if (sender == _xAxis) [self setDefaultBool:[_xAxis state] forKey:@"decorations.x.axis"];
	if (sender == _xTicks) [self setDefaultBool:[_xTicks state] forKey:@"decorations.x.ticks"];
	if (sender == _xGrid) [self setDefaultBool:[_xGrid state] forKey:@"decorations.x.grid"];
	if (sender == _xLabels) [self setDefaultBool:[_xLabels state] forKey:@"decorations.x.labels"];
	if (sender == _yAxis) [self setDefaultBool:[_yAxis state] forKey:@"decorations.y.axis"];
	if (sender == _yTicks) [self setDefaultBool:[_yTicks state] forKey:@"decorations.y.ticks"];
	if (sender == _yGrid) [self setDefaultBool:[_yGrid state] forKey:@"decorations.y.grid"];
	if (sender == _yLabels) [self setDefaultBool:[_yLabels state] forKey:@"decorations.y.labels"];
	if (sender == _background) [self setDefaultBool:[_background state] forKey:@"decorations.background"];
	if (sender == _majorLineColor) [self setDefaultColor:[_majorLineColor color] forKey:@"decorations.majorlinecolor"];
	if (sender == _minorLineColor) [self setDefaultColor:[_minorLineColor color] forKey:@"decorations.minorlinecolor"];
	if (sender == _backgroundColor) [self setDefaultColor:[_backgroundColor color] forKey:@"decorations.background.color"];
}

-(BOOL)min {
	return [_minCurve state];
}

-(BOOL)mean {
	return [_meanCurve state];
}

-(BOOL)max {
	return [_maxCurve state];
}

-(BOOL)fill {
	return [_minmaxFill state];
}

@end
