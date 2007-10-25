//
//  NSImage+XRayTemplatePlugin.m
//  XRayTemplatesPlugin
//
//  Created by Joris Heuberger on 10/25/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//

#import "NSImage+XRayTemplatePlugin.h"
#include <Accelerate/Accelerate.h>

@implementation NSImage (XRayTemplatePlugin)

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
