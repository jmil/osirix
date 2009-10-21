//
//  NSDictionary+N2.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 22.09.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "NSDictionary+N2.h"


@implementation NSDictionary (N2)

-(id)objectForKey:(NSString*)k ofClass:(Class)cl {
	if (![self isKindOfClass:[NSDictionary class]])
		[NSException raise:NSGenericException format:@"NSDictionary expected, actually %@", [self className]];
	id o = [self objectForKey:k];
	if (o && ![o isKindOfClass:cl])
		[NSException raise:NSGenericException format:@"%s expected, actually %@", [[NSClassDescription classDescriptionForClass:cl] description], [o className]];\
	return o;
}

@end
