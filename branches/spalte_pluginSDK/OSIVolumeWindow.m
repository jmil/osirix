//
//  OSIVolumeWindow.m
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import "OSIVolumeWindow.h"
#import "OSIVolumeWindow+Private.h"
#import "OSIROIManager.h"

NSString* const OSIVolumeWindowDidCloseNotification = @"OSIVolumeWindowDidCloseNotification";

@implementation OSIVolumeWindow

// don't call this!
- (id)init
{
	assert(0);
	[self autorelease];
	self = nil;
	return self;
}

- (void)dealloc
{
	[_viewerController release];
	_viewerController = nil;
	_ROIManager.delegate = nil;
	[_ROIManager release];
	_ROIManager = nil;
	[super dealloc];
}

- (ViewerController *)viewerController // if you really want to go into the depths of OsiriX, use at your own peril!
{
	return _viewerController;
}

- (BOOL)isOpen
{
	return (_viewerController ? YES : NO);
}

- (OSIROIManager *)ROIManager
{
	return _ROIManager;
}

- (NSString *)title
{
	return [[_viewerController window] title];
}

@end

@implementation OSIVolumeWindow (Private)

- (id)initWithViewerController:(ViewerController *)viewerController
{
	if ( (self = [super init]) ) {
		_viewerController = [viewerController retain];
		_ROIManager = [[OSIROIManager alloc] initWithVolumeWindow:self];
		_ROIManager.delegate = self;
	}
	return self;
}

- (void)viewerControllerDidClose
{
	[_viewerController release];
	[self willChangeValueForKey:@"open"];
	_viewerController = nil;
	[self didChangeValueForKey:@"open"];
	[[NSNotificationCenter defaultCenter] postNotificationName:OSIVolumeWindowDidCloseNotification object:self];
}

@end
