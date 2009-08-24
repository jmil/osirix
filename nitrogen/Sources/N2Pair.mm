//
//  N2Pair.mm
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/11/09.
//  Copyright 2009 OsiriX Foundation. All rights reserved.
//

#import <Nitrogen/N2Pair.h>

@implementation N2Pair
@synthesize first = _first, second = _second;

-(id)initWith:(id)first and:(id)second {
	self = [super init];
	
	_first = [first retain];
	_second = [second retain];
	
	return self;
}

-(void)dealloc {
	[_first release];
	[_second release];
	[super dealloc];
}

@end
