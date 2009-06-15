//
//  NSImage+Extras.m
//  Arthroplasty Templating II
//  Created by Alessandro Volz on 5/27/09.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "NSImage+ArthroplastyTemplating.h"
#include <Accelerate/Accelerate.h>
#include <vector>
#include <algorithm>

@implementation ATImage
@synthesize inchSize = _inchSize;

-(id)initWithContentsOfFile:(NSString*)path {
	self = [super initWithContentsOfFile:path];
	NSSize size = [self size];
	_inchSize = NSMakeSize(size.width/72, size.height/72);
	return self;
}

-(id)initWithSize:(NSSize)size inches:(NSSize)inches {
	self = [super initWithSize:size];
	_inchSize = inches;
	return self;
}

-(void)setSize:(NSSize)size {
	NSSize oldSize = [self size];
	if (![self scalesWhenResized])
		_inchSize = NSMakeSize(_inchSize.width/oldSize.width*size.width, _inchSize.height/oldSize.height*size.height);
	[super setSize:size];
}

-(ATImage*)crop:(NSRect)cropRect {
	NSSize size = [self size];
	
	ATImage* croppedImage = [[ATImage alloc] initWithSize:cropRect.size inches:NSMakeSize(_inchSize.width/size.width*cropRect.size.width, _inchSize.height/size.height*cropRect.size.height)];
	
	[croppedImage lockFocus];
	[self compositeToPoint:NSZeroPoint fromRect:cropRect operation:NSCompositeSourceOver fraction:0];
	[croppedImage unlockFocus];
	
	return [croppedImage autorelease];
}

-(float)resolution {
	NSSize size = [self size];
	return (size.width+size.height)/(_inchSize.width+_inchSize.height);
}

@end


@implementation NSImage (ArthroplastyTemplating)



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


@implementation NSBitmapImageRep (ArthroplastyTemplating)

struct P {
	unsigned x, y;
	P(unsigned x, unsigned y) : x(x), y(y) {}
};

#include <iostream>

-(void)ATMask:(float)level {
	NSSize size = [self size];
	unsigned width = size.width, height = size.height;
	float v[width][height];
	
	for (unsigned x = 0; x < width; ++x)
		for (unsigned y = 0; y < height; ++y)
			v[x][y] = [[self colorAtX:x y:y] alphaComponent];
	
	BOOL mask[width][height];
	memset(mask, YES, sizeof(mask));
	BOOL visited[width][height];
	memset(visited, NO, sizeof(visited));

	std::vector<P> ps;
	for (unsigned x = 0; x < width; ++x) {
		ps.push_back(P(x, 0));
		ps.push_back(P(x, height-1));
	} for (unsigned y = 1; y < height-1; ++y) {
		ps.push_back(P(0, y));
		ps.push_back(P(width-1, y));
	}
	
	while (!ps.empty()) {
		P p = ps.back();
		ps.pop_back();
		
		if (visited[p.x][p.y]) continue;
		visited[p.x][p.y] = YES;
		
		if (!v[p.x][p.y]) {
			mask[p.x][p.y] = NO;
			if (p.x > 0 && !visited[p.x-1][p.y]) ps.push_back(P(p.x-1, p.y));
			if (p.y > 0 && !visited[p.x][p.y-1]) ps.push_back(P(p.x, p.y-1));
			if (p.x < width-1 && !visited[p.x+1][p.y]) ps.push_back(P(p.x+1, p.y));
			if (p.y < height-1 && !visited[p.x][p.y+1]) ps.push_back(P(p.x, p.y+1));
		}
	}
	
	for (unsigned x = 0; x < width; ++x)
		for (unsigned y = 0; y < height; ++y)
			if (mask[x][y])
				[self setColor:[[self colorAtX:x y:y] colorWithAlphaComponent:std::max(v[x][y], level)] atX:x y:y];
}
















@end

