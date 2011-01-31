/*
 *  OSIVolumeWindow+Private.h
 *  OsiriX
 *
 *  Created by Joël Spaltenstein on 1/26/11.
 *  Copyright 2011 OsiriX Team. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import "OSIVolumeWindow.h"

@class ViewerController;

@interface OSIVolumeWindow (Private)

- (id)initWithViewerController:(ViewerController *)viewerController;
- (void)viewerControllerDidClose;

@end




