//
//  FusionFilter.m
//  Fusion
//
//  Created by rossetantoine on Wed Jun 09 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "FusionFilter.h"

@implementation FusionFilter

- (long) filterImage:(NSString*) menuName
{
	long			i, x, y;
	float			*fImageA, *fImageB;

	// In this filter, we will apply a subtraction optimized for Angio CT
	// We are interested to produce an image that contains ONLY the contrast agent
	// WITHOUT bones, calcification and fat
	// IMAGE A: WITH CONTRAST
	// IMAGE B: WITHOUT CONTRAST (DRAGGED IMAGE, TO BE SUBTRACTED)
	
	NSArray		*pixListA = [viewerController pixList];	
	NSArray		*pixListB = [[viewerController blendedWindow] pixList];	
	
	// This filter works ONLY for BW images
	if( [[pixListA lastObject] isRGB] || [[pixListB lastObject] isRGB])
	{
		NSRunAlertPanel(@"Plugin Error", @"This plugin works only with B&W series", nil, nil, nil);
		return 0;
	}
	
	// This filter works ONLY for images of same size
	if( [[pixListA lastObject] pwidth] != [[pixListB lastObject] pwidth] ||
		[[pixListA lastObject] pheight] != [[pixListB lastObject] pheight])
	{
		NSRunAlertPanel(@"Plugin Error", @"This plugin works only for images of same size", nil, nil, nil);
		return 0;
	}
	
	// This filter works ONLY for series with same number of images
	if( [pixListA count] != [pixListB count])
	{
		NSRunAlertPanel(@"Plugin Error", @"This plugin works only for series with same number of images", nil, nil, nil);
		return 0;
	}
	
	// We are ready to START! Display a waiting window
	id waitWindow = [viewerController startWaitWindow:@"Angio-CT Subtraction"];
	
	DCMPix		*curPixA, *curPixB;
	float		pixelA, pixelB;
	BOOL		result;
	
	// Loop through all images contained in the current series
	for( i = 0; i < [pixListA count]; i++)
	{
		curPixA = [pixListA objectAtIndex: i];
		curPixB = [pixListB objectAtIndex: i];
		
		// fImage is a pointer on the pixels, ALWAYS represented in float (float*) for BW images
		fImageA = [curPixA fImage];
		fImageB = [curPixB fImage];
		
		for( y = 0; y < [curPixA pheight]; y++)
		{
			for( x = 0; x < [curPixA pwidth]; x++)
			{
				pixelA = fImageA[ [curPixA pwidth] * y + x];
				pixelB = fImageB[ [curPixB pwidth] * y + x];
				
				result = YES;
				if( pixelA < 10) result = NO;
				if( pixelA > 500) result = NO;
				if( pixelB < 0) result = NO;
				if( pixelB > 100) result = NO;
				
				pixelA -= pixelB;
				
				if( pixelA < 0) result = NO;
				if( pixelA > 500) result = NO;
				
				if( result != 0) fImageA[ [curPixA pwidth] * y + x] = pixelA;
				else fImageA[ [curPixA pwidth] * y + x] = -1000;	//AIR
			}
		}
	}
	
	// Close the waiting window
	[viewerController endWaitWindow: waitWindow];
			
	// We modified the pixels: OsiriX please update the display!
	[viewerController needsDisplayUpdate];
	
	return 0;
}

@end
