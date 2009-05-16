#pragma once

/*=========================================================================
  Program:   OsiriX

  Copyright (c) OsiriX Team
  All rights reserved.
  Distributed under GNU - GPL
  
  See http://www.osirix-viewer.com/copyright.html for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
=========================================================================*/

enum XRangeMode {
	XRangeEntireStack, XRangeFromCurrentToEnd, XRange4thDimension, XRangeDefinedByUser
};

#import <Cocoa/Cocoa.h>
@class Interface;
@class UserDefaults;

@interface Options : NSObject {
	IBOutlet Interface* _interface;
	// curves
	IBOutlet NSButton *_meanCurve, *_minCurve, *_maxCurve, *_minmaxFill;
	// ranges
	IBOutlet NSPopUpButton* _xRangeMode;
	IBOutlet NSMenuItem *_xRangeEntireStack, *_xRangeFromCurrentToEnd, *_xRange4thDimension, *_xRangeDefinedByUser;
	IBOutlet NSTextField *_xRangeMin, *_xRangeMax;
	IBOutlet NSButton* _logscaleYRange;
	IBOutlet NSButton* _constrainYRange;
	IBOutlet NSTextField *_yRangeMin, *_yRangeMax;
	// decorations
	IBOutlet NSButton *_xAxis, *_xTicks, *_xGrid, *_xLabels, *_yAxis, *_yTicks, *_yGrid, *_yLabels, *_background;
	IBOutlet NSColorWell *_majorLineColor, *_minorLineColor, *_backgroundColor;
}

-(void)loadUserDefaults;

-(IBAction)curvesChanged:(id)sender;
-(IBAction)xRangeChanged:(id)sender;
-(void)updateXRange;
-(IBAction)yRangeChanged:(id)sender;
-(XRangeMode)xRangeMode;
-(void)updateYRange;
-(IBAction)decorationsChanged:(id)sender;
-(BOOL)min;
-(BOOL)mean;
-(BOOL)max;
-(BOOL)fill;

@end
