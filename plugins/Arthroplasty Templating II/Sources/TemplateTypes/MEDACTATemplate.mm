//
//  MEDACTATemplate.mm
//  Arthroplasty Templating II
//
//  Created by Alessandro Volz on 07.09.09.
//  Copyright (c) 2009 OsiriX Team. All rights reserved.
//

#import "MEDACTATemplate.h"

@implementation MEDACTATemplate

+(NSArray*)bundledTemplates {
	return [ZimmerTemplate templatesAtPath:[[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/MEDACTA Templates"] usingClass:[MEDACTATemplate class]];
}

-(CGFloat)rotation {
	NSString* rotationString = [_properties objectForKey:@"AP_HEAD_ROTATION_RADS"];
	return rotationString? [rotationString floatValue] : 0;
}

@end
