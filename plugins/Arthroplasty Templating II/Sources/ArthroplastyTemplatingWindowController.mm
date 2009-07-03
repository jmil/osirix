//
//  ArthroplastyTemplatingWindowController.m
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "ArthroplastyTemplatingWindowController.h"
#import "ArthroplastyTemplatingStepByStepController.h"
#import "BrowserController.h"
#import "ViewerController.h"
#import "ROI.h"
#import "DCMView.h"
#import "ZimmerTemplate.h"
#import "NSImage+ArthroplastyTemplating.h"
#import "ArthroplastyTemplateFamily.h"
#import "ArthroplastyTemplatingPlugin.h"
#include <sstream>
#include <cmath>
#include "NSUtils.h"
#include "Notifications.h"

@implementation ArthroplastyTemplatingWindowController
@synthesize flipTemplatesHorizontally = _flipTemplatesHorizontally, userDefaults = _userDefaults, plugin = _plugin;

-(id)initWithPlugin:(ArthroplastyTemplatingPlugin*)plugin {
	self = [self initWithWindowNibName:@"ArthroplastyTemplatingWindow"];
	_plugin = plugin;
	
	_viewDirection = ArthroplastyTemplateAnteriorPosteriorDirection;
	_flipTemplatesHorizontally = NO;
	
	_userDefaults = [[ArthroplastyTemplatingUserDefaults alloc] init];
	NSBundle* bundle = [NSBundle bundleForClass:[self class]];
	_presets = [[NSDictionary alloc] initWithContentsOfFile:[bundle pathForResource:[bundle bundleIdentifier] ofType:@"plist"]];
	
	_templates = [[NSMutableArray arrayWithCapacity:0] retain];
	_familiesArrayController = [[NSArrayController alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performDragOperation:) name:OsirixPerformDragOperationNotification object:NULL];
	
	[self loadTemplates];
	
	return self;
}

-(void)awakeFromNib {
	[_familiesArrayController setSortDescriptors:[_familiesTableView sortDescriptors]];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_familiesArrayController release];
//	[_families release];
	[_templates release];
	[_presets release];
	[_userDefaults release];
	[super dealloc];
}

-(void)windowWillClose:(NSNotification *)aNotification {
	// [self release];
}

#pragma mark Templates

-(void)loadTemplates {
//	[self willChangeValueForKey:@"templates"];
	[_templates removeAllObjects];
	NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(LoadTemplates:) object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTemplatesDone:) name:NSThreadWillExitNotification object:thread];
	[thread start];
}

-(void)LoadTemplates:(id)object {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableArray* templates = [NSMutableArray arrayWithCapacity:64];
	[[[NSThread currentThread] threadDictionary] setObject:templates forKey:@"templates"];
	// do the actual job
	[templates addObjectsFromArray:[ZimmerTemplate bundledTemplates]];
	
	[pool release];
}

-(void)loadTemplatesDone:(NSNotification*)notification {
	NSThread* thread = [notification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSThreadWillExitNotification object:thread];
	[_templates addObjectsFromArray:[[thread threadDictionary] objectForKey:@"templates"]];
	
	// fill _families from _templates
	for (unsigned i = 0; i < [_templates count]; ++i) {
		ArthroplastyTemplate* templat = [_templates objectAtIndex:i];
		BOOL included = NO;
		
		for (unsigned i = 0; i < [[_familiesArrayController content] count]; ++i) {
			ArthroplastyTemplateFamily* family = [[_familiesArrayController content] objectAtIndex:i];
			if ([family matches:templat]) {
				[family add:templat];
				included = YES;
				break;
			}
		}
		
		if (included)
			continue;
		
		[_familiesArrayController addObject:[[[ArthroplastyTemplateFamily alloc] initWithTemplate:templat] autorelease]];
	}
	
	[_familiesArrayController rearrangeObjects];
	[_familiesTableView reloadData];
	[self setFamily:_familiesTableView];
	// [self didChangeValueForKey:@"templates"];}
}

-(ArthroplastyTemplate*)templateAtPath:(NSString*)path {
	for (unsigned i = 0; i < [_templates count]; ++i)
		if ([[[_templates objectAtIndex:i] path] isEqualToString:path])
			return [_templates objectAtIndex:i];
	return NULL;
}

//-(ArthroplastyTemplate*)templateAtIndex:(int)index {
//	return [[_templatesArrayController arrangedObjects] objectAtIndex:index];	
//}

-(ArthroplastyTemplateFamily*)familyAtIndex:(int)index {
	return index != -1? [[_familiesArrayController arrangedObjects] objectAtIndex:index] : NULL;	
}

//-(ArthroplastyTemplate*)selectedTemplate {
//	return [self templateAtIndex:[_templatesTableView selectedRow]];
//}

-(ArthroplastyTemplateFamily*)selectedFamily {
	return [self familyAtIndex:[_familiesTableView selectedRow]];
}

-(ArthroplastyTemplate*)currentTemplate {
	return [[self selectedFamily] template:[_sizes indexOfSelectedItem]];
}

-(void)filterTemplates {
	NSString* filter = [_searchField stringValue];
	
	if ([filter length] == 0) {
		[_familiesArrayController setFilterPredicate:[NSPredicate predicateWithValue:YES]];
	} else {
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(fixation contains[c] %@) OR (group contains[c] %@) OR (manufacturer contains[c] %@) OR (modularity contains[c] %@) OR (name contains[c] %@) OR (placement contains[c] %@) OR (surgery contains[c] %@) OR (type contains[c] %@)", filter, filter, filter, filter, filter, filter, filter, filter];
		[_familiesArrayController setFilterPredicate:predicate];
	}
	
//	[_familiesArrayController rearrangeObjects];
	[_familiesTableView noteNumberOfRowsChanged];
//	[_familiesTableView reloadData];
	[self setFamily:_familiesTableView];
}

-(BOOL)setFilter:(NSString*)string {
	[_searchField setStringValue:string];
	[self searchFilterChanged:self];
	return [[_familiesArrayController arrangedObjects] count] > 0;
}

-(IBAction)searchFilterChanged:(id)sender {
	[self filterTemplates];
}

#pragma mark PDF preview

-(NSString*)pdfPathForFamilyAtIndex:(int)index {
	return index != -1? [[[self familyAtIndex:index] template:[_sizes indexOfSelectedItem]] pdfPathForDirection:_viewDirection] : [[NSBundle bundleForClass:[self class]] pathForResource:@"empty" ofType:@"pdf"];
}

-(void)setFamily:(id)sender {
	if (sender == _familiesTableView) { // update sizes menu
		[_familiesArrayController setSelectionIndex:[_familiesTableView selectedRow]];
		
		float selectedSize; std::istringstream([[_sizes titleOfSelectedItem] UTF8String]) >> selectedSize;
		[_sizes removeAllItems];
		ArthroplastyTemplateFamily* family = [self selectedFamily];
		float diffs[[[family templates] count]];
		for (unsigned i = 0; i < [[family templates] count]; ++i) {
			NSString* size = [(ArthroplastyTemplate*)[[family templates] objectAtIndex: i] size];
			[_sizes addItemWithTitle:size];
			float currentSize = 0; std::istringstream([size UTF8String]) >> selectedSize;
			diffs[i] = fabsf(selectedSize-currentSize);
		}
		
		unsigned index = 0;
		for (unsigned i = 1; i < [[family templates] count]; ++i)
			if (diffs[i] < diffs[index])
				index = i;
		[_sizes selectItemAtIndex:index];
	}
	
	if ([_familiesTableView selectedRow] < 0)
		if ([[_familiesArrayController arrangedObjects] count])
			[_familiesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
		else return;
	
	NSString* pdfPath = [self pdfPathForFamilyAtIndex:[_familiesTableView selectedRow]];
	
	if(!pdfPath) return;
	
//	NSData *pdfData = [NSData dataWithContentsOfFile:pdfPath];
//	PDFDocument *doc = [[PDFDocument alloc] initWithData:pdfData];
	PDFDocument *doc = [[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:pdfPath]];

//	NSImage *image = [[NSImage alloc] initByReferencingFile:pdfPath];
//	NSMutableDictionary *deviceDictionary = [NSMutableDictionary dictionaryWithObject:[NSValue valueWithSize:NSMakeSize(300,300)] forKey:@"NSDeviceResolution"];
//	[deviceDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"NSDeviceIsScreen"];
//	[image release];
	
	[_pdfView setAutoScales:NO];
	[_pdfView setDocument:doc];
	[_pdfView setAutoScales:YES];
}

-(NSString*)idForTemplate:(ArthroplastyTemplate*)templat {
	if (_viewDirection == ArthroplastyTemplateAnteriorPosteriorDirection)
		return [NSString stringWithFormat:@"%@/%@/%@", [templat manufacturer], [templat name], [templat size]];
	else return [NSString stringWithFormat:@"%@/%@/%@/Lateral", [templat manufacturer], [templat name], [templat size]];
}

-(BOOL)selectionForTemplate:(ArthroplastyTemplate*)templat into:(NSRect*)rect {
	NSRect temp;
	NSString* key = [self idForTemplate:templat];
	if ([_userDefaults keyExists:key])
		temp = [_userDefaults rect:key otherwise:NSZeroRect];
	else if ([_presets valueForKey:key]) {
		NSData* data = [_presets valueForKey:key];
		[data getBytes:&temp length:sizeof(NSRect)];
	} else return NO;
	if (temp.size.width < 0) { temp.origin.x += temp.size.width; temp.size.width = -temp.size.width; }
	if (temp.size.height < 0) { temp.origin.y += temp.size.height; temp.size.height = -temp.size.height; }
	memcpy(rect, &temp, sizeof(NSRect));
	return YES;	
}

-(BOOL)selectionForCurrentTemplate:(NSRect*)rect {
	return [self selectionForTemplate:[self currentTemplate] into:rect];
}

-(void)setSelectionForCurrentTemplate:(NSRect)rect {
	[_userDefaults setRect:rect forKey:[self idForTemplate:[self currentTemplate]]];
}

-(void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	[self setFamily:_familiesTableView];
}

-(ATImage*)templateImage:(ArthroplastyTemplate*)templat entirePageSizePixels:(NSSize)size color:(NSColor*)color {
	ATImage* image = [[ATImage alloc] initWithContentsOfFile:[templat pdfPathForDirection:_viewDirection]];
	NSSize imageSize = [image size];
	
	// size.width OR size.height can be qual to zero, in which case the zero value is set corresponding to the available value
	if (!size.width)
		size.width = std::floor(size.height/imageSize.height*imageSize.width);
	if (!size.height)
		size.height = std::floor(size.width/imageSize.width*imageSize.height);
	
	[image setScalesWhenResized:YES];
	[image setSize:size];
	
	// extract selected part
	NSRect sel; if ([self selectionForTemplate:templat into:&sel]) {
		sel = NSMakeRect(std::floor(sel.origin.x*size.width), std::floor(sel.origin.y*size.height), std::ceil(sel.size.width*size.width), std::ceil(sel.size.height*size.height));
		ATImage* temp = [image crop:sel];
		[image release];
		image = [temp retain];
	}
	
	// remove whitespace
	ATImage* temp = [image crop:[image boundingBoxSkippingColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0]]];
	[image release];
	image = temp;
	
	if (_flipTemplatesHorizontally)
		[image flipImageHorizontally];

/*	if (color) {
		size = [image size]; unsigned s = size.width*size.height;
		
		NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
		[bitmap ATMask:.01];
		for (unsigned i = 0; i < s; ++i) {
			unsigned x = i%(int)size.width, y = i/(int)size.width;
			NSColor* c = [bitmap colorAtX:x y:y];
			[bitmap setColor:[color colorWithAlphaComponent:[c alphaComponent]] atX:x y:y];
		}
		
		temp = [[[ATImage alloc] initWithSize:size inches:[image inchSize] portion:[image portion]] autorelease];
		[temp addRepresentation:bitmap];
		[bitmap release];
		
		image = temp;
	}*/
	
	return image;
}

-(ATImage*)templateImage:(ArthroplastyTemplate*)templat entirePageSizePixels:(NSSize)size {
	return [self templateImage:templat entirePageSizePixels:size color:[_shouldTransformColor state]? [_transformColor color] : NULL];
}

-(ATImage*)templateImage:(ArthroplastyTemplate*)templat {
	if ([_familiesTableView selectedRow] == -1) return NULL;
	PDFPage* page = [_pdfView currentPage];
	NSRect pageBox = [_pdfView convertRect:[page boundsForBox:kPDFDisplayBoxMediaBox] fromPage:page];
	return [self templateImage:templat entirePageSizePixels:pageBox.size];
}

-(ATImage*)dragImageForTemplate:(ArthroplastyTemplate*)templat {
	return [self templateImage:templat];
}

#pragma mark Template View direction

- (IBAction)setViewDirection:(id)sender; {
	if([sender selectedSegment] == 0)
		_viewDirection = ArthroplastyTemplateAnteriorPosteriorDirection;
	else _viewDirection = ArthroplastyTemplateLateralDirection;
	
//	[self loadTemplates]; // TODO: gray out unavailable templates
	[self setFamily:_familiesTableView];
}


#pragma mark Flip Left/Right

-(IBAction)flipLeftRight:(id)sender {
	if ([sender state]==NSOnState)
		_flipTemplatesHorizontally = YES;
	else _flipTemplatesHorizontally = NO;
	[_pdfView setNeedsDisplay:YES];
}

#pragma mark Drag n Drop

-(void)addTemplate:(ArthroplastyTemplate*)templat toPasteboard:(NSPasteboard*)pboard {
	[pboard declareTypes:[NSArray arrayWithObjects:pasteBoardOsiriXPlugin, @"ArthroplastyTemplate*", NULL] owner:self];
	[pboard setData:[NSData dataWithBytes:&templat length:sizeof(ArthroplastyTemplate*)] forType:@"ArthroplastyTemplate*"];
}

- (BOOL)tableView:(NSTableView*)tv writeRowsWithIndexes:(NSIndexSet*)rowIndexes toPasteboard:(NSPasteboard*)pboard {
	[self addTemplate:[[self familyAtIndex:[rowIndexes firstIndex]] template:[_sizes indexOfSelectedItem]] toPasteboard:pboard];
	return YES;
}

-(void)dragTemplate:(ArthroplastyTemplate*)templat startedByEvent:(NSEvent*)event onView:(NSView*)view {
	NSPasteboard* pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	[self addTemplate:templat toPasteboard:pboard];
	
	ATImage* image = [self dragImageForTemplate:templat];
	NSSize size = [image size];
	
	NSPoint click = [view convertPoint:[event locationInWindow] fromView:NULL];
	NSPoint at = click-size/2;
	
	NSPoint origin;
	if ([templat origin:&origin forDirection:_viewDirection]) { // origin in inches
		if (_flipTemplatesHorizontally)
			origin.y = [image originalInchSize].width-origin.y;
		at = click-[image convertPointFromPageInches:origin]-NSMakePoint(1,-3);
	}
	
	[view dragImage:image at:at offset:NSMakeSize(0,0) event:event pasteboard:pboard source:view slideBack:YES];
}

-(ROI*)createROIFromTemplate:(ArthroplastyTemplate*)templat inViewer:(ViewerController*)destination centeredAt:(NSPoint)p {
	ATImage* image = [self templateImage:templat entirePageSizePixels:NSMakeSize(0,1800)]; // TODO: N -> adapted size
	
	CGFloat magnification = [[_plugin windowControllerForViewer:destination] magnification];
	if (!magnification) magnification = 1;
	float pixSpacing = (1.0 / [image resolution] * 25.4) * magnification; // image is in 72 dpi, we work in milimeters
	
	ROI* newLayer = [destination addLayerRoiToCurrentSliceWithImage:image referenceFilePath:[templat path] layerPixelSpacingX:pixSpacing layerPixelSpacingY:pixSpacing];
	
	[destination bringToFrontROI:newLayer];
	[newLayer generateEncodedLayerImage];
	
	// find the center of the template
	NSSize imageSize = [image size];
	NSPoint imageCenter = NSMakePoint(imageSize/2);
	NSPoint origin;
	if ([templat origin:&origin forDirection:_viewDirection]) { // origin in inches
		if (_flipTemplatesHorizontally)
			origin.x = [image originalInchSize].width-origin.x;
		imageCenter = [image convertPointFromPageInches:origin];
		imageCenter.y = imageSize.height-imageCenter.y;
	}
	
	NSArray *layerPoints = [newLayer points];
	NSPoint layerSize = [[layerPoints objectAtIndex:2] point] - [[layerPoints objectAtIndex:0] point];
	
	NSPoint layerCenter = imageCenter/imageSize*layerSize;
	[[newLayer points] addObject:[MyPoint point:layerCenter]];
	[[newLayer points] addObject:[MyPoint point:layerCenter+NSMakePoint(1,0)]];
	
	[newLayer setROIMode:ROI_selected]; // in order to make the roiMove method possible
	[newLayer roiMove:p-layerCenter :YES];
	
	// set the textual data
	[newLayer setName:[templat name]];
	NSArray *lines = [templat textualData];
	if([lines objectAtIndex:0]) [newLayer setTextualBoxLine1:[lines objectAtIndex:0]];
	if([lines objectAtIndex:1]) [newLayer setTextualBoxLine2:[lines objectAtIndex:1]];
	if([lines objectAtIndex:2]) [newLayer setTextualBoxLine3:[lines objectAtIndex:2]];
	if([lines objectAtIndex:3]) [newLayer setTextualBoxLine4:[lines objectAtIndex:3]];
	if([lines objectAtIndex:4]) [newLayer setTextualBoxLine5:[lines objectAtIndex:4]];
	
	return newLayer;
}

-(void)performDragOperation:(NSNotification *)notification {
	NSDictionary* userInfo = [notification userInfo];
	id <NSDraggingInfo> operation = [userInfo valueForKey:@"id<NSDraggingInfo>"];

	if (![[operation draggingPasteboard] dataForType:@"ArthroplastyTemplate*"])
		return; // no ArthroplastyTemplate pointer available
	if ([operation draggingSource] != _pdfView && [operation draggingSource] != _familiesTableView)
		return;
	
	ViewerController* destination = [notification object];
	
	ArthroplastyTemplate* templat; [[[operation draggingPasteboard] dataForType:@"ArthroplastyTemplate*"] getBytes:&templat length:sizeof(ArthroplastyTemplate*)];

	// find the location of the mouse in the OpenGL view
	NSPoint openGLLocation = [[destination imageView] ConvertFromNSView2GL:[[destination imageView] convertPoint:[operation draggingLocation] fromView:NULL]];
	
	[self createROIFromTemplate:templat inViewer:destination centeredAt:openGLLocation];
	
	[[destination window] makeKeyWindow];
}

- (NSRect)addMargin:(int)pixels toRect:(NSRect)rect;
{
	float x = rect.origin.x - pixels;
	if(x<0) x=0;
	float y = rect.origin.y - pixels;
	if(y<0) y=0;
	float width = rect.size.width + 2 * pixels;
	float height = rect.size.height + 2 * pixels;
	
	return NSMakeRect(x, y, width, height);
}

#pragma mark ROI



#pragma mark Keyboard
//
//- (void)keyDown:(NSEvent*)theEvent;
//{
//	if([theEvent modifierFlags] & NSAlternateKeyMask)
//		flipTemplatesHorizontally = YES;
//}
//
//- (void)keyUp:(NSEvent*)theEvent;
//{
//	flipTemplatesHorizontally = NO;
//}

-(void)keyDown:(NSEvent*)event {
	if ([[event characters] isEqualToString:@"+"]) {
		[_sizes selectItemAtIndex:([_sizes indexOfSelectedItem]+1)%[_sizes numberOfItems]];
		[_sizes setNeedsDisplay:YES];
		[self setFamily:_sizes];
	} else
		if ([[event characters] isEqualToString:@"-"]) {
			int index = [_sizes indexOfSelectedItem]-1;
			if (index < 0) index = [_sizes numberOfItems]-1;
			[_sizes selectItemAtIndex:index];
			[_sizes setNeedsDisplay:YES];
			[self setFamily:_sizes];
		} else
			[super keyDown:event];
}

#pragma mark NSTableDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView*)table {
	return [[_familiesArrayController arrangedObjects] count];
}

- (id)tableView:(NSTableView*)table objectValueForTableColumn:(NSTableColumn*)col row:(NSInteger)i {
	return [[[_familiesArrayController arrangedObjects] objectAtIndex:i] performSelector:sel_registerName([[col identifier] UTF8String])];
}

- (void)tableView:(NSTableView*)table sortDescriptorsDidChange:(NSArray*)oldDescriptors {
	[_familiesArrayController setSortDescriptors:[_familiesTableView sortDescriptors]];
	[_familiesArrayController rearrangeObjects];
	[_familiesTableView selectRowIndexes:[_familiesArrayController selectionIndexes] byExtendingSelection:NO];
}

@end
