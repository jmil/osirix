/*
 *  OSIROI+private.h
 *  OsiriX
 *
 *  Created by Joël Spaltenstein on 1/27/11.
 *  Copyright 2011 OsiriX Team. All rights reserved.
 *
 */

#import "OSIROI.h"
#import "OSIPlanarPathROI.h"
#import "N3Geometry.h"

@class ROI;
@class OSIFloatVolumeData;

@interface OSIROI (Private)

+ (id)ROIWithOsiriXROI:(ROI *)roi pixToDICOMTransfrom:(N3AffineTransform)pixToDICOMTransfrom homeFloatVolumeData:(OSIFloatVolumeData *)floatVolumeData;
+ (id)ROICoalescedWithOSIROIs:(NSArray *)rois;

@end

@interface OSIPlanarPathROI (Private)

- (id)initWithOsiriXROI:(ROI *)roi pixToDICOMTransfrom:(N3AffineTransform)pixToDICOMTransfrom homeFloatVolumeData:(OSIFloatVolumeData *)floatVolumeData;

@end