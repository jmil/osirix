//
//  EjectionFraction.h
//  Ejection Fraction II
//
//  Created by Alessandro Volz on 7/20/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <OsiriX Headers/PluginFilter.h>

@interface EjectionFractionPlugin : PluginFilter {
	NSMutableArray* _wfs;
}

-(long)filterImage:(NSString*)menuName;

@end
