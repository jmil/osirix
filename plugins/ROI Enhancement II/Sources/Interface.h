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

@interface CSVSaveOptions : NSView {
	IBOutlet NSButton* _includeHeaders;
}

-(BOOL)includeHeaders;

@end;

@interface DICOMSaveOptions	: NSView {
	IBOutlet NSColorWell* _bgColor;
}

-(NSColor*)bgColor;

@end

@interface DICOMSavePanel : NSPanel {
	IBOutlet NSTextField* _seriesName;
	IBOutlet NSColorWell* _bgColor;
}

-(NSString*)seriesName;
-(NSColor*)bgColor;

@end;

@interface Interface : NSWindowController {
	ViewerController* _viewer;
	IBOutlet ROIList* _roiList;
	IBOutlet Chart* _chart;
	IBOutlet Options* _options;
	IBOutlet CSVSaveOptions* _csvSaveOptions; // TODO: save in prefs
	IBOutlet DICOMSaveOptions* _dicomSaveOptions; // TODO: save in prefs
	IBOutlet DICOMSavePanel* _dicomSavePanel; // TODO: save in prefs
	IBOutlet NSNumberFormatter* _decimalFormatter;
}

@property(readonly) ViewerController* viewer;
@property(readonly) ROIList* roiList;
@property(readonly) Chart* chart;
@property(readonly) Options* options;
@property(readonly) NSNumberFormatter* decimalFormatter;

-(id)initForViewer:(ViewerController*)viewer;
-(IBAction)saveDICOM:(id)sender;
-(IBAction)saveAsPDF:(id)sender;
-(IBAction)saveAsTIFF:(id)sender;
-(IBAction)saveAsDICOM:(id)sender;
-(IBAction)saveAsCSV:(id)sender;

@end
