//
//  NSImage+Extras.m
//  Arthroplasty Templating II
//  Created by Alessandro Volz on 5/27/09.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "NSImage+ArthroplastyTemplating.h"
#include <Accelerate/Accelerate.h>


@implementation NSImage (ArthroplastyTemplating)

- (NSImage*)croppedImageInRectangle:(NSRect)rect {
	NSImage* croppedImage = [[NSImage alloc] initWithSize:rect.size];
	[croppedImage lockFocus];
	[self compositeToPoint:NSMakePoint(0, 0) fromRect:rect operation:NSCompositeSourceOver fraction:0];
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

-(NSRect)boundingBoxSkippingColor:(NSColor*)color {
	NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]];
	NSSize imageSize = [self size];
	NSRect box = NSMakeRect(0, 0, imageSize.width, imageSize.height);
	
	int x, y;
	// change origin.x
	for (x = box.origin.x; x < box.origin.x+box.size.width; ++x)
		for (y = box.origin.y; y < box.origin.y+box.size.width; ++y)
			if (![[bitmap colorAtX:x y:y] isEqualTo:color])
				goto end_origin_x;
	end_origin_x:
	if (x < box.origin.x+box.size.width) {
		box.size.width -= x-box.origin.x;
		box.origin.x = x;
	}
	
	// change origin.y
	for (y = box.origin.y; y < box.origin.y+box.size.width; ++y)
		for (x = box.origin.x; x < box.origin.x+box.size.width; ++x)
			if (![[bitmap colorAtX:x y:imageSize.height-y-1] isEqualTo:color])
				goto end_origin_y;
	end_origin_y:
	if (y < box.origin.y+box.size.height) {
		box.size.height -= y-box.origin.y;
		box.origin.y = y;
	}
	
	// change size.width
	for (x = box.origin.x+box.size.width-1; x >= box.origin.x; --x)
		for (y = box.origin.y; y < box.origin.y+box.size.width; ++y)
			if (![[bitmap colorAtX:x y:y] isEqualTo:color])
				goto end_size_x;
	end_size_x:
	if (x >= box.origin.x)
		box.size.width = x-box.origin.x+1;
	
	// change size.height
	for (y = box.origin.y+box.size.height-1; y >= box.origin.y; --y)
		for (x = box.origin.x; x < box.origin.x+box.size.width; ++x)
			if (![[bitmap colorAtX:x y:imageSize.height-y-1] isEqualTo:color])
				goto end_size_y;
	end_size_y:
	if (y >= box.origin.y)
		box.size.height = y-box.origin.y+1;
	
	[bitmap release];
	return box;
}




@end