//
//  OSIEnvironment.m
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import "OSIEnvironment.h"
#import "OSIEnvironment+Private.h"
#import "OSIVolumeWindow.h"
#import "OSIVolumeWindow+Private.h"
#import "ViewerController.h"

static OSIEnvironment *sharedEnvironment = nil;

@implementation OSIEnvironment

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	if ([key isEqualToString:@"openVolumeWindows"]) {
		return NO;
	}
	
	return YES;
}

+ (OSIEnvironment*)sharedEnvironment
{
	@synchronized (self) {
		if (sharedEnvironment == nil) {
			sharedEnvironment = [[super allocWithZone:NULL] init];
		}
	}
    return sharedEnvironment;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedEnvironment] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (id)init
{
	if ( (self = [super init]) ) {
		_volumeWindows = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (OSIVolumeWindow *)volumeWindowForViewerController:(ViewerController *)viewerController
{
	return [_volumeWindows objectForKey:[NSValue valueWithPointer:viewerController]];
}

- (NSArray *)openVolumeWindows
{
	return [_volumeWindows allValues];
}

- (OSIVolumeWindow *)frontmostVolumeWindow
{
	NSArray *windows;
	NSWindow *window;
	NSWindowController *windowController;
	ViewerController *viewerController;
	OSIVolumeWindow *volumeWindow;
	
	windows = [NSApp orderedWindows];
	
	for (window in windows) {
		windowController = [window windowController];
		if ([windowController isKindOfClass:[ViewerController class]]) {
			viewerController = (ViewerController *)windowController;
			volumeWindow = [self volumeWindowForViewerController:viewerController];
			if (volumeWindow) {
				return volumeWindow;
			}
		}
	}
	
	return nil;
}

@end


@implementation OSIEnvironment (Private)

- (void)addViewerController:(ViewerController *)viewerController
{
	OSIVolumeWindow *volumeWindow;
	
	assert([_volumeWindows objectForKey:[NSValue valueWithPointer:viewerController]] == NO); // already added this viewerController!
	
	volumeWindow = [[OSIVolumeWindow alloc] initWithViewerController:viewerController];
	[self willChangeValueForKey:@"openVolumeWindows"];
	[_volumeWindows setObject:volumeWindow forKey:[NSValue valueWithPointer:viewerController]];
	[self didChangeValueForKey:@"openVolumeWindows"];
	[volumeWindow release];
}

- (void)removeViewerController:(ViewerController *)viewerController
{
	assert([_volumeWindows objectForKey:[NSValue valueWithPointer:viewerController]] == NO); // already added this viewerController!
	
	[self willChangeValueForKey:@"openVolumeWindows"];
	[_volumeWindows removeObjectForKey:[NSValue valueWithPointer:viewerController]];
	[self didChangeValueForKey:@"openVolumeWindows"];
}

@end























