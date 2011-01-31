//
//  pluginSDKAdditions.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewerController.h"
#import "CPRGeometry.h"
#import "DCMPix.h"

@class OSIVolumeWindow;

@interface ViewerController (PluginSDKAdditions)

- (OSIVolumeWindow *)volumeWindow;

@end

@interface DCMPix (PluginSDKAdditions)

- (CPRAffineTransform3D)pixToDicomTransform; // converts points in the DCMPix's coordinate space ("Slice Coordinates") into the DICOM space (patient space with mm units)

@end
