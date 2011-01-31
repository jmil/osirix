//
//  pluginSDKAdditions.m
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import "pluginSDKAdditions.h"
#import "OSIEnvironment.h"
#import "OSIVolumeWindow.h"

@implementation ViewerController (PluginSDKAdditions)

- (OSIVolumeWindow *)volumeWindow
{
	return [[OSIEnvironment sharedEnvironment] volumeWindowForViewerController:self];
}

@end


@implementation DCMPix (PluginSDKAdditions)

- (CPRAffineTransform3D)pixToDicomTransform // converts points in the DCMPix's coordinate space ("Slice Coordinates") into the DICOM space (patient space with mm units)
{
    CPRAffineTransform3D pixToDicomTransform;
    double spacingX;
    double spacingY;
    //    double spacingZ;
    double pixOrientation[9];
    
    memset(pixOrientation, 0, sizeof(double) * 9);
    [self orientationDouble:pixOrientation];
    spacingX = [self pixelSpacingX];
    spacingY = [self pixelSpacingY];
    //    spacingZ = pix.sliceInterval;
    
    pixToDicomTransform = CPRAffineTransform3DIdentity;
    pixToDicomTransform.m41 = [self originX];
    pixToDicomTransform.m42 = [self originY];
    pixToDicomTransform.m43 = [self originZ];
    pixToDicomTransform.m11 = pixOrientation[0]*spacingX;
    pixToDicomTransform.m12 = pixOrientation[1]*spacingX;
    pixToDicomTransform.m13 = pixOrientation[2]*spacingX;
    pixToDicomTransform.m21 = pixOrientation[3]*spacingY;
    pixToDicomTransform.m22 = pixOrientation[4]*spacingY;
    pixToDicomTransform.m23 = pixOrientation[5]*spacingY;
    pixToDicomTransform.m31 = pixOrientation[6];
    pixToDicomTransform.m32 = pixOrientation[7];
    pixToDicomTransform.m33 = pixOrientation[8];
    
    return pixToDicomTransform;
}


@end