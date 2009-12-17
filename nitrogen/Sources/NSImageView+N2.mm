//
//  NSImageWell.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 02.12.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "NSImageView+N2.h"
#import "NSImage+N2.h"
#import <Nitrogen/N2Operators.h>
#include <algorithm>

@implementation NSImageView (N2)

+(id)createWithImage:(NSImage*)image {
	id view = [[self alloc] initWithSize:[image size]];
	[view setImage:image];
	return [view autorelease];
}

-(NSSize)optimalSize {
	return n2::ceil([[self image] size]);
}

-(NSSize)optimalSizeForWidth:(CGFloat)width {
	NSSize imageSize = [[self image] size];
	if (width == CGFLOAT_MAX) width = imageSize.width;
	return n2::ceil(NSMakeSize(width, width/imageSize.width*imageSize.height));
}

@end

@implementation N2ImageView 

-(void)setFrameSize:(NSSize)newSize {
	if ([[self image] isLogicallyResizable])
		[[self image] setSize:newSize];
	[super setFrameSize:newSize];
}

@end