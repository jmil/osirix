//
//  ResultsController.m
//  ResultsController
//
//  Created by rossetantoine on Tue Jun 15 2004.
//  Copyright (c) 2004 Antoine Rosset. All rights reserved.
//

#import "ResultsController.h"
#import "DCMPix.h"

@implementation ResultsController

+ (void) initialize
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
}

- (void)getPoint:(NSPointPointer *)point atIndex:(unsigned)index
{		
	if( index < 0)
	{
		*point = nil;
		return;
	}
	
	if( index >= num)
	{
		*point = nil;
		return;
	}
	
	*(*point) = NSMakePoint(index, rmean[ index]);
}

- (void)awakeFromNib
{

}

- (id) initWithROI:(ROI*) roi viewer:(ViewerController*) v
{
	self = [super initWithWindowNibName:@"ResultsROI"];
	
	[[self window] setDelegate:self];   //In order to receive the windowWillClose notification!
	
	[roiName setStringValue: [roi name]];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(roiChange:) name: @"roiChange" object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(removeROI:) name: @"removeROI" object: nil];
	
	curROI = [roi retain];
	viewerController = v;
	
	[self updateData];
	
	plotMean.showTitle = NO;
	plotMean.showXLabel = NO;
	plotMean.showYLabel = NO;
	
	plotMin.showTitle = NO;
	plotMin.showXLabel = NO;
	plotMin.showYLabel = NO;
	
	plotMin.showXGrid = NO;
	plotMin.showXTickMarks = NO;
	plotMin.showYGrid = NO;
	plotMin.showYTickMarks = NO;
	plotMin.showBackground = NO;
	plotMin.showCurve = YES;
	plotMin.showFill = NO;
	
	plotMax.showTitle = NO;
	plotMax.showXLabel = NO;
	plotMax.showYLabel = NO;
	
	plotMax.showXGrid = NO;
	plotMax.showXTickMarks = NO;
	plotMax.showYGrid = NO;
	plotMax.showYTickMarks = NO;
	plotMax.showBackground = NO;
	plotMax.showCurve = YES;
	plotMax.showFill = NO;
	
	return self;
}

- (void) updateData
{
	int x, mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"ROIEnhancementMode"];

	NSMutableArray  *pixList;
	NSMutableArray  *roiSeriesList;
	NSMutableArray  *roiImageList;
	DCMPix			*curPix;
	
	pixList = [viewerController pixList];
	
	curPix = [pixList objectAtIndex: [[viewerController imageView] curImage]];
	
	// All rois contained in the current series
	roiSeriesList = [viewerController roiList];
	
	// All rois contained in the current image
	roiImageList = [roiSeriesList objectAtIndex: [[viewerController imageView] curImage]];

	if( rmean) free( rmean);
	if( rmin) free( rmin);
	if( rmax) free( rmax);
	
	rmax = rmin = rmean = nil;
	
	if( mode == 0)	// Apply same ROI to the entire stack
	{	
		rmean = (float*) malloc( sizeof(float) * [pixList count]);
		rmin = (float*) malloc( sizeof(float) * [pixList count]);
		rmax = (float*) malloc( sizeof(float) * [pixList count]);
		
		for( x = 0; x < [pixList count]; x++)
		{
			rmin[ x] = 0;
			rmax[ x] = 0;
			rmean[ x] = 0;
			
			// Compute the min, max, mean values
			curPix = [pixList objectAtIndex: x];
			
			[curPix computeROI: curROI :&rmean[ x] :0L :0L : &rmin[ x] :&rmax[ x]];
		}
		
		num = [pixList count];
		
//		[view setArrays: [pixList count] :rmean :rmin :rmax];
	}

	if( mode == 3)	// Apply same ROI to the entire stack
	{	
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
			
			for( int i = 0; i < [roiImageList count]; i++)
			{
				if( [[[roiImageList objectAtIndex: i] name] isEqualToString: [curROI name]])
				{
					// Compute the min, max, mean values
					curPix = [pixList objectAtIndex: x];
					
					[curPix computeROI: [roiImageList objectAtIndex: i] :&rmean[ x] :0L :0L : &rmin[ x] :&rmax[ x]];
				}
			}
		}
		
	}
	
	[plotMinData setValue: rmin number: num];
	[plotMaxData setValue: rmax number: num];
	[plotMeanData setValue: rmean number: num];
	
	[plotMean setNeedsDisplay: YES];
	[plotMin setNeedsDisplay: YES];
	[plotMax setNeedsDisplay: YES];
	
	plotMean.xMin = 0;
	plotMean.xMax = num-1;

	for( int x = 0 ; x < num; x++)
	{
		if( rmin[x] < plotMean.yMin)
			plotMean.yMin = rmin[ x];
			
		if( rmax[x] > plotMean.yMax)
			plotMean.yMax = rmax[ x];
	}
	
	plotMin.xMin = plotMax.xMin = plotMean.xMin;
	plotMin.xMax = plotMax.xMax = plotMean.xMax;
	plotMin.xScale = plotMax.xScale = plotMean.xScale;
	
	plotMin.yMin = plotMax.yMin = plotMean.yMin;
	plotMin.yMax = plotMax.yMax = plotMean.yMax;
	plotMin.yScale = plotMax.yScale = plotMean.yScale;
}

-(void) removeROI:(NSNotification*)note
{
	if( [note object] == curROI)
	{
		[self close];
	}
}

- (void) roiChange:(NSNotification*) note
{
	if( [note object] == curROI)
	{
		[self updateData];
	}
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self release];
}

- (void) dealloc
{	
	if( rmean) free( rmean);
	if( rmin) free( rmin);
	if( rmax) free( rmax);
	
	[curROI release];
	
	[super dealloc];
}
@end
