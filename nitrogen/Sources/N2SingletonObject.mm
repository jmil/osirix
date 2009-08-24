//
//  N2SingletonObject.mm
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/11/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2SingletonObject.h>

@implementation N2SingletonObject

-(id)init {
	if (!_hasInited) {
		self = [super init];
		_hasInited = YES;
	}
	
	return self;
}

-(id)retain {
	return self;
}

-(void)release {
}

-(id)autorelease {
	return self;
}

-(NSUInteger)retainCount {
	return UINT_MAX;
}

@end
