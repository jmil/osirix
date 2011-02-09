//
//  OSILineROI.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/27/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSIROI.h"
#import "N3Geometry.h"

@class ROI;
@class N3MutableBezierPath;
@class OSIFloatVolumeData;

// for now implement closed poly first

@interface OSIPlanarPathROI : OSIROI {
	ROI *_osiriXROI;
	
	N3MutableBezierPath *_bezierPath;
	OSIFloatVolumeData *_homeFloatVolumeData;
	N3Plane _plane;
}


@end
