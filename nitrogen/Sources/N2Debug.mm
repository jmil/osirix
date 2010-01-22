//
//  N2Debug.mm
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 6/25/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2Debug.h>

@implementation N2Debug

static BOOL _active = NO;

+(BOOL)isActive {
	return _active;
}

+(void)setActive:(BOOL)active {
	_active = active;
}

@end