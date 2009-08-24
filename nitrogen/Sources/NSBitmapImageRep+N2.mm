//
//  NSBitmapImageRep+N2.mm
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 07/08/09.
//  Copyright 2009 OsiriX Foundation. All rights reserved.
//

#import <Nitrogen/NSBitmapImageRep+N2.h>
#include <algorithm>

@implementation NSBitmapImageRep (N2)

-(void)setColor:(NSColor*)color {
	for (int y = [self pixelsHigh]-1; y >= 0; --y)
		for (int x = [self pixelsWide]-1; x >= 0; --x) {
			CGFloat saturation, brightness, alpha;
			[[[self colorAtX:x y:y] colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getHue:NULL saturation:&saturation brightness:&brightness alpha:&alpha];
			[self setColor:[NSColor colorWithDeviceHue:[color hueComponent] saturation:[color saturationComponent] brightness:std::max((CGFloat).75, brightness) alpha:alpha] atX:x y:y];
		}
}

-(NSImage*)image {
	NSImage* image = [[NSImage alloc] initWithSize:[self size]];
	[image addRepresentation:[[self copy] autorelease]];
	return [image autorelease];
}

-(NSBitmapImageRep*)repUsingColorSpaceName:(NSString*)colorSpaceName {
	if ([[self colorSpaceName] isEqualToString:colorSpaceName])
		return self;
	
	NSInteger spp = [self hasAlpha]? 1 : 0;
	
	if ([colorSpaceName isEqualToString:NSCalibratedWhiteColorSpace]
	||	[colorSpaceName isEqualToString:NSCalibratedBlackColorSpace]
	||	[colorSpaceName isEqualToString:NSDeviceWhiteColorSpace]
	||	[colorSpaceName isEqualToString:NSDeviceBlackColorSpace])
		spp += 1;
	else if ([colorSpaceName isEqualToString:NSCalibratedRGBColorSpace]
	||	[colorSpaceName isEqualToString:NSDeviceRGBColorSpace])
		spp += 3;
	else if ([colorSpaceName isEqualToString:NSDeviceCMYKColorSpace])
		spp += 4;
	else
		[NSException raise:NSInvalidArgumentException format:@"invalid color space"];
	
	NSBitmapImageRep* rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:[self pixelsWide] pixelsHigh:[self pixelsHigh] bitsPerSample:8 samplesPerPixel:spp hasAlpha:[self hasAlpha] isPlanar:NO colorSpaceName:colorSpaceName bytesPerRow:0 bitsPerPixel:0];
	for (int y = [self pixelsHigh]-1; y >= 0; --y)
		for (int x = [self pixelsWide]-1; x >= 0; --x)
			[rep setColor:[[self colorAtX:x y:y] colorUsingColorSpaceName:colorSpaceName] atX:x y:y];
	
	return [rep autorelease];
}


@end
