//
//  OSILineROI.h
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/27/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSIROI.h"
#import "CPRGeometry.h"

@class ROI;
@class CPRMutableBezierPath;

// for now implement closed poly first

@interface OSIPlanarPathROI : OSIROI {
	ROI *_osiriXROI;
	
	CPRMutableBezierPath *_bezierPath;
	CPRPlane _plane;
}

- (id)initWithOsiriXROI:(ROI *)roi pixToDICOMTransfrom:(CPRAffineTransform3D)pixToDICOMTransfrom;

@end
