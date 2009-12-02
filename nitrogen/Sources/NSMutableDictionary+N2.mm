//
//  NSMutableDictionary+N2.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 17.11.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "NSMutableDictionary+N2.h"
#import "NSDictionary+N2.h"


@implementation NSMutableDictionary (N2)

-(void)removeObject:(id)obj {
	[self removeObjectForKey:[self keyForObject:obj]];
}

@end
