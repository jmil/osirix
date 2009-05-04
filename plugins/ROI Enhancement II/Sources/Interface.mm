//
//  Window.mm
//  ROI-Enhancement
//
//  Created by Alessandro Volz on 4/20/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "Interface.h"
#import <ViewerController.h>
#import "ROIList.h"
#import "Chart.h"
#import "Options.h"

const NSString* FileTypePDF = @"pdf";
const NSString* FileTypeDICOM = @"dicom";

@implementation Interface
@synthesize viewer = _viewer;
@synthesize roiList = _roiList;
@synthesize chart = _chart;
@synthesize options = _options;
@synthesize decimalFormatter = _decimalFormatter;

-(id)initForViewer:(ViewerController*)viewer {
	self = [super initWithWindowNibName: @"Interface"];
	_viewer = [viewer retain];
	return self;
}

-(void)windowWillClose:(NSNotification*)notification {
	[self release];
}

-(IBAction)saveAsPDF:(id)sender {
	NSSavePanel* panel = [NSSavePanel savePanel];
	[panel setRequiredFileType: FileTypePDF];
	[panel beginSheetForDirectory:NULL file:NULL modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(saveAsPanelDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

-(IBAction)saveAsDICOM:(id)sender {
	NSSavePanel* panel = [NSSavePanel savePanel];
	[panel setRequiredFileType: FileTypeDICOM];
	[panel beginSheetForDirectory:NULL file:NULL modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(saveAsPanelDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

-(void)saveAsPanelDidEnd:(NSSavePanel*)panel returnCode:(int)code contextInfo:(void*)contextInfo {
    if (code == NSOKButton) {
		NSData *data = [_chart dataWithPDFInsideRect: [_chart bounds]];
		if ([[panel requiredFileType] isEqualToString: FileTypeDICOM])
			; // TODO: save data as DICOM
		else [data writeToFile: [panel filename] atomically: YES];
	}
}

@end
