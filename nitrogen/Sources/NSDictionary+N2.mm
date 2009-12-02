//
//  NSDictionary+N2.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 22.09.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "NSDictionary+N2.h"


@implementation NSDictionary (N2)

-(id)objectForKey:(id)key ofClass:(Class)cl {
	id obj = [self objectForKey:key];
	if (obj && ![obj isKindOfClass:cl])
		[NSException raise:NSGenericException format:@"%s expected, actually %@", [[NSClassDescription classDescriptionForClass:cl] description], [obj className]];\
	return obj;
}

-(id)keyForObject:(id)obj {
	for (id key in self)
		if ([self objectForKey:key] == obj)
			return key;
	return NULL;
}

@end
