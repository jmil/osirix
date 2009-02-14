//
//  ROIEnhancementFilter.m
//  ROIEnhancementFilter
//
//  Created by rossetantoine on Wed Jun 09 2004.
//  Copyright (c) 2004 OsiriX. All rights reserved.
//

#import "ROI-EnhancementFilter.h"

@implementation ROIEnhancementFilter

+ (void) initialize
{
	NSString *frameworkPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/Frameworks/GraphX.framework"];
	NSBundle *framework = [NSBundle bundleWithPath:frameworkPath];
	NSError *error = nil;
	
	if([framework loadAndReturnError: &error])
	{
	
	}
	else
	{
		NSLog( frameworkPath);
		NSLog( @"%@", [framework executablePath]);
		NSLog( @"%@", [framework infoDictionary]);
		NSLog( @"%@", [framework executableArchitectures]);
		NSLog(@"Error, framework failed to load\nAborting: %@", error);
	}
}

- (long) filterImage:(NSString*) menuName
{

	NSString *frameworkPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/Frameworks/GraphX.framework"];
        
	NSBundle *framework = [NSBundle bundleWithPath:frameworkPath];
  
    NSError *error = nil;
	
	NSLog( [framework executablePath]);
	
	if([framework loadAndReturnError: &error])
		NSLog(@"Framework loaded");
	else
	{
		NSLog( frameworkPath);
		NSLog( @"Error, framework failed to load: %@", error);
	}
	
	NSMutableArray  *pixList;
	NSMutableArray  *roiSeriesList;
	NSMutableArray  *roiImageList;
	DCMPix			*curPix;
	NSString		*roiName = 0L;
	int				i, x, z;
	ROI				*roi = nil;
	
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
			
			roi = [roiImageList objectAtIndex: i];
			roiName = [[roiImageList objectAtIndex: i] name];
			
			break;
		}
	}
	
	if( roiName == 0L)
	{
		if( [roiImageList count] == 1)	// Take the only available ROI...
		{
			roi = [roiImageList lastObject];
			roiName = [[roiImageList lastObject] name];
		}
		
		if( roiName == 0L)
		{
			NSRunInformationalAlertPanel(@"ROI Enhancement", @"You need to select a ROI!", @"OK", 0L, 0L);
			return 0;
		}
	}
	
	//Now create our results window
	ResultsController* resultsWin = [[ResultsController alloc] initWithROI: roi viewer: viewerController];
	[resultsWin showWindow:self];

	return 0;
}

@end
