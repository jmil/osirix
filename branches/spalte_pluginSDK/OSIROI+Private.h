/*
 *  OSIROI+private.h
 *  OsiriX
 *
 *  Created by Joël Spaltenstein on 1/27/11.
 *  Copyright 2011 OsiriX Team. All rights reserved.
 *
 */

#import "OSIROI.h"
#import "CPRGeometry.h"

@class ROI;
@class OSIFloatVolumeData;

@interface OSIROI (Private)

+ (id)ROIWithOsiriXROI:(ROI *)roi pixToDICOMTransfrom:(CPRAffineTransform3D)pixToDICOMTransfrom homeFloatVolumeData:(OSIFloatVolumeData *)floatVolumeData;
+ (id)ROICoalescedWithOSIROIs:(NSArray *)rois;

@end