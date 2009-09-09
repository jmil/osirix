//
//  MEDACTATemplate.mm
//  Arthroplasty Templating II
//
//  Created by Alessandro Volz on 07.09.09.
//  Copyright (c) 2009 OsiriX Team. All rights reserved.
//

#import "MEDACTATemplate.h"
#include <sstream>

@implementation MEDACTATemplate

+(NSArray*)bundledTemplates {
	return [ZimmerTemplate templatesAtPath:[[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/MEDACTA Templates"] usingClass:[MEDACTATemplate class]];
}

-(CGFloat)rotation {
	NSString* rotationString = [_properties objectForKey:@"AP_HEAD_ROTATION_RADS"];
	if (!rotationString)
		return 0;
	CGFloat rotation;
	std::istringstream([rotationString UTF8String]) >> rotation;
	return rotation;
}

@end
