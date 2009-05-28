//
//  PetSpectFusion.m
//  PetSpectFusion
//
//  Copyright (c) 2008 - 2009 Brian Jensen. All rights reserved.
//

#import <Foundation/NSDebug.h>

#import "PetSpectFusion.h"
#import "SettingsWindowController.h"

@implementation PetSpectFusion

- (void) initPlugin
{
	//TODO init plugin here
}

- (void) dealloc
{
	DebugLog(@"PetSpectFusion dealloc called!");
	[super dealloc];
}

- (long) filterImage:(NSString*) menuName
{	
	if([viewerController blendedWindow] == nil)
	{
		NSLog(@"PetSpectFusion aborting, blending viewer is not defined");
		return 0;
	}
	
	NSLog(@"PetSpectFusion started");
	
	//change titles
	[[[viewerController blendedWindow] window] setTitle: [[[[viewerController blendedWindow] window] title] stringByAppendingString:@" :: Moving Image"]];
	[[viewerController window] setTitle: [[[viewerController window] title] stringByAppendingString:@" :: Fixed Image"]];
	NSString* movingCLUTMenu = [[[viewerController blendedWindow] curCLUTMenu] retain];
	ITKNS::MultiThreader::SetGlobalDefaultNumberOfThreads(MPProcessors());
	
	//activate the controller window
	//if(controller==nil)
	//	controller = [[SettingsWindowController alloc] initWithFixedImageViewer:viewerController movingImageViewer:[viewerController blendedWindow]];

	SettingsWindowController* controller = [[SettingsWindowController alloc] initWithFixedImageViewer:viewerController movingImageViewer:[viewerController blendedWindow]];
	
	//activate blending
	[viewerController blendWithViewer:[viewerController blendedWindow] blendingType:1];
	[[viewerController blendingController] ApplyCLUTString:movingCLUTMenu];
	[[viewerController window] performZoom: self];
	
	//Make sure to catch the viewer closing events for both of the viewers
	[[NSNotificationCenter defaultCenter]  addObserver:controller 
										   selector:@selector(viewerWillClose:) name:@"CloseViewerNotification" 
										   object:viewerController];
	
	[[NSNotificationCenter defaultCenter]  addObserver:controller
										   selector:@selector(viewerWillClose:) name:@"CloseViewerNotification" 
										   object:[viewerController blendedWindow]];
	
	return 0;

}


@end
