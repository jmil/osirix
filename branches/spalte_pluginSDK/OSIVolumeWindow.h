//
//  OSIVolumeWindow.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSIROIManager.h"

extern NSString* const OSIVolumeWindowDidCloseNotification; 

// This is a peer of the ViewerController. It provides an abstract and cleaner interface to the ViewerController
// for now 

// it really is the window that is showing stuff, so it should be possible to ask the window what the hell it is showing.

// a study is a tag on images, but many differnt studies could be shown in the same window. a specific volume definitly belongs to a study, and it should be possible to
// ask the environment what all the open studies are.

@class OSIFloatVolumeData;
@class OSIROIManager;
@class ViewerController;

@interface OSIVolumeWindow : NSObject <OSIROIManagerDelegate>  {
	ViewerController *_viewerController; // this is retained
	OSIROIManager *_ROIManager;
}

- (ViewerController *)viewerController; // if you really want to go into the depths of OsiriX, use at your own peril!
- (BOOL)isOpen; // observable. Is this VolumeWindow actually connected to a ViewerController. If the ViewerController is closed, the connection will be lost
// but if the plugin is lazy and doesn't close things properly, at least the ViewerController will be released, the memory will be released, and the plugin will just be holding on to
// a super lightweight object

- (OSIROIManager *)ROIManager; // no not mess with the delegate of this ROI manager, but feel free to ask if for it's list of ROIs
- (NSString *)title;


// not done
//- (OSIROIManager *)ROIManager; // no not mess with the delegate of this ROI manager, but feel free to ask if for it's list of ROIs
//- (NSArray *)selectedROIs; // observable list of selected ROIs
//
//- (NSArray *)dimensions; // dimensions other than the 3 natural dimensions
//- (NSUInteger)depthOfDimension:(NSString *)dimension; // I don't like this name
//
//- (OSIFloatVolumeData *)floatVolumeDataForDimensionsAndIndexes:(id)firstDimenstion, ... NS_REQUIRES_NIL_TERMINATION;
//
//- (OSIFloatVolumeData *)displayedFloatVolumeData;


@end
