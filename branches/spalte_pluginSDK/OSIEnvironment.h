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

/**  
 
 The OSIEnvironment class is the main access point into the OsiriX Plugin SDK. It provides access to the list of Viewer Windows that are currently open.
 Whenever a Viewer Window is opened or closed a OSIEnvironmentOpenVolumeWindowsDidUpdateNotification is posted. 
 
 */

extern NSString* const OSIEnvironmentOpenVolumeWindowsDidUpdateNotification; 


@interface OSIEnvironment : NSObject {
	NSMutableDictionary *_volumeWindows;
}


///-----------------------------------
/// @name Obtaining the Shared Environment Object
///-----------------------------------

/** Returns the shared `OSIEnvironment` instance.
 
 @return The shared `OSIEnvironment` instance
 */
+ (OSIEnvironment *)sharedEnvironment;

///-----------------------------------
/// @name Managing Volume Windows
///-----------------------------------

/** Returns the `OSIVolumeWindow` object that is paired with the given viewerController
 
 @return The Volume Window for cooresponding to the viewerController.
 @param viewerController The Viewer Controller for which to return a Volume Window.
 */
- (OSIVolumeWindow *)volumeWindowForViewerController:(ViewerController *)viewerController;

// I don't like the name because "open" can be taken to be meant as the verb not the adjective

/** Returns an array of all the displayed Volume Windows
 
 This property is observable using key-value observing.
 
 @return An array of OSIVolumeWindow objects.
 */
- (NSArray *)openVolumeWindows; // this is observeable

/** Returns the frontmost Volume Window
 
 @return The frontmost Volume Window.
 */
- (OSIVolumeWindow *)frontmostVolumeWindow; // not observable will return nil if there is no reasonable frontmost controller, 

// this probably should be mainVolumeWindow, but do all the windows behave nicely?

// not done

//- (NSArray *)openFloatVolumes; // returns OSIVolumeData
//- (NSArray *)openStudies; // returns all the studies that are open somewhere in the app // will this be KVO-able?


@end
