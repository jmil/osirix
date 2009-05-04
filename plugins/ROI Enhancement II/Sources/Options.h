#pragma once

//
//  Options.h
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 4/28/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Interface;

@interface Options : NSObject {
	IBOutlet Interface* _interface;
	NSMutableDictionary* _userDefaults;
	// curves
	IBOutlet NSButton *_meanCurve, *_minCurve, *_maxCurve;
	// ranges
	IBOutlet NSPopUpButton* _xRangeSelection;
	IBOutlet NSTextField *_xRangeMin, *_xRangeMax;
	IBOutlet NSButton* _logscaleYRange;
	IBOutlet NSButton* _constrainYRange;
	IBOutlet NSTextField *_yRangeMin, *_yRangeMax;
	// decorations
	IBOutlet NSButton *_xAxis, *_xTicks, *_xGrid, *_xLabels, *_yAxis, *_yTicks, *_yGrid, *_yLabels, *_background;
	IBOutlet NSColorWell *_majorLineColor, *_minorLineColor, *_backgroundColor;
}

@property(retain, readonly) NSMutableDictionary* userDefaults;

-(IBAction)curvesChanged:(id)sender;
-(void)chartChanged:(NSNotification*)notification;
-(IBAction)xRangeChanged:(id)sender;
-(IBAction)yRangeChanged:(id)sender;
-(void)updateYRange;
-(IBAction)decorationsChanged:(id)sender;
-(BOOL)min;
-(BOOL)mean;
-(BOOL)max;

@end
