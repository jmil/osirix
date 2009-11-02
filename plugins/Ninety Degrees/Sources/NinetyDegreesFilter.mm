//
//  90degFilter.m
//  90deg
//
//  Copyright (c) 2009 OsiriX. All rights reserved.
//

#import "NinetyDegreesFilter.h"
#import "NinetyDegreesROI.h"
#import <OsiriX Headers/Notifications.h>
#import <OsiriX Headers/ROI.h>
#import <Nitrogen/N2Operators.h>

@implementation NinetyDegreesFilter

-(void)initPlugin {
	_ndrois = [[NSMutableArray alloc] initWithCapacity:4];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roiChanged:) name:OsirixROIChangeNotification object:NULL];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roiRemoved:) name:OsirixRemoveROINotification object:NULL];
}

-(void)dealloc {
	[_ndrois release]; _ndrois = NULL;
	[super dealloc];
}

-(long)filterImage:(NSString*)menuName {
	// NSLog(@"ROIS: %@", );
	
	NSUInteger selectedRoisCount = 0;
	ROI* selectedROI = NULL;
	for (ROI* roi in [[viewerController imageView] curRoiList])
		if ([roi ROImode] == ROI_selected) {
			++selectedRoisCount;
			selectedROI = roi;
		}
	
	if (selectedRoisCount != 1)
		return -1;
	
	if ([selectedROI type] != tMesure && [[selectedROI points] count] == 2)
		return -1;
	
	NSPoint p1 = [[[selectedROI points] objectAtIndex:0] point];
	NSPoint p2 = [[[selectedROI points] objectAtIndex:1] point];
	NSPoint d = p2-p1, m = (p1+p2)/2, d2 = d/2;
	
	ROI* line = [[ROI alloc] initWithType:tMesure :[selectedROI pixelSpacingX] :[selectedROI pixelSpacingY] :NSZeroPoint];
	[[line points] addObject:[MyPoint point:NSMakePoint(m.x+d2.y, m.y-d2.x)]];
	[[line points] addObject:[MyPoint point:NSMakePoint(m.x-d2.y, m.y+d2.x)]];
	[[[viewerController imageView] curRoiList] addObject:line];
	[line release];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:OsirixROIChangeNotification object:line];
	
//	if ([[roi points] count] == 2)

	return 0;
}

/*-(void)checkPerpendicular:(ROI*)roi1 with:(ROI*)roi2 {
	ROI* ndroi = NULL;
	for (NinetyDegreesROI* ndroit in _ndrois)
		if ([ndroit isOnROI:roi1] && [ndroit isOnROI:roi2])
			ndroi = ndroit;
	
	CGFloat angle = fabs(NSAngle([[[roi1 points] objectAtIndex:0] point], [[[roi1 points] objectAtIndex:1] point])-NSAngle([[[roi2 points] objectAtIndex:0] point], [[[roi2 points] objectAtIndex:1] point]));
	angle -= pi/2;
	BOOL perp = fabs(angle) < 0.001;
	
	if (ndroi && !perp)
		[[NSNotificationCenter defaultCenter] postNotificationName:OsirixRemoveROINotification object:ndroi];
	if (!ndroi && perp) {
		ndroi = [[NinetyDegreesROI alloc] initWithRoi1:roi1 roi2:roi2];
		[_ndrois addObject:ndroi];
		[[[viewerController imageView] curRoiList] addObject:ndroi];
		[ndroi release];
	}
}

-(void)roiChanged:(NSNotification*)notification {
	ROI* roi = [notification object];
	
	if ([roi type] == tMesure && [[roi points] count] == 2)
		for (ROI* other in [[roi curView] curRoiList])
			if (other != roi && [other type] == tMesure && [[other points] count] == 2)
				[self checkPerpendicular:roi with:other];
}

-(void)roiRemoved:(NSNotification*)notification {
	ROI* roi = [notification object];
	
	if ([roi isKindOfClass:[NinetyDegreesROI class]])
		[_ndrois removeObject:roi];
	else
		for (NinetyDegreesROI* ndroi in _ndrois)
			if ([ndroi isOnROI:roi])
				[[NSNotificationCenter defaultCenter] postNotificationName:OsirixRemoveROINotification object:ndroi];
}*/

@end
