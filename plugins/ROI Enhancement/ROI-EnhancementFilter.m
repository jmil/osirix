//
//  ROIEnhancementFilter.m
//  ROIEnhancementFilter
//
//  Created by rossetantoine on Wed Jun 09 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "ROI-EnhancementFilter.h"

@implementation ROIEnhancementFilter

- (long) filterImage:(NSString*) menuName
{
	NSMutableArray  *pixList;
	NSMutableArray  *roiSeriesList;
	NSMutableArray  *roiImageList;
	DCMPix			*curPix;
	NSString		*roiName = 0L;
	long			i, x;
	
	// In this plugin, we will take the selected roi of the current 2D viewer
	// and search all rois with same name in other images of the series
	
	pixList = [viewerController pixList];
	
	curPix = [pixList objectAtIndex: [[viewerController imageView] curImage]];
	
	// All rois contained in the current series
	roiSeriesList = [viewerController roiList];
	
	// All rois contained in the current image
	roiImageList = [roiSeriesList objectAtIndex: [[viewerController imageView] curImage]];
	
	// Find the first selected ROI of current image
	for( i = 0; i < [roiImageList count]; i++)
	{
		if( [[roiImageList objectAtIndex: i] ROImode] == ROI_selected)
		{
			// We find it! What's his name?
			
			roiName = [[roiImageList objectAtIndex: i] name];
			
			i = [roiImageList count];   //Break the loop
		}
	}
	
	if( roiName == 0L)
	{
		NSRunInformationalAlertPanel(@"ROI Enhancement", @"You need to select a ROI!", @"OK", 0L, 0L);
		return 0;
	}
	
	float *rmean, *rmin, *rmax;
	
	rmean = (float*) malloc( sizeof(float) * [pixList count]);
	rmin = (float*) malloc( sizeof(float) * [pixList count]);
	rmax = (float*) malloc( sizeof(float) * [pixList count]);
	
	// Now find all ROIs with the same name on other images of the series
	for( x = 0; x < [pixList count]; x++)
	{
		roiImageList = [roiSeriesList objectAtIndex: x];
		
		rmin[ x] = 0;
		rmax[ x] = 0;
		rmean[ x] = 0;
		
		for( i = 0; i < [roiImageList count]; i++)
		{
			if( [[[roiImageList objectAtIndex: i] name] isEqualToString: roiName])
			{
				// Compute the min, max, mean values
				curPix = [pixList objectAtIndex: x];
				
				[curPix computeROI: [roiImageList objectAtIndex: i] :&rmean[ x] :0L :0L : &rmin[ x] :&rmax[ x]];
			}
		}
	}
	
	//Now create our results window
	ResultsController* resultsWin = [[ResultsController alloc] initWithName: roiName];
	[[resultsWin resultsView] setArrays: [pixList count] :rmean :rmin :rmax];
	[resultsWin showWindow:self];
	return 0;
}

@end
