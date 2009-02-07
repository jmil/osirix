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
	NSString *frameworkPath=[[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"Contents/Frameworks/GraphX.framework"];
        
	NSBundle *framework=[NSBundle bundleWithPath:frameworkPath];
  
	if([framework load])
		NSLog(@"Framework loaded");
	else
	{
		NSLog(@"Error, framework failed to load\nAborting.");
			exit(1);
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
	[view setArrays: 0 :nil :nil :nil];
	
	if( rmean) free( rmean);
	if( rmin) free( rmin);
	if( rmax) free( rmax);
	
	[curROI release];
	
	[super dealloc];
}
@end
