//
//  OSIROI.m
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import "OSIROI.h"
#import "OSIROI+Private.h"
#import "OSIPlanarPathROI.h"
#import "OSICoalescedROI.h"
#import "DCMView.h"
#import "CPRGeometry.h"
#import "ROI.h"

@implementation OSIROI

- (NSString *)name
{
	assert(0);
	return nil;
}

- (NSArray *)convexHull
{
	assert(0);
	return nil;
}

- (OSIROIMask *)ROIMaskForFloatVolumeData:(OSIFloatVolumeData *)floatVolume
{
	return nil;
}

- (NSArray *)osiriXROIs
{
	return [NSArray array];
}

@end

@implementation OSIROI (Private)

+ (id)ROIWithOsiriXROI:(ROI *)roi pixToDICOMTransfrom:(CPRAffineTransform3D)pixToDICOMTransfrom
{
	switch ([roi type]) {
		case tMesure:
		case tOPolygon:
		case tCPolygon:
			return [[[OSIPlanarPathROI alloc] initWithOsiriXROI:roi pixToDICOMTransfrom:pixToDICOMTransfrom] autorelease];
			break;
		default:
			return nil;;
	}
}


+ (id)ROICoalescedWithOSIROIs:(NSArray *)rois
{
	return [[[OSICoalescedROI alloc] initWithOSIROIs:rois] autorelease];
}


@end
