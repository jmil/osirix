/*=========================================================================
 Program:   OsiriX
 
 Copyright (c) OsiriX Team
 All rights reserved.
 Distributed under GNU - LGPL
 
 See http://www.osirix-viewer.com/copyright.html for details.
 
 This software is distributed WITHOUT ANY WARRANTY; without even
 the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 PURPOSE.
 =========================================================================*/

#import "OSIFloatVolumeData.h"


@implementation OSIFloatVolumeData

@dynamic pixelsWide;
@dynamic pixelsHigh;
@dynamic pixelsDeep;
@dynamic minPixelSpacing;
@dynamic pixelSpacingX;
@dynamic pixelSpacingY;
@dynamic pixelSpacingZ;
@dynamic volumeTransform;

- (const float *)floatBytes
{
	return [super floatBytes];
}

- (void)getFloatData:(void *)buffer range:(NSRange)range
{
	[super getFloatData:buffer range:range];
}

- (float)floatAtPixelCoordinateX:(NSUInteger)x y:(NSUInteger)y z:(NSUInteger)z
{
	return [super floatAtPixelCoordinateX:x y:y z:z];
}

- (float)linearInterpolatedFloatAtDicomVector:(N3Vector)vector
{
	return [super linearInterpolatedFloatAtDicomVector:vector];
}

@end
