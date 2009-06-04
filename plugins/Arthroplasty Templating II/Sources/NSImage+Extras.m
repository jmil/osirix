//
//  NSImage+Extras.m
//  Arthroplasty Templating II
//  Created by Alessandro Volz on 5/27/09.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "NSImage+Extras.h"
#include <Accelerate/Accelerate.h>


@implementation NSImage (Additions)

- (NSImage*)croppedImageInRectangle:(NSRect)rect {
	NSImage* croppedImage = [[NSImage alloc] initWithSize:rect.size];
	[croppedImage lockFocus];
	[self compositeToPoint:NSMakePoint(0, 0) fromRect:rect operation:NSCompositeSourceOver fraction:1];
	[croppedImage unlockFocus];
	return [croppedImage autorelease];
}

- (void)flipImageHorizontally {
	// dimensions
	NSSize size = [self size];
	// bitmap init
	NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]];
	// flip
	vImage_Buffer src, dest;
	src.height = dest.height = size.height;
	src.width = dest.width = size.width;
	src.rowBytes = dest.rowBytes = [bitmap bytesPerRow];
	src.data = dest.data = [bitmap bitmapData];
	vImageHorizontalReflect_ARGB8888(&src, &dest, 0L);
	// draw
	[self lockFocus];
	[bitmap draw];
	[self unlockFocus];
	// release
	[bitmap release];
}

@end