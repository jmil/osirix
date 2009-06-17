//
//  ArthroplastyTemplatingWindowController.m
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "ArthroplastyTemplatingWindowController.h"
#import "BrowserController.h"
#import "ViewerController.h"
#import "ROI.h"
#import "DCMView.h"
#import "ZimmerTemplate.h"
#import "NSImage+ArthroplastyTemplating.h"
#import "ArthroplastyTemplateFamily.h"
#include <sstream>
#include <cmath>
#include "NSImage+ArthroplastyTemplating.h"

@implementation ArthroplastyTemplatingWindowController
@synthesize flipTemplatesHorizontally = _flipTemplatesHorizontally, userDefaults = _userDefaults;

-(id)initWithWindowNibName:(NSString *)windowNibName {
	self = [super initWithWindowNibName:windowNibName];
	
	_viewDirection = ArthroplastyTemplateAnteriorPosteriorDirection;
	_flipTemplatesHorizontally = NO;
	
	_userDefaults = [[ArthroplastyTemplatingUserDefaults alloc] init];
	NSBundle* bundle = [NSBundle bundleForClass:[self class]];
	_presets = [[NSDictionary alloc] initWithContentsOfFile:[bundle pathForResource:[bundle bundleIdentifier] ofType:@"plist"]];
	
	_templates = [[NSMutableArray arrayWithCapacity:0] retain];
	_families = [[NSMutableArray arrayWithCapacity:0] retain];
	[self loadTemplates];
	
	//	[self setPDFDocument:_templatesTableView];
	
//	[_pdfView setAutoScales:YES];
	
//	[[self window] setFrameAutosaveName:@"ArthroplastyTemplatingsPluginWindow"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performDragOperation:) name:@"PluginDragOperationNotification" object:nil];
	//[templatesTableView registerForDraggedTypes:[NSArray arrayWithObject:ArthroplastyTemplatingDataType]];
	
	[[self window] makeKeyAndOrderFront:self]; // TODO: remove
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_families release];
	[_templates release];
	[_presets release];
	[_userDefaults release];
	[super dealloc];
}

- (void)windowDidLoad {
	[_templatesTableView selectRow:0 byExtendingSelection:NO];
//	[self setFamily:_templatesTableView];
}

-(void)windowWillClose:(NSNotification *)aNotification {
	// [self release];
}

#pragma mark Templates

-(void)loadTemplates {
//	[self willChangeValueForKey:@"templates"];
	[_templatesArrayController removeObjects:_templates];
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
	[_templatesArrayController addObjects:[[thread threadDictionary] objectForKey:@"templates"]];
	
	// fill _families from _templates
	for (unsigned i = 0; i < [_templates count]; ++i) {
		ArthroplastyTemplate* templat = [_templates objectAtIndex:i];
		BOOL included = NO;
		
		for (unsigned i = 0; i < [_families count]; ++i) {
			ArthroplastyTemplateFamily* family = [_families objectAtIndex:i];
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
	
//	[_templatesTableView reloadData];
	[_templatesTableView selectRow:0 byExtendingSelection:NO];
	[self setFamily:_templatesTableView];
	//	[self didChangeValueForKey:@"templates"];}
}

-(ArthroplastyTemplate*)templateAtPath:(NSString*)path {
	for (unsigned i = 0; i < [_templates count]; ++i)
		if ([[[_templates objectAtIndex:i] referenceFilePath] isEqualToString:path])
			return [_templates objectAtIndex:i];
	return NULL;
}

//-(ArthroplastyTemplate*)templateAtIndex:(int)index {
//	return [[_templatesArrayController arrangedObjects] objectAtIndex:index];	
//}

-(ArthroplastyTemplateFamily*)familyAtIndex:(int)index {
	return [[_familiesArrayController arrangedObjects] objectAtIndex:index];	
}

//-(ArthroplastyTemplate*)selectedTemplate {
//	return [self templateAtIndex:[_templatesTableView selectedRow]];
//}

-(ArthroplastyTemplateFamily*)selectedFamily {
	return [self familyAtIndex:[_templatesTableView selectedRow]];
}

-(ArthroplastyTemplate*)currentTemplate {
	return [[self selectedFamily] template:[_sizes indexOfSelectedItem]];
}

#pragma mark PDF preview

//-(NSString*)pdfPathForTemplateAtIndex:(int)index {
//	return [[self familyAtIndex:index] pdfPathForDirection:_viewDirection size:0]; // TODO: size
//}

-(NSString*)pdfPathForFamilyAtIndex:(int)index {
	return [[[self familyAtIndex:index] template:[_sizes indexOfSelectedItem]] pdfPathForDirection:_viewDirection];
}

-(void)setFamily:(id)sender {
	if (sender == _templatesTableView) { // update sizes menu
		float selectedSize; std::istringstream([[_sizes titleOfSelectedItem] UTF8String]) >> selectedSize;
		[_sizes removeAllItems];
		ArthroplastyTemplateFamily* family = [self selectedFamily];
		float diffs[[[family templates] count]];
		for (unsigned i = 0; i < [[family templates] count]; ++i) {
			NSString* size = [(ArthroplastyTemplate*)[[family templates] objectAtIndex: i] size];
			[_sizes addItemWithTitle:size];
			float currentSize; std::istringstream([size UTF8String]) >> selectedSize;
			diffs[i] = fabsf(selectedSize-currentSize);
		}
		
		unsigned index = 0;
		for (unsigned i = 1; i < [[family templates] count]; ++i)
			if (diffs[i] < diffs[index])
				index = i;
		[_sizes selectItemAtIndex:index];
	}
	
	if ([_templatesTableView selectedRow] < 0)
		return;
	
	NSString *pdfPath = [self pdfPathForFamilyAtIndex:[_templatesTableView selectedRow]];
	
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
		return [NSString stringWithFormat:@"%@/%@/%@", [templat manufacturerName], [templat name], [templat size]];
	else return [NSString stringWithFormat:@"%@/%@/%@/Lateral", [templat manufacturerName], [templat name], [templat size]];
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
	[self setFamily:_templatesTableView];
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

	if (color) {
		size = [image size]; unsigned s = size.width*size.height;
		
		NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
		[bitmap ATMask:.01];
		for (unsigned i = 0; i < s; ++i) {
			unsigned x = i%(int)size.width, y = i/(int)size.width;
			NSColor* c = [bitmap colorAtX:x y:y];
			[bitmap setColor:[color colorWithAlphaComponent:[c alphaComponent]] atX:x y:y];
		}
		
		temp = [[[ATImage alloc] initWithSize:size inches:[image inchSize]] autorelease];
		[temp addRepresentation:bitmap];
		[bitmap release];
		
		image = temp;
	}
	
	return image;
}

-(ATImage*)templateImage:(ArthroplastyTemplate*)templat entirePageSizePixels:(NSSize)size {
	return [self templateImage:templat entirePageSizePixels:size color:[_shouldTransformColor state]? [_transformColor color] : NULL];
}

-(ATImage*)templateImage:(ArthroplastyTemplate*)templat {
	PDFPage* page = [_pdfView currentPage];
	NSRect pageBox = [_pdfView convertRect:[page boundsForBox:kPDFDisplayBoxMediaBox] fromPage:page];
	return [self templateImage:templat entirePageSizePixels:pageBox.size];
}

-(NSImage*)dragImageForTemplate:(ArthroplastyTemplate*)templat {
	NSImage* image = [self templateImage:templat];
	
//	NSSize size = [image size];
	
	// draw background & drop shadow
//	static const float shadowBlurRadius = 5;
//	NSSize shadowedSize = NSMakeSize(size.width+shadowBlurRadius*3, size.height+shadowBlurRadius*3);
//	NSImage* shadowedImage = [[[NSImage alloc] initWithSize:shadowedSize] autorelease];
//	[shadowedImage setBackgroundColor:[NSColor clearColor]];
//	[shadowedImage lockFocus];
//	NSShadow *shadow = [[NSShadow alloc] init];
//	[shadow setShadowBlurRadius:shadowBlurRadius];
//	[shadow setShadowOffset:NSMakeSize(shadowBlurRadius/2,-shadowBlurRadius/2)];
//	[shadow setShadowColor:[NSColor whiteColor]];
//	[shadow set];
//	[[[NSColor whiteColor] colorWithAlphaComponent:.1] set];
//	[[NSBezierPath bezierPathWithRect:NSMakeRect(0, shadowBlurRadius, size.width+shadowBlurRadius*2, size.height+shadowBlurRadius*2)] fill];
//	[image compositeToPoint:NSMakePoint(shadowBlurRadius, shadowBlurRadius*2) operation:NSCompositeSourceOver];
//	[shadow release];
//	[shadowedImage unlockFocus];
//	image = shadowedImage;
	
	return image;
}

#pragma mark Template View direction

- (IBAction)setViewDirection:(id)sender; {
	if([sender selectedSegment] == 0)
		_viewDirection = ArthroplastyTemplateAnteriorPosteriorDirection;
	else _viewDirection = ArthroplastyTemplateLateralDirection;
	
//	[self loadTemplates]; // TODO: gray out unavailable templates
	[self setFamily:_templatesTableView];
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
	
	NSImage* image = [self dragImageForTemplate:templat];
	NSSize size = [image size];
	
	NSPoint click = [event locationInWindow];
	[view dragImage:image at:NSMakePoint(click.x-size.width/2, click.y-size.height/2) offset:NSMakeSize(0,0) event:event pasteboard:pboard source:view slideBack:YES];
}

-(void)performDragOperation:(NSNotification *)notification {
	NSDictionary* userInfo = [notification userInfo];
	id <NSDraggingInfo> operation = [userInfo valueForKey:@"dragOperation"];
	id destination = [userInfo valueForKey:@"destination"];
	
	if (![[operation draggingPasteboard] dataForType:@"ArthroplastyTemplate*"])
		return; // no ArthroplastyTemplate pointer available
	
	ArthroplastyTemplate* templat; [[[operation draggingPasteboard] dataForType:@"ArthroplastyTemplate*"] getBytes:&templat length:sizeof(ArthroplastyTemplate*)];
	ATImage* image = [self templateImage:templat entirePageSizePixels:NSMakeSize(0,1800)];// TODO: N -> adapted size

	[image setBackgroundColor:[_shouldTransformColor state]? [_transformColor color] : [NSColor clearColor]];
	[image setBackgroundColor:[NSColor clearColor]];
		
	float pixSpacing = 1.0 / [image resolution] * 25.4; // image is in 72 dpi, we work in milimeters
	
	ROI *newLayer = [(ViewerController*)destination addLayerRoiToCurrentSliceWithImage:image referenceFilePath:[templat referenceFilePath] layerPixelSpacingX:pixSpacing layerPixelSpacingY:pixSpacing];

	[(ViewerController*)destination bringToFrontROI:newLayer];
	[newLayer generateEncodedLayerImage];
	
	// place the center of the template to the mouse location:

	// find the location of the mouse in the OpenGL view
	NSPoint locationInWindow = [operation draggingLocation];
	NSPoint locationInView = [[[operation draggingDestinationWindow] contentView] convertPoint:locationInWindow toView:(DCMView*)[(ViewerController*)destination imageView]];
	NSPoint flippedLocationInView = locationInView;
	flippedLocationInView.y = [[(ViewerController*)destination imageView] frame].size.height - flippedLocationInView.y ;
	NSPoint openGLLocation = [(DCMView*)[(ViewerController*)destination imageView] ConvertFromView2GL:flippedLocationInView];
	
	// find the center of the template
	NSArray *layerPoints = [newLayer points];
	float layerWidth = [[layerPoints objectAtIndex:1] x] - [[layerPoints objectAtIndex:0] x];
	float layerHeight = [[layerPoints objectAtIndex:3] y] - [[layerPoints objectAtIndex:0] y];
	
	// as the template is initialy placed on the origin, the shift is equal to the mouse location
	NSPoint shift = openGLLocation;
	shift.x -= layerWidth/2.0;
	shift.y -= layerHeight/2.0;
	
	[newLayer setROIMode:ROI_selected]; // in order to make the roiMove method possible
	[newLayer roiMove:shift :YES];
//	[newLayer setROIMode:ROI_sleep]; // ? not sure... 
	
	// set the textual data
	[newLayer setName:[templat name]];
	NSArray *lines = [templat textualData];
	if([lines objectAtIndex:0]) [newLayer setTextualBoxLine1:[lines objectAtIndex:0]];
	if([lines objectAtIndex:1]) [newLayer setTextualBoxLine2:[lines objectAtIndex:1]];
	if([lines objectAtIndex:2]) [newLayer setTextualBoxLine3:[lines objectAtIndex:2]];
	if([lines objectAtIndex:3]) [newLayer setTextualBoxLine4:[lines objectAtIndex:3]];
	if([lines objectAtIndex:4]) [newLayer setTextualBoxLine5:[lines objectAtIndex:4]];
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

@end
