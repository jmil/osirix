//
//  ArthroplastyTemplatingTableView.m
//  Arthroplasty Templating II
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "ArthroplastyTemplatingTableView.h"
#import "NSImage+Extras.h"

@implementation ArthroplastyTemplatingTableView

- (NSImage *)dragImageForRowsWithIndexes:(NSIndexSet *)dragRows tableColumns:(NSArray *)tableColumns event:(NSEvent*)dragEvent offset:(NSPointPointer)dragImageOffset {
	if([dragRows count]>1) return nil;
	[self selectRowIndexes:dragRows byExtendingSelection:NO];

	int rowIndex = [dragRows firstIndex];

	NSString *pdfPath = [windowController pdfPathForTemplateAtIndex:rowIndex];
	
	// creates an image from the PDF
	NSImage *image0 = [[NSImage alloc] initWithContentsOfFile:pdfPath];

	[image0 setScalesWhenResized:YES];
	NSSize imageSize = [image0 size];
	float newHeight = 250;
	float ratio = imageSize.height / newHeight;
	float newWidth = imageSize.width / ratio;
	NSSize newSize = NSMakeSize(newWidth, newHeight);
	[image0 setSize:newSize];

	NSRect croppingRect = [windowController boundingBoxOfImage:image0 withBackgroundColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0]];
	croppingRect = [windowController addMargin:10 toRect:croppingRect];
	NSImage *image = [image0 croppedImageInRectangle:croppingRect];
	newSize = [image size];

	NSColor *backgroundColor = [[NSColor whiteColor] colorWithAlphaComponent:1];
	[image setBackgroundColor:backgroundColor];

	if([windowController flipTemplatesHorizontally])
		[image flipImageHorizontally];

	// sets a shadow
	#define IMAGE_EXPANSION 15
	NSSize sizeWithShadow = NSMakeSize(newWidth+IMAGE_EXPANSION, newHeight+IMAGE_EXPANSION);
	NSImage *imageWithShadow = [[NSImage alloc] initWithSize:sizeWithShadow];
	[imageWithShadow setBackgroundColor:[NSColor clearColor]];
	
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowOffset:NSMakeSize(2, -2)];

	[imageWithShadow lockFocus];
	[shadow set];
	[[NSColor whiteColor] set];
	
	NSRect frame = NSMakeRect(5, IMAGE_EXPANSION-5, newSize.width, newSize.height);
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:frame];
	[path fill];
	[imageWithShadow unlockFocus];
		
	[imageWithShadow lockFocus];
	[image compositeToPoint:NSMakePoint(5, IMAGE_EXPANSION-5) operation:NSCompositeSourceOver];
	[imageWithShadow unlockFocus];

	[shadow release];

	// make the final image semi-opaque
	NSImage *semiOpaqueImage = [[NSImage alloc] initWithSize:sizeWithShadow];
	[semiOpaqueImage setBackgroundColor:[NSColor clearColor]];
	[semiOpaqueImage lockFocus];
	[imageWithShadow compositeToPoint:NSMakePoint(0, 0) operation:NSCompositeSourceOver fraction:0.9];
	[semiOpaqueImage unlockFocus];

	//return semiOpaqueImage;
	return imageWithShadow;
}

- (BOOL)canDragRowsWithIndexes:(NSIndexSet *)rowIndexes atPoint:(NSPoint)mouseDownPoint {
	return YES;
}

@end
