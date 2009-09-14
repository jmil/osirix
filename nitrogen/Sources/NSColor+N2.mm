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
	
	for (NSInteger i = 0; i < numberOfComponents; ++i)
		if (c1components[i] != c2components[i])
			return NO;
	
	return YES;
}

@end
