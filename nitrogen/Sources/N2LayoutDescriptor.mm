//
//  NSLayoutDescriptor.mm
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/13/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2LayoutDescriptor.h>

@implementation N2LayoutDescriptor
@synthesize alignment = _alignment;

+(id)createWithAlignment:(N2Alignment)alignment {
	return [[[N2LayoutDescriptor alloc] initWithAlignment:alignment] autorelease];
}

-(id)initWithAlignment:(N2Alignment)alignment {
	self = [super init];
	_alignment = alignment;
	return self;
}

@end
