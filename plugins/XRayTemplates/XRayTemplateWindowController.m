//
//  XRayTemplateWindowController.m
//  XRayTemplatesPlugin
//
//  Created by joris on 05/03/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//
#include <Accelerate/Accelerate.h>

#import "XRayTemplateWindowController.h"
#import "BrowserController.h"
#import "ViewerController.h"
#import "ROI.h"
#import "DCMView.h"

@interface NSImage (Additions)

- (NSImage*)croppedImageInRectangle:(NSRect)rect;
- (void)flipImageHorizontally;

@end

@implementation NSImage (Additions)

- (NSImage*)croppedImageInRectangle:(NSRect)rect;
{
	NSImage *croppedImage = [[NSImage alloc] initWithSize:rect.size];
	[croppedImage lockFocus];
	[self compositeToPoint:NSMakePoint(0.0, 0.0) fromRect:rect operation:NSCompositeSourceOver fraction:1.0];
	[croppedImage unlockFocus];
	return [croppedImage autorelease];
}

- (void)flipImageHorizontally;
{
	// dimensions
	NSSize size = [self size];
	float width = size.width;
	float height = size.height;
	
	// bitmap init
	NSBitmapImageRep *bitmap;
	bitmap = [[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]];
	int rowBytes = [bitmap bytesPerRow];
	unsigned char *imageBuffer = [bitmap bitmapData];

	// flip
	vImage_Buffer src, dest;
	src.height = dest.height = height;
	src.width = dest.width = width;
	src.rowBytes = dest.rowBytes = rowBytes;
	src.data = imageBuffer;
	dest.data = imageBuffer;
	vImageHorizontalReflect_ARGB8888(&src, &dest, 0L);

	// draw
	[self lockFocus];
	[bitmap draw];
	[self unlockFocus];

	[bitmap release];
}

@end

#pragma mark -

#define PluginDataType @"OsiriXPluginDataType"

@implementation XRayTemplateWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	self = [super initWithWindowNibName:windowNibName];
	if (self != nil)
	{
		viewDirection = XRayTemplateAnteriorPosteriorDirection;
		flipTemplatesHorizontally = NO;
		
		templates = [[NSMutableArray arrayWithCapacity:0] retain];
		[self findTemplates];
		
		[templatesTableView selectRow:0 byExtendingSelection:NO];
		[self setPDFDocument:templatesTableView];
		
		[pdfView setAutoScales:YES];
		
		[[self window] setFrameAutosaveName:@"XRayTemplatesPluginWindow"];
//		[self setWindowFrameAutosaveName:@"XRayTemplatesPluginWindow"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(templateDragged:) name:@"PluginDragOperationNotification" object:nil];
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:@"NSWindowWillCloseNotification" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:@"CloseViewerNotification" object:nil];
	    //[templatesTableView registerForDraggedTypes:[NSArray arrayWithObject:XRayTemplateDataType]];
		
	}
	return self;
}

- (void)dealloc;
{
	NSLog(@"XRayTemplateWindowController dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[templates release];
	[super dealloc];
}

- (void)windowDidLoad
{
	[templatesTableView selectRow:0 byExtendingSelection:NO];
	[self setPDFDocument:templatesTableView];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	if([[aNotification object] isEqualTo:[self window]])
	{
		NSLog(@"XRayTemplateWindowController windowWillClose");
	//	[self release];
	//	NSLog(@"XRayTemplateWindowController released");
	}
}

- (void)viewerWillClose:(NSNotification*)notification;
{
	[self close];
}

#pragma mark -
#pragma mark Templates list

- (NSMutableArray*)templates;
{
	return templates;
}

- (NSMutableArray*)templatesForManufacturer:(XRayTemplateManufacturer)manufacturer;
{
	NSMutableArray *manufacturerTemplates = [NSMutableArray array];
	int i;
	for (i=0; i<[templates count]; i++)
	{
		XRayTemplate *template = [templates objectAtIndex:i];
		if([template manufacturer]==manufacturer)
			[manufacturerTemplates addObject:template];
	}
	return manufacturerTemplates;
}

- (NSMutableArray*)templatesForManufacturer:(XRayTemplateManufacturer)manufacturer withName:(NSString*)name;
{
	NSMutableArray *manufacturerTemplates = [NSMutableArray array];
	int i;
	for (i=0; i<[templates count]; i++)
	{
		XRayTemplate *template = [templates objectAtIndex:i];
		if([template manufacturer]==manufacturer && [[template name] isEqualToString:name])
			[manufacturerTemplates addObject:template];
	}
	return manufacturerTemplates;
}

- (void)findTemplates;
{
	embededTemplateDirectoryPath = [[NSBundle bundleForClass:@"XRayTemplatesPluginFilter"] resourcePath];

	[self willChangeValueForKey:@"templates"];
	[templates removeAllObjects];
	[templates addObjectsFromArray:[self templatesInDirectoryAtPath:embededTemplateDirectoryPath]];
	[self didChangeValueForKey:@"templates"];
}

- (NSMutableArray*)templatesInDirectoryAtPath:(NSString*)path;
{
	NSMutableArray *templatesArray = [NSMutableArray arrayWithCapacity:0];
	
	BOOL isDir = NO;
	int i;
	if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)
	{
		NSArray *content = [[NSFileManager defaultManager] directoryContentsAtPath:path];
		for (i=0; i<[content count]; i++)
		{
			NSString *fileName = [content objectAtIndex:i];
			NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, fileName];
			
			if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] && isDir)
			{
				[templatesArray addObjectsFromArray:[self templatesInDirectoryAtPath:filePath]];
			}
			else
			{
				XRayTemplate *template = [self templateAtPath:filePath];
				if(template)
				{
					[template setViewDirection:viewDirection];
					[templatesArray addObject:template];
					[template release];
				}
			}
		}
	}
	return templatesArray;
}

- (XRayTemplate*)templateAtPath:(NSString*)path;
{
	XRayTemplate *template;
	template = [[ZimmerTemplate alloc] initFromFileAtPath:path];
	if(template) return template;
	
	return nil;
}

- (XRayTemplate*)templateAtIndex:(int)index;
{
	XRayTemplate *template = [[templatesArrayController arrangedObjects] objectAtIndex:index];	
	return template;
}

- (XRayTemplate*)selectedTemplate;
{
	int index = [templatesTableView selectedRow];
	return [self templateAtIndex:index];
}

- (XRayTemplate*)nextSizeForTemplate:(XRayTemplate*)aTemplate;
{
	NSMutableArray *manufacturerTemplates = [self templatesForManufacturer:[aTemplate manufacturer] withName:[aTemplate name]];
	XRayTemplate *nextSizeTemplate = aTemplate;
	
	float maxSize = 9999.99;
	int i;
	for (i=0; i<[manufacturerTemplates count]; i++)
	{
		XRayTemplate *curTemplate = [manufacturerTemplates objectAtIndex:i];
		if([curTemplate sizeValue] > [aTemplate sizeValue] && [curTemplate sizeValue] < maxSize)
		{
			maxSize = [curTemplate sizeValue];
			nextSizeTemplate = curTemplate;
		}
	}
	
	return nextSizeTemplate;
}

- (XRayTemplate*)previousSizeForTemplate:(XRayTemplate*)aTemplate;
{
	NSMutableArray *manufacturerTemplates = [self templatesForManufacturer:[aTemplate manufacturer] withName:[aTemplate name]];
	XRayTemplate *nextSizeTemplate = aTemplate;
	
	float maxSize = 0.0;
	int i;
	for (i=0; i<[manufacturerTemplates count]; i++)
	{
		XRayTemplate *curTemplate = [manufacturerTemplates objectAtIndex:i];
		if([curTemplate sizeValue] < [aTemplate sizeValue] && [curTemplate sizeValue] > maxSize)
		{
			maxSize = [curTemplate sizeValue];
			nextSizeTemplate = curTemplate;
		}
	}
	
	return nextSizeTemplate;
}

#pragma mark -
#pragma mark PDF preview

- (NSString*)PDFPathForTemplateAtIndex:(int)index;
{
	XRayTemplate *template = [self templateAtIndex:index];
	return [template PDFPreviewPath];
}

- (void)setPDFDocument:(id)sender;
{
	if([sender selectedRow]<0) return;
	
	NSString *pdfPath = [self PDFPathForTemplateAtIndex:[sender selectedRow]];
	
	if(!pdfPath) return;
	
//	NSData *pdfData = [NSData dataWithContentsOfFile:pdfPath];
//	PDFDocument *doc = [[PDFDocument alloc] initWithData:pdfData];
	PDFDocument *doc = [[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:pdfPath]];

	NSImage *image = [[NSImage alloc] initByReferencingFile:pdfPath];
	NSMutableDictionary *deviceDictionary = [NSMutableDictionary dictionaryWithObject:[NSValue valueWithSize:NSMakeSize(300,300)] forKey:@"NSDeviceResolution"];
	[deviceDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"NSDeviceIsScreen"];
	[image release];

	
	[pdfView setAutoScales:NO];
	[pdfView setDocument:doc];
	[pdfView setAutoScales:YES];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self setPDFDocument:[aNotification object]];
}

#pragma mark -
#pragma mark Template View direction

- (IBAction)setViewDirection:(id)sender;
{
	if([sender selectedSegment] == 0)
		viewDirection = XRayTemplateAnteriorPosteriorDirection;
	else
		viewDirection = XRayTemplateLateralDirection;
	
	[self findTemplates];
	[self setPDFDocument:templatesTableView];
}

#pragma mark -
#pragma mark Flip Left/Right

- (BOOL)flipTemplatesHorizontally;
{
	return flipTemplatesHorizontally;
}

- (IBAction)flipLeftRight:(id)sender;
{
	if([sender state]==NSOnState)
		flipTemplatesHorizontally=YES;
	else
		flipTemplatesHorizontally=NO;
}

#pragma mark -
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
	if(![[operation draggingSource] isEqualTo:templatesTableView]) return;
	
	NSData *data = [[operation draggingPasteboard] dataForType:PluginDataType];
	NSIndexSet *rowIndexes = (NSIndexSet*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
	if([rowIndexes count]>1) return;
	
	NSString *pdfPath = [self PDFPathForTemplateAtIndex:[rowIndexes firstIndex]];
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

//	NSRect croppingRect = [self boundingBoxOfImage:image withBackgroundColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0]];
	NSRect croppingRect = [self boundingBoxOfImage:image];
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
	
//	NSEvent *event = [[NSApplication sharedApplication] currentEvent];
//
//	if([event modifierFlags] & NSAlternateKeyMask)
//		NSLog(@"NSAlternateKeyMask");
//
//		NSLog(@"[event modifierFlags] : %@", [event modifierFlags]);
		
	if(flipTemplatesHorizontally)
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

- (NSImage*)imageForTemplate:(XRayTemplate*)template pixelSpacing:(float*)pixelSpacing;
{
	NSString *pdfPath = [template PDFPreviewPath];
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

//	NSRect croppingRect = [self boundingBoxOfImage:image withBackgroundColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0]];
	NSRect croppingRect = [self boundingBoxOfImage:image];
	croppingRect = [self addMargin:10 toRect:croppingRect];

	NSImage *croppedImage = [image croppedImageInRectangle:croppingRect];
	[croppedImage setBackgroundColor:backgroundColor];
	if(flipTemplatesHorizontally)
	{
		[croppedImage flipImageHorizontally];
	}
	
	[image release];
	
	*pixelSpacing = 1.0 / 72.0 * 25.4 * ratio; // image is in 72 dpi, we work in milimeters
	
	return croppedImage;
}

#pragma mark -
#pragma mark Image

- (NSRect)boundingBoxOfImage:(NSImage*)image withBackgroundColor:(NSColor*)backgroundColor;
{	
	NSBitmapImageRep *bitmap;
	bitmap = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
	
	NSSize imageSize = [image size];
	int height = imageSize.height;
	int width = imageSize.width;
	
	NSColor *currentPixelColor = backgroundColor;
	
	int i=0;
	int x=0, y=0;
	while([currentPixelColor isEqualTo:backgroundColor])
	{
		x = i % width;
		y = i / width;
		currentPixelColor = [bitmap colorAtX:x y:y];
		i++;
	}
	int minY = y;

	currentPixelColor = backgroundColor;
	i = height * width - 1;
	while([currentPixelColor isEqualTo:backgroundColor])
	{
		x = i % width;
		y = i / width;
		currentPixelColor = [bitmap colorAtX:x y:y];
		i--;
	}
	int maxY = y;
	
	currentPixelColor = backgroundColor;
	i = 0;
	while([currentPixelColor isEqualTo:backgroundColor])
	{
		x = i / height;
		y = i % height;
		currentPixelColor = [bitmap colorAtX:x y:y];
		i++;
	}
	int minX = x;

	currentPixelColor = backgroundColor;
	i = height * width - 1;
	while([currentPixelColor isEqualTo:backgroundColor])
	{
		x = i / height;
		y = i % height;
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

- (NSRect)boundingBoxOfImage:(NSImage*)image;
{	
	NSBitmapImageRep *bitmap;
	bitmap = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
	
	NSSize imageSize = [image size];
	int height = imageSize.height;
	int width = imageSize.width;
	
	unsigned char *imageBuffer = [bitmap bitmapData];
	int bytesPerRow = [bitmap bytesPerRow];
	
	float currentPixelAlpha = 0.0;
	
	int i=0;
	int x=0, y=0;
	while(currentPixelAlpha == 0.0)
	{
		x = i % width;
		y = i / width;
		currentPixelAlpha = imageBuffer[4*x+3+y*bytesPerRow];
		i++;
	}
	int minY = y;

	currentPixelAlpha = 0.0;
	i = height * width - 1;
	while(currentPixelAlpha == 0.0)
	{
		x = i % width;
		y = i / width;
		currentPixelAlpha = imageBuffer[4*x+3+y*bytesPerRow];
		i--;
	}
	int maxY = y;
	
	currentPixelAlpha = 0.0;
	i = 0;
	while(currentPixelAlpha == 0.0)
	{
		x = i / height;
		y = i % height;
		currentPixelAlpha = imageBuffer[4*x+3+y*bytesPerRow];
		i++;
	}
	int minX = x;

	currentPixelAlpha = 0.0;
	i = height * width - 1;
	while(currentPixelAlpha == 0.0)
	{
		x = i / height;
		y = i % height;
		currentPixelAlpha = imageBuffer[4*x+3+y*bytesPerRow];
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

#pragma mark -
#pragma mark ROI

- (NSString*)nameForTemplateAtIndex:(int)index;
{
	XRayTemplate *template = [self templateAtIndex:index];
	return [template name];
}

- (NSArray*)textualDataForTemplateAtIndex:(int)index;
{
	XRayTemplate *template = [self templateAtIndex:index];
	return [template textualData];
}

#pragma mark -
#pragma mark Keyboard

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
