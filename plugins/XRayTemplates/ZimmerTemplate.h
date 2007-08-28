//
//  ZimmerTemplate.h
//  XRayTemplatesPlugin
//
//  Created by joris on 19/03/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XRayTemplate.h"

@interface ZimmerTemplate : XRayTemplate {
	NSString *infoFilePath;
	NSString *anteriorPosteriorPDFFileName, *lateralPDFFileName;
}

+ (NSMutableDictionary*)propertiesFromFileInfoAtPath:(NSString*)path;

@end
