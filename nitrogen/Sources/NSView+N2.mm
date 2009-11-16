//
//  NSView+N2.m
//  Nitrogen
//
//  Created by Alessandro Volz on 11.11.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "NSView+N2.h"
#import "N2Operators.h"


@implementation NSView (N2)

-(id)initWithSize:(NSSize)size {
	return [self initWithFrame:NSMakeRect(NSZeroPoint, size)];
}

@end
