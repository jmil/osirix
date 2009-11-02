//
//  90degFilter.h
//  90deg
//
//  Copyright (c) 2009 OsiriX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OsiriX Headers/PluginFilter.h>

@interface NinetyDegreesFilter : PluginFilter {
	NSMutableArray* _ndrois;
}

-(long)filterImage:(NSString*)menuName;

@end
