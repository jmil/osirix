//
//  NSLayoutDescriptor.mm
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/13/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2ColumnDescriptor.h>

@implementation N2ColumnDescriptor
@synthesize alignment = _alignment, widthConstraints = _widthConstraints;

+(N2ColumnDescriptor*)descriptor {
	return [self descriptorWithWidthConstraints:N2MakeMinMax() alignment:N2Left];
}

+(N2ColumnDescriptor*)descriptorWithWidthConstraints:(const N2MinMax&)widthConstraints alignment:(N2Alignment)alignment {
	return [[[N2ColumnDescriptor alloc] initWithWidthConstraints:widthConstraints alignment:alignment] autorelease];
}

-(N2ColumnDescriptor*)init {
	return [self initWithWidthConstraints:N2MakeMinMax() alignment:N2Left];
}

-(N2ColumnDescriptor*)initWithWidthConstraints:(const N2MinMax&)widthConstraints alignment:(N2Alignment)alignment {
	self = [super init];
	[self setWidthConstraints:widthConstraints];
	[self setAlignment:alignment];
	return self;
}

@end
