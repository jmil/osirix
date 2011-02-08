//
//  OSILineROI.m
//  OsiriX
//
//  Created by Joël Spaltenstein on 1/27/11.
//  Copyright 2011 OsiriX Team. All rights reserved.
//

#import "OSIPlanarPathROI.h"
#import "CPRBezierPath.h"
#import "ROI.h"
#import "CPRGeometry.h"
#import "MyPoint.h"
#import "DCMView.h"
#import "OSIFloatVolumeData.h"
#import "OSIROIMask.h"
#import "OSIROI.h"

@implementation OSIPlanarPathROI (Private)

- (id)initWithOsiriXROI:(ROI *)roi pixToDICOMTransfrom:(CPRAffineTransform3D)pixToDICOMTransfrom homeFloatVolumeData:(OSIFloatVolumeData *)floatVolumeData
{
	NSPoint point;
	NSArray *pointArray;
	MyPoint *myPoint;
	NSMutableArray *nodes;
	
	if ( (self = [super init]) ) {
		_osiriXROI = [roi retain];
		
		_plane = CPRPlaneApplyTransform(CPRPlaneMake(CPRVectorZero, CPRVectorMake(0, 0, 1)), pixToDICOMTransfrom);
		_homeFloatVolumeData = [floatVolumeData retain];
		
		if ([roi type] == tMesure && [[roi points] count] > 1) {
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
			if ([_bezierPath elementCount]) {
				[_bezierPath close];
			}
			[nodes release];
		} else {
			[self release];
			self = nil;
		}
	}
	return self;
}

@end


@implementation OSIPlanarPathROI


- (void)dealloc
{
	[_bezierPath release];
	_bezierPath = nil;
	
	[_osiriXROI release];
	_osiriXROI = nil;
	
	[_homeFloatVolumeData release];
	_homeFloatVolumeData = nil;
	
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

- (OSIROIMask *)ROIMaskForFloatVolumeData:(OSIFloatVolumeData *)floatVolume
{
	CPRMutableBezierPath *volumeBezierPath;
	CPRBezierPathElement segmentType;
	CPRVector endpoint;
	NSArray	*intersections;
	NSMutableArray *intersectionNumbers;
	NSMutableArray *ROIRuns;
	OSIROIMaskRun maskRun;
	CGFloat minY;
	CGFloat maxY;
	CGFloat z;
	BOOL zSet;
	NSValue *vectorValue;
	NSNumber *number;
	NSUInteger i;
	NSUInteger j;
	NSUInteger runStart;
	NSUInteger runEnd;
	
	volumeBezierPath = [[_bezierPath bezierPathByApplyingTransform:floatVolume.volumeTransform] mutableCopy];
	[volumeBezierPath flatten:CPRBezierDefaultFlatness];
	zSet = NO;
	ROIRuns = [NSMutableArray array];
	minY = CGFLOAT_MAX;
	maxY = -CGFLOAT_MAX;
	
	for (i = 0; i < [volumeBezierPath elementCount]; i++) {
		segmentType = [volumeBezierPath elementAtIndex:i control1:NULL control2:NULL endpoint:&endpoint];
#if CGFLOAT_IS_DOUBLE
		endpoint.z = round(endpoint.z);
#else
		endpoint.z = roundf(endpoint.z);		
#endif		
		[volumeBezierPath setVectorsForElementAtIndex:i control1:CPRVectorZero control2:CPRVectorZero endpoint:endpoint];
		minY = MIN(minY, endpoint.y);
		maxY = MAX(maxY, endpoint.y);
		
		if (zSet == NO) {
			z = endpoint.z;
			zSet = YES;
		}
		
		assert (endpoint.z == z);		
	}
	
	minY = floor(minY);
	maxY = ceil(maxY);
	maskRun.depthIndex = z;
	
	for (i = minY; i <= maxY; i++) {
		maskRun.heightIndex = i;
		intersections = [volumeBezierPath intersectionsWithPlane:CPRPlaneMake(CPRVectorMake(0, i, 0), CPRVectorMake(0, 1, 0))];
		
		intersectionNumbers = [NSMutableArray array];
		for (vectorValue in intersections) {
			[intersectionNumbers addObject:[NSNumber numberWithDouble:[vectorValue CPRVectorValue].x]];
		}
		[intersectionNumbers sortUsingSelector:@selector(compare:)];
		for(j = 0; j+1 < [intersectionNumbers count]; j++) {
			runStart = round([[intersectionNumbers objectAtIndex:j] doubleValue]);
			runEnd = round([[intersectionNumbers objectAtIndex:j+1] doubleValue]);
			if (runEnd > runStart) {
				maskRun.widthRange = NSMakeRange(runStart, runEnd - runStart);
                [ROIRuns addObject:[NSValue valueWithOSIROIMaskRun:maskRun]];
			}
			j++;
		}
	}
	
	if ([ROIRuns count] > 0) {
		return [[[OSIROIMask alloc] initWithMaskRuns:ROIRuns] autorelease];
	} else {
		return nil;
	}
}

- (NSArray *)osiriXROIs
{
	return [NSArray arrayWithObject:_osiriXROI];
}

- (OSIFloatVolumeData *)homeFloatVolumeData // the volume data on which the ROI was drawn
{
	return _homeFloatVolumeData;
}

@end




















