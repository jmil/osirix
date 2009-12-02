//
//  NSImageWell.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 02.12.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "NSImageView+N2.h"


@implementation NSImageView (N2)

+(NSImageView*)createWithImage:(NSImage*)image {
	NSImageView* view = [[NSImageView alloc] initWithSize:[image size]];
	[view setImage:image];
	return [view autorelease];
}

@end
