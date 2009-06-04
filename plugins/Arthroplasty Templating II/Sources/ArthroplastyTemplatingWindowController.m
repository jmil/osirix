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
#import "NSImage+Extras.h"

#define PluginDataType @"OsiriXPluginDataType"

@implementation ArthroplastyTemplatingWindowController
@synthesize flipTemplatesHorizontally = _flipTemplatesHorizontally;

-(id)initWithWindowNibName:(NSString *)windowNibName {
	self = [super initWithWindowNibName:windowNibName];
	
	_viewDirection = ArthroplastyTemplateAnteriorPosteriorDirection;
	_flipTemplatesHorizontally = NO;
	
	_templates = [[NSMutableArray arrayWithCapacity:0] retain];
	[self loadTemplates];
	
	//	[self setPDFDocument:_templatesTableView];
	
	[_pdfView setAutoScales:YES];
	
//	[[self window] setFrameAutosaveName:@"ArthroplastyTemplatingsPluginWindow"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(templateDragged:) name:@"PluginDragOperationNotification" object:nil];
	//[templatesTableView registerForDraggedTypes:[NSArray arrayWithObject:ArthroplastyTemplatingDataType]];
	
	[[self window] makeKeyAndOrderFront:self]; // TODO: remove
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_templates release];
	[super dealloc];
}

- (void)windowDidLoad {
	[_templatesTableView selectRow:0 byExtendingSelection:NO];
	[self setPDFDocument:_templatesTableView];
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
	[_templatesTableView reloadData];
	[_templatesTableView selectRow:0 byExtendingSelection:NO];
	//	[self didChangeValueForKey:@"templates"];}
}

-(ArthroplastyTemplate*)templateAtPath:(NSString*)path {
	for (unsigned i = 0; i < [_templates count]; ++i)
		if ([[[_templates objectAtIndex:i] referenceFilePath] isEqualToString:path])
			return [_templates objectAtIndex:i];
	return NULL;
}

-(ArthroplastyTemplate*)templateAtIndex:(int)index {
	return [[_templatesArrayController arrangedObjects] objectAtIndex:index];	
}

-(ArthroplastyTemplate*)selectedTemplate {
	return [self templateAtIndex:[_templatesTableView selectedRow]];
}

#pragma mark PDF preview

-(NSString*)pdfPathForTemplateAtIndex:(int)index {
	return [[self templateAtIndex:index] pdfPathForDirection:_viewDirection];
}

-(void)setPDFDocument:(id)sender {
	if([sender selectedRow]<0) return;
	
	NSString *pdfPath = [self pdfPathForTemplateAtIndex:[sender selectedRow]];
	
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

-(void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	[self setPDFDocument:[aNotification object]];
}


#pragma mark Template View direction

- (IBAction)setViewDirection:(id)sender; {
	if([sender selectedSegment] == 0)
		_viewDirection = ArthroplastyTemplateAnteriorPosteriorDirection;
	else _viewDirection = ArthroplastyTemplateLateralDirection;
	
//	[self loadTemplates]; // TODO: gray out unavailable templates
	[self setPDFDocument:_templatesTableView];
}


#pragma mark Flip Left/Right

-(IBAction)flipLeftRight:(id)sender {
	if ([sender state]==NSOnState)
		_flipTemplatesHorizontally = YES;
	else _flipTemplatesHorizontally = NO;
}


#pragma mark Drag n Drop

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard 
{
    // Copy the row numbers to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:PluginDataType] owner:self];
    [pboard setData:data forType:PluginDataType];
    return YES;
}

- (void)templateDragged:(NSNotification *)notification;
{
	NSDictionary *userInfo = [notification userInfo];
	[self draggedOperation:[userInfo valueForKey:@"dragOperation"] onDestination:[userInfo valueForKey:@"destination"]];
}
		
- (void)draggedOperation:(id <NSDraggingInfo>)operation onDestination:(id)destination;
{
	if(![[operation draggingSource] isEqualTo:_templatesTableView]) return;
	
	NSData *data = [[operation draggingPasteboard] dataForType:PluginDataType];
	NSIndexSet *rowIndexes = (NSIndexSet*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
	if([rowIndexes count]>1) return;
	
	NSString *pdfPath = [self pdfPathForTemplateAtIndex:[rowIndexes firstIndex]];
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:pdfPath];
	NSColor *backgroundColor = [NSColor clearColor];

	[image setScalesWhenResized:YES];
	NSSize imageSize = [image size];
	float newHeight = 1800.0;
	float ratio = imageSize.height / newHeight;
	int newWidth = imageSize.width / ratio;
	newWidth /= 2;
	newWidth *= 2;
	NSSize newSize = NSMakeSize(newWidth, newHeight);
	[image setSize:newSize];

	NSRect croppingRect = [self boundingBoxOfImage:image withBackgroundColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0]];
	croppingRect = [self addMargin:10 toRect:croppingRect];

	NSImage *croppedImage = [image croppedImageInRectangle:croppingRect];
	[croppedImage setBackgroundColor:backgroundColor];
		
//	NSColor *backgroundColorWhenSelected = [[NSColor cyanColor] colorWithAlphaComponent:0.3];
//	NSImage *imageSelected = [[NSImage alloc] initWithContentsOfFile:pdfPath];
//	[imageSelected setBackgroundColor:backgroundColorWhenSelected];
//	
//	[imageSelected setScalesWhenResized:YES];
//	[imageSelected setSize:newSize];
//	
//	NSImage *croppedImageWhenSelected = [imageSelected croppedImageInRectangle:croppingRect];
	
	if(_flipTemplatesHorizontally)
	{
		[croppedImage flipImageHorizontally];
//		[croppedImageWhenSelected flipImageHorizontally];
	}
	
	float pixSpacing = 1.0 / 72.0 * 25.4; // image is in 72 dpi, we work in milimeters
	pixSpacing = pixSpacing * ratio;
	
	// create the template layer
//	ROI *newLayer = [(ViewerController*)destination addLayerRoiToCurrentSliceWithImage:croppedImage imageWhenSelected:croppedImageWhenSelected referenceFilePath:@"test" layerPixelSpacingX:pixSpacing layerPixelSpacingY:pixSpacing];
	ROI *newLayer = [(ViewerController*)destination addLayerRoiToCurrentSliceWithImage:croppedImage referenceFilePath:[[self templateAtIndex:[rowIndexes firstIndex]] referenceFilePath] layerPixelSpacingX:pixSpacing layerPixelSpacingY:pixSpacing];
	[image release];
//	[imageSelected release];
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
	[newLayer setName:[self nameForTemplateAtIndex:[rowIndexes firstIndex]]];
	NSArray *lines = [self textualDataForTemplateAtIndex:[rowIndexes firstIndex]];
	if([lines objectAtIndex:0]) [newLayer setTextualBoxLine1:[lines objectAtIndex:0]];
	if([lines objectAtIndex:1]) [newLayer setTextualBoxLine2:[lines objectAtIndex:1]];
	if([lines objectAtIndex:2]) [newLayer setTextualBoxLine3:[lines objectAtIndex:2]];
	if([lines objectAtIndex:3]) [newLayer setTextualBoxLine4:[lines objectAtIndex:3]];
	if([lines objectAtIndex:4]) [newLayer setTextualBoxLine5:[lines objectAtIndex:4]];
}


#pragma mark Image

- (NSRect)boundingBoxOfImage:(NSImage*)image withBackgroundColor:(NSColor*)backgroundColor;
{	
	NSBitmapImageRep *bitmap;
	bitmap = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
	
	NSSize imageSize = [image size];
	float height = imageSize.height;
	float width = imageSize.width;
	
	NSColor *currentPixelColor = backgroundColor;
	
	int i=0;
	int x=0, y=0;
	while([currentPixelColor isEqualTo:backgroundColor])
	{
		x = i % (int)width;
		y = i / (int)width;
		currentPixelColor = [bitmap colorAtX:x y:y];
		i++;
	}
	int minY = y;

	currentPixelColor = backgroundColor;
	i = height * width - 1;
	while([currentPixelColor isEqualTo:backgroundColor])
	{
		x = i % (int)width;
		y = i / (int)width;
		currentPixelColor = [bitmap colorAtX:x y:y];
		i--;
	}
	int maxY = y;
	
	currentPixelColor = backgroundColor;
	i = 0;
	while([currentPixelColor isEqualTo:backgroundColor])
	{
		x = i / (int)height;
		y = i % (int)height;
		currentPixelColor = [bitmap colorAtX:x y:y];
		i++;
	}
	int minX = x;

	currentPixelColor = backgroundColor;
	i = height * width - 1;
	while([currentPixelColor isEqualTo:backgroundColor])
	{
		x = i / (int)height;
		y = i % (int)height;
		currentPixelColor = [bitmap colorAtX:x y:y];
		i--;
	}
	int maxX = x;

	int newHeight = maxY-minY+1;
	newHeight /= 2;
	newHeight *= 2;

	int newWidth = maxX-minX+1;
	newWidth /= 2;
	newWidth *= 2;
	
	[bitmap release];
	
	return NSMakeRect(minX, height-maxY, newWidth, newHeight);
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

- (NSString*)nameForTemplateAtIndex:(int)index;
{
	ArthroplastyTemplate *template = [self templateAtIndex:index];
	return [template name];
}

- (NSArray*)textualDataForTemplateAtIndex:(int)index;
{
	ArthroplastyTemplate *template = [self templateAtIndex:index];
	return [template textualData];
}


//#pragma mark Keyboard
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

@end
