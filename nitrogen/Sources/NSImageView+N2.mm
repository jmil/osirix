//
//  NSImageWell.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 02.12.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "NSImageView+N2.h"
#include <algorithm>

@implementation NSImageView (N2)

+(NSImageView*)createWithImage:(NSImage*)image {
	NSImageView* view = [[NSImageView alloc] initWithSize:[image size]];
	[view setImage:image];
	return [view autorelease];
}

-(NSSize)optimalSize {
	return [[self image] size];
}

-(NSSize)optimalSizeForWidth:(CGFloat)width {
	NSSize imageSize = [[self image] size];
	if (width == CGFLOAT_MAX) width = imageSize.width;
	return NSMakeSize(width, width/imageSize.width*imageSize.height);
}

@end
