//
//  VoiceClipFilter.m
//  Duplicate
//
//  Created by Lance Pysher 11/8/06.
//  Copyright (c) 2006 OsiriX. All rights reserved.
//

#import "VoiceClipFilter.h"
#import "browserController.h"
#import"VoiceClipController.h"
#include "DCAudioFileRecorder.h"
#include <sys/param.h>



@implementation VoiceClipFilter

- (void) initPlugin
{

}

- (long) filterImage:(NSString*) menuName
{
	NSLog(@"Voice Clip filter");
	if (!voiceClipController)
		voiceClipController = [[VoiceClipController alloc] init];
		
	[voiceClipController reset];
	[voiceClipController showWindow:nil];
	return -1;
}

- (void)dealloc{
	[super dealloc];
}



@end
