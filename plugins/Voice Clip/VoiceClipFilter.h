//
//  VoiceClipFilter.h
//  Duplicate
//
//  Created by Lance Pysher 11/8/06.
//  Copyright (c) 2006 OsiriX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginFilter.h"
#include <Carbon/Carbon.h>

@class VoiceClipController;

@interface VoiceClipFilter : PluginFilter {

	VoiceClipController *voiceClipController;
}

- (long) filterImage:(NSString*) menuName;





@end
