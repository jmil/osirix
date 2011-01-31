//
//  OSILineROI.m
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/27/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import "OSIPathROI.h"
#import "CPRBezierPath.h"
#import "ROI.h"
#import "CPRGeometry.h"
#import "MyPoint.h"
#import "DCMView.h"

@implementation OSIPathROI

- (id)initWithOsiriXROI:(ROI *)roi pixToDICOMTransfrom:(CPRAffineTransform3D)pixToDICOMTransfrom
{
	NSPoint point;
	NSArray *pointArray;
	MyPoint *myPoint;
	NSMutableArray *nodes;
	
	if ( (self = [super init]) ) {
		_osiriXROI = [roi retain];
		
		if ([roi type] == tMesure) {
			_bezierPath = [[CPRMutableBezierPath alloc] init];
			point = [roi pointAtIndex:0];
			[_bezierPath moveToVector:CPRVectorApplyTransform(CPRVectorMakeFromNSPoint(point), pixToDICOMTransfrom)];
			point = [roi pointAtIndex:1];
			[_bezierPath lineToVector:CPRVectorApplyTransform(CPRVectorMakeFromNSPoint(point), pixToDICOMTransfrom)];
		} else if ([roi type] == tOPolygon) {
			pointArray = [roi points];
			
			nodes = [[NSMutableArray alloc] init];
			for (myPoint in pointArray) {
				[nodes addObject:[NSValue valueWithCPRVector:CPRVectorApplyTransform(CPRVectorMakeFromNSPoint([myPoint point]), pixToDICOMTransfrom)]];
			}
			_bezierPath = [[CPRMutableBezierPath alloc] initWithNodeArray:nodes];
			[nodes release];
		} else if ([roi type] == tCPolygon) {
			pointArray = [roi points];
			
			nodes = [[NSMutableArray alloc] init];
			for (myPoint in pointArray) {
				[nodes addObject:[NSValue valueWithCPRVector:CPRVectorApplyTransform(CPRVectorMakeFromNSPoint([myPoint point]), pixToDICOMTransfrom)]];
			}
			_bezierPath = [[CPRMutableBezierPath alloc] initWithNodeArray:nodes];
			[_bezierPath close];
			[nodes release];
		} else {
			[self release];
			self = nil;
		}
	}
	return self;
}

- (void)dealloc
{
	[_bezierPath release];
	_bezierPath = nil;
	
	[_osiriXROI release];
	_osiriXROI = nil;
	
	[super dealloc];
}

- (NSString *)name
{
	return [_osiriXROI name];
}

- (NSArray *)convexHull
{
	NSMutableArray *convexHull;
	NSUInteger i;
	CPRVector control1;
	CPRVector control2;
	CPRVector endpoint;
	CPRBezierPathElement elementType;
	
	convexHull = [NSMutableArray array];
	
	for (i = 0; i < [_bezierPath elementCount]; i++) {
		elementType = [_bezierPath elementAtIndex:i control1:&control1 control2:&control2 endpoint:&endpoint];
		switch (elementType) {
			case CPRMoveToBezierPathElement:
			case CPRLineToBezierPathElement:
				[convexHull addObject:[NSValue valueWithCPRVector:endpoint]];
				break;
			case CPRCurveToBezierPathElement:
				[convexHull addObject:[NSValue valueWithCPRVector:control1]];
				[convexHull addObject:[NSValue valueWithCPRVector:control2]];
				[convexHull addObject:[NSValue valueWithCPRVector:endpoint]];
				break;
			default:
				break;
		}
	}
	
	return convexHull;
}

@end






















