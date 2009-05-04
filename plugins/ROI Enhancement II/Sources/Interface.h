#pragma once

//
//  Window.h
//  ROI-Enhancement
//
//  Created by Alessandro Volz on 4/20/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ViewerController;
@class ROIList;
@class Chart;
@class Options;

@interface Interface : NSWindowController {
	ViewerController* _viewer;
	IBOutlet ROIList* _roiList;
	IBOutlet Chart* _chart;
	IBOutlet Options* _options;
	IBOutlet NSNumberFormatter* _decimalFormatter;
}

@property(readonly, retain) ViewerController* viewer;
@property(readonly) ROIList* roiList;
@property(readonly) Chart* chart;
@property(readonly) Options* options;
@property(readonly) NSNumberFormatter* decimalFormatter;

-(id)initForViewer:(ViewerController*)viewer;
-(IBAction)saveAsPDF:(id)sender;
-(IBAction)saveAsDICOM:(id)sender;

@end
