//
//  OSIROI.m
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/25/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import "OSIROI.h"
#import "OSIROI+Private.h"
#import "OSIPathROI.h"
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


@end

@implementation OSIROI (Private)

+ (id)ROIWithOsiriXROI:(ROI *)roi pixToDICOMTransfrom:(CPRAffineTransform3D)pixToDICOMTransfrom
{
	switch ([roi type]) {
		case tMesure:
		case tOPolygon:
			return [[[OSIPathROI alloc] initWithOsiriXROI:roi pixToDICOMTransfrom:pixToDICOMTransfrom] autorelease];
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