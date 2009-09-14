//
//  NSColor+N2.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 14.09.09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "NSColor+N2.h"


@implementation NSColor (N2)

-(BOOL)isEqualToColor:(NSColor*)color {
	if (!color) return NO;
	if (color == self) return YES;
	
	NSColor *c1, *c2;
	
	if ([[self colorSpace] isEqual:[color colorSpace]]) {
		c1 = self; c2 = color;
	} else {
		c1 = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		c2 = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	}
	
	NSInteger numberOfComponents = [c1 numberOfComponents];
	CGFloat c1components[numberOfComponents], c2components[numberOfComponents];
	[c1 getComponents:c1components]; [c2 getComponents:c2components];
	
	if (!c1components[numberOfComponents-1] || !c2components[numberOfComponents-1])
		return YES;
	
	for (NSInteger i = 0; i < numberOfComponents-1; ++i) {
		NSLog(@"component %d: %f, %f", i, c1components[i], c2components[i]);
		if (c1components[i] != c2components[i])
			return NO;
	}
	
	return YES;
}

@end
