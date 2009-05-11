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
@class UserDefaults;

@interface Interface : NSWindowController {
	ViewerController* _viewer;
	UserDefaults* _userDefaults;
	IBOutlet ROIList* _roiList;
	IBOutlet Chart* _chart;
	IBOutlet Options* _options;
	IBOutlet NSButton* _csvSaveOptionsIncludeHeaders;
	IBOutlet NSView* _dicomSaveOptions;
		IBOutlet NSColorWell* _dicomSaveOptionsBackgroundColor;
	IBOutlet NSWindow* _dicomSavePanel;
		IBOutlet NSTextField* _dicomSavePanelSeriesName;
		IBOutlet NSColorWell* _dicomSavePanelBackgroundColor;
		IBOutlet NSButton* _dicomSavePanelSaveButton;
		IBOutlet NSButton* _dicomSavePanelCancelButton;
	IBOutlet NSNumberFormatter* _decimalFormatter;
	IBOutlet NSNumberFormatter* _floatFormatter;
}

@property(readonly) ViewerController* viewer;
@property(readonly) ROIList* roiList;
@property(readonly) Chart* chart;
@property(readonly) Options* options;
@property(readonly) NSNumberFormatter* decimalFormatter;
@property(readonly) NSNumberFormatter* floatFormatter;
@property(readonly) UserDefaults* userDefaults;

-(id)initForViewer:(ViewerController*)viewer;
-(IBAction)saveDICOM:(id)sender;
-(IBAction)saveAsPDF:(id)sender;
-(IBAction)saveAsTIFF:(id)sender;
-(IBAction)saveAsDICOM:(id)sender;
-(IBAction)saveAsCSV:(id)sender;

@end
