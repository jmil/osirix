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
#import <DICOMExport.h>
#import <DCMPix.h>

const NSString* FileTypePDF = @"pdf";
const NSString* FileTypeTIFF = @"tiff";
const NSString* FileTypeDICOM = @"dcm";
const NSString* FileTypeCSV = @"csv";


@implementation CSVSaveOptions

-(BOOL)includeHeaders {
	return [_includeHeaders state] == NSOnState;
}

@end

@implementation DICOMSaveOptions

-(NSColor*)bgColor {
	return [_bgColor color];
}

@end

@implementation DICOMSavePanel

-(NSString*)seriesName {
	return [_seriesName stringValue];
}

-(NSColor*)bgColor {
	return [_bgColor color];
}

@end


@implementation Interface
@synthesize viewer = _viewer;
@synthesize roiList = _roiList;
@synthesize chart = _chart;
@synthesize options = _options;
@synthesize decimalFormatter = _decimalFormatter;

- (void) dealloc
{
	[_viewer release];
	[super dealloc];
}


-(id)initForViewer:(ViewerController*)viewer {
	_viewer = [viewer retain];
	self = [super initWithWindowNibName:@"Interface"];
	[self window]; // triggers nib loading
	
	[_roiList loadViewerROIs];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:@"CloseViewerNotification" object:viewer];
	
	return self;
}

-(void)windowWillClose:(NSNotification*)notification
{
	[self release];
}

-(void)viewerWillClose:(NSNotification*)notification
{
	if( [notification object] == _viewer)
	{
		[[self window] close];
	}
}

-(void)saveAs:(NSString*)format accessoryView:(NSView*)accessoryView {
	NSSavePanel* panel = [NSSavePanel savePanel];
	[panel setRequiredFileType:format];
	if (accessoryView)
		[panel setAccessoryView:accessoryView];
	[panel beginSheetForDirectory:NULL file:NULL modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(saveAsPanelDidEnd:returnCode:contextInfo:) contextInfo:format];
}

-(IBAction)saveDICOM:(id)sender {
	[NSApp beginSheet:_dicomSavePanel modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(saveDicomSheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

-(IBAction)saveAsPDF:(id)sender {
	[self saveAs:FileTypePDF accessoryView:NULL];
}

-(IBAction)saveAsTIFF:(id)sender {
	[self saveAs:FileTypeTIFF accessoryView:NULL];
}

-(IBAction)saveAsDICOM:(id)sender {
	[self saveAs:FileTypeDICOM accessoryView:_dicomSaveOptions];
}

-(IBAction)saveAsCSV:(id)sender {
	[self saveAs: FileTypeCSV accessoryView:_csvSaveOptions];
}

-(void)dicomSave:(NSString*)seriesDescription backgroundColor:(NSColor*)backgroundColor toFile:(NSString*)filename {
	NSBitmapImageRep* bitmapImageRep = [_chart bitmapImageRepForCachingDisplayInRect:[_chart bounds]];
	[_chart cacheDisplayInRect:[_chart bounds] toBitmapImageRep:bitmapImageRep];
	NSInteger bytesPerPixel = [bitmapImageRep bitsPerPixel]/8;
	CGFloat backgroundRGBA[4]; [[backgroundColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]] getComponents:backgroundRGBA];
	
	// convert RGBA to RGB
	NSMutableData* bitmapRGBData = [NSMutableData dataWithCapacity: [bitmapImageRep size].width*[bitmapImageRep size].height*3];
	for (int y = 0; y < [bitmapImageRep size].height; ++y) {
		unsigned char* rowStart = [bitmapImageRep bitmapData]+[bitmapImageRep bytesPerRow]*y;
		for (int x = 0; x < [bitmapImageRep size].width; ++x) {
			unsigned char rgba[4]; memcpy(rgba, rowStart+bytesPerPixel*x, 4);
			float ratio = float(rgba[3])/255;
			rgba[0] = ratio*rgba[0]+(1-ratio)*backgroundRGBA[0]*255;
			rgba[1] = ratio*rgba[1]+(1-ratio)*backgroundRGBA[1]*255;
			rgba[2] = ratio*rgba[2]+(1-ratio)*backgroundRGBA[2]*255;
			[bitmapRGBData appendBytes:rgba length:3];
		}
	}
	
	DICOMExport* dicomExport = [[DICOMExport alloc] init];
	[dicomExport setSourceFile:[[[_viewer pixList] objectAtIndex:0] srcFile]];
	[dicomExport setSeriesDescription: seriesDescription];
	[dicomExport setSeriesNumber:1];
	[dicomExport setPixelData:(unsigned char*)[bitmapRGBData bytes] samplePerPixel:3 bitsPerPixel:8 width:[bitmapImageRep size].width height:[bitmapImageRep size].height];
	[dicomExport writeDCMFile:filename];
	[dicomExport release];
}

-(void)saveDicomSheetDidEnd:(NSWindow*)sheet returnCode:(int)code contextInfo:(void*)contextInfo {
	if (code == NSOKButton)
		[self dicomSave:[_dicomSavePanel seriesName] backgroundColor:[_dicomSavePanel bgColor] toFile:NULL];
}

-(void)saveAsPanelDidEnd:(NSSavePanel*)panel returnCode:(int)code contextInfo:(void*)format {
    NSError* error = 0;
	
	if (code == NSOKButton)
		if (format == FileTypePDF) {
			[[_chart dataWithPDFInsideRect:[_chart bounds]] writeToFile:[panel filename] options:NSAtomicWrite error:&error];
			
		} else if (format == FileTypeCSV) {
			[[_chart csv: [_csvSaveOptions includeHeaders]] writeToFile:[panel filename] atomically:YES encoding:NSUTF8StringEncoding error:&error];
			
		} else if (format == FileTypeTIFF) {
			NSBitmapImageRep* bitmapImageRep = [_chart bitmapImageRepForCachingDisplayInRect:[_chart bounds]];
			[_chart cacheDisplayInRect:[_chart bounds] toBitmapImageRep:bitmapImageRep];
			NSImage* image = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
			[image addRepresentation:bitmapImageRep];
			[[image TIFFRepresentation] writeToFile:[panel filename] options:NSAtomicWrite error:&error];
			[image release];
			
		} else { // dicom
			unsigned lastSlash = [[panel filename] rangeOfString:@"/" options:NSBackwardsSearch].location+1;
			[self dicomSave:[[panel filename] substringWithRange: NSMakeRange(lastSlash, [[panel filename] rangeOfString:@"." options:NSBackwardsSearch].location-lastSlash)] backgroundColor:[_dicomSaveOptions bgColor] toFile:[panel filename]];
		}
	
	if (error)
		[[NSAlert alertWithError:error] beginSheetModalForWindow:[self window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
}

@end
