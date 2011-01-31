//
//  OSIEnvironment.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OSIVolumeWindow;
@class ViewerController;
// this is a singleton

// the OSI environment owns the volumeWindows


@interface OSIEnvironment : NSObject {
	NSMutableDictionary *_volumeWindows;
}

// done
+ (OSIEnvironment *)sharedEnvironment;

- (OSIVolumeWindow *)volumeWindowForViewerController:(ViewerController *)viewerController;

// I don't like the name because "open" can be taken to be meant as the verb not the adjective
- (NSArray *)openVolumeWindows; // this is observeable
- (OSIVolumeWindow *)frontmostVolumeWindow; // not observable will return nil if there is no reasonable frontmost controller, 
// this probably should be mainVolumeWindow, but do all the windows behave nicely?

// not done

//- (NSArray *)openFloatVolumes; // returns OSIVolumeData
//- (NSArray *)openStudies; // returns all the studies that are open somewhere in the app // will this be KVO-able?


@end
