//
//  Controller.m
//  Mapping
//
//  Created by Antoine Rosset on Mon Aug 02 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#include "math.h"

#import "PluginFilter.h"
#import "Mapping.h"

#import "Controller.h"


@implementation ControllerT2Fit

-(IBAction) endFill:(id) sender
{
    [fillWindow orderOut:sender];
    
    [NSApp endSheet:fillWindow returnCode:[sender tag]];
    
    if( [sender tag])   //User clicks OK Button
    {
		NSMutableArray		*pixList;
		long				i;
		
		pixList = [[filter viewerController] pixList];
		
		if( [[fillMode selectedCell] tag] == 1)		// Interval
		{
			for( i = 0; i < [pixList count]; i++)
			{
				TEValues[ i] = ([startFill floatValue]+ i*[intervalFill floatValue]) / 1000.;
			}
		}
		else //Start - End
		{
			for( i = 0; i < [pixList count]; i++)
			{
				TEValues[ i] = ([startFill floatValue] + (i*([endFill floatValue] - [startFill floatValue]))/((float) ([pixList count]-1))) / 1000.;
			}
		}
		
		[TETable reloadData];
		
		[self refreshGraph: self];
    }
}

- (IBAction) startFill:(id) sender
{
    [NSApp beginSheet: fillWindow modalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[[filter viewerController] pixList] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if( [[aTableColumn identifier] isEqualToString:@"index"]) return [NSString stringWithFormat:@"%d", rowIndex+1];
	else return [NSString stringWithFormat:@"%2.2f", TEValues[ rowIndex] * 1000.];
}

- (void)tableView:(NSTableView *)aTableView
    setObjectValue:anObject
    forTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
	TEValues[ rowIndex] = [anObject floatValue] / 1000.f;
	
	[self refreshGraph:self];
}

-(void) computeLinearRegression:(long) n :(float*) xValues :(float*) yValues :(float*) b :(float*) m
{
	long	i;
	float	sumx, sumx2, sumxy, sumy, sumy2;
	float   r;                                 /* correlation coefficient       */
	float	nf;
	
	sumx = sumx2 = sumxy = sumy = sumy2 = 0;
	
	for( i = 0; i < n; i++)
	{
		sumx += xValues[ i];
		sumx2 += xValues[ i]*xValues[ i];
		sumxy += xValues[ i]*yValues[ i];
		sumy += yValues[ i];
		sumy2 += yValues[ i]*yValues[ i];
	}
	
/*---------------------------------------------------------------------------*/
/*  Compute least-squares best fit straight line.                            */
/*---------------------------------------------------------------------------*/

	nf = n;

   *m = (nf * sumxy  -  sumx * sumy) /        /* compute slope                 */
       (nf * sumx2 - sumx*sumx);

   *b = (sumy * sumx2  -  sumx * sumxy) /    /* compute y-intercept           */
       (nf * sumx2  -  sumx*sumx);

   r = (sumxy - sumx * sumy / nf) /          /* compute correlation coeff     */
            sqrt((sumx2 - (sumx*sumx)/nf) *
            (sumy2 - (sumy*sumy)/nf));
}

- (IBAction) refreshGraph:(id) sender
{
	long				i;
	NSMutableArray		*pixList;
	float				*rmean, *rmin, *rmax, background;
	DCMPix				*curPix;
	
	background = [backgroundSignal floatValue];
//	NSLog(@"%2.2f", background);
	
	pixList = [[filter viewerController] pixList];

	if( curROI == 0L)
	{
		[resultView setArrays: [pixList count] :0L :0L :0L :TEValues :[logScale state]];
		return;
	}

	rmean = (float*) malloc( sizeof(float) * [pixList count]);
	rmin = (float*) malloc( sizeof(float) * [pixList count]);
	rmax = (float*) malloc( sizeof(float) * [pixList count]);
	
	// Find the first selected ROI of current image
	for( i = 0; i < [pixList count]; i++)
	{
		// Compute the min, max, mean values
		curPix = [pixList objectAtIndex: i];
		
		[curPix computeROI: curROI :&rmean[ i] :0L :0L : &rmin[ i] :&rmax[ i]];
		
		rmean[i] -= background;
		rmin[i] -= background;
		rmax[i] -= background;
	}
	
	[resultView setArrays: [pixList count] :rmean :rmin :rmax :TEValues :[logScale state]];
	
	// Compute slope and intercept
	{
		float	*rmeanLog;
		
		rmeanLog = (float*) malloc( sizeof(float) * [pixList count]);
		
		for( i = 0; i < [pixList count]; i++)
		{
			if( rmean[i] < 1.0) rmean[i] = 1.0;
			if( rmin[i] < 1.0) rmin[i] = 1.0;
			if( rmax[i] < 1.0) rmax[i] = 1.0;
			
			rmeanLog[ i] = log( rmean[i]);
		}
		
		[self computeLinearRegression: [pixList count] :TEValues :rmeanLog :&intercept :&slope];
		
		free( rmeanLog);
		
		[resultView setLinearRegression:intercept : slope];
	}
	
	[meanT2Value setStringValue: [NSString stringWithFormat:@"Mean T2: %2.2f ms, M0: %2.2f", 1000.0 / (-slope), exp( intercept)]];
}



-(IBAction) compute:(id) sender
{
	// Contains a list of DCMPix objects: they contain the pixels of current series
	NSArray				*pixListA;
	NSArray				*pixListC;
	DCMPix				*firstPix;
	long				i, x, y;
	unsigned char		*emptyData;
	float				*dstImage, kValue;
	float				factor, threshold, thresholdSet, minValue, background;
	
	BOOL				meanMode;
	
	pixListA = [[filter viewerController] pixList];
	
	[self refreshGraph: self];
	
	firstPix = [pixListA objectAtIndex: 0];
	
	if( new2DViewer == 0L)
	{
		long size = sizeof(float) * [firstPix pwidth] * [firstPix pheight];
		
		emptyData = malloc( size);
		memset( emptyData, 0, size);
		
		NSData	*newData = [NSData dataWithBytes:emptyData length: size];
		
		// CREATE A SERIE WITH ONE IMAGE
		new2DViewer = [[filter viewerController] newWindow		:[NSMutableArray arrayWithObject: [[pixListA objectAtIndex:0] copy]]
																:[NSMutableArray arrayWithObject: [[[filter viewerController] fileList] objectAtIndex:0]]
																:newData];
		free( emptyData);
		
		pixListC = [new2DViewer pixList];
		[[pixListC objectAtIndex: 0] setfImage: (float*)[newData bytes]];
	}
	else pixListC = [new2DViewer pixList];
	
	factor = [factorText floatValue];
	background = [backgroundSignal floatValue];
	thresholdSet = 0;
	minValue = 99999;
	
	NSLog(@"Threshold:%0.0f", threshold);
	
	meanMode = [[mode selectedCell] tag];
	
	if( meanMode)
	{
		NSLog(@"mean mode");
	}
	else
	{
		NSLog(@"pixels mode");
	}
	
	dstImage = [[pixListC objectAtIndex: 0] fImage];
	
	// Loop through all images contained in the current series
	for( x = 0; x < [firstPix pwidth]; x++)
	{
		for( y = 0; y < [firstPix pheight]; y++)
		{
			if( [firstPix isInROI: curROI :NSMakePoint(x, y)])
			{
				if( meanMode)
				{
				//	minValue = slope * factor;
					dstImage[ x + y*[firstPix pwidth]] = factor /-slope;
				}
				else
				{
					float values[ 1000];
					long pos = x + y*[firstPix pwidth];
					
					for( i = 0; i < [pixListA count]; i++)
					{
						values[ i] = log( [[pixListA objectAtIndex: i] fImage] [ pos] - background);
					}
					
					[self computeLinearRegression: [pixListA count] :TEValues :values :&intercept :&slope];
					
					dstImage[ x + y*[firstPix pwidth]] = factor / -slope;
				//	if( slope*factor < minValue) minValue = -slope * factor;
				}
			}
		}
	}
	
//	[[pixListC objectAtIndex: 0] fillROI: curROI :0 :-999999 :99999 :YES];
	
	// We modified the pixels: OsiriX please update the display!
	[new2DViewer needsDisplayUpdate];
	[[new2DViewer imageView] setWLWW:0 :0];
}

- (void)awakeFromNib
{
	NSLog( @"Nib loaded!");
	
	NSNotificationCenter *nc;
    nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector: @selector(closeViewer:)
               name: @"CloseViewerNotification"
             object: nil];
	
	[nc addObserver: self
           selector: @selector(roiChange:)
               name: @"roiChange"
             object: nil];
	
	[nc addObserver: self
           selector: @selector(roiChange:)
               name: @"removeROI"
             object: nil];
	
	[nc addObserver: self
           selector: @selector(roiChange:)
               name: @"roiSelected"
             object: nil];

			 
}

- (id) init:(MappingT2FitFilter*) f 
{
	long i;
	
	self = [super initWithWindowNibName:@"ControllerT2Fit"];
		
	[[self window] setDelegate:self];   //In order to receive the windowWillClose notification!
	
	new2DViewer = 0L;
	curROI = 0L;
	filter = f;
	blendedWindow = [[filter viewerController] blendedWindow];
	
	// Try to find the TEs...
	
	for( i = 0; i < [[[filter viewerController] pixList] count]; i++)
	{
		TEValues[ i] = [[[[[filter viewerController] pixList] objectAtIndex: i] echotime] floatValue] / 1000.;
	}
	
	[TETable reloadData];
	
	NSMutableArray		*roiSeriesList, *roiImageList;
	// TRY TO FIND THE SELECTED ROI OF CURRENT IMAGE
	// All rois contained in the current series
	roiSeriesList = [[filter viewerController] roiList];
	
	// All rois contained in the current image
	roiImageList = [roiSeriesList objectAtIndex: [[[filter viewerController] imageView] curImage]];
	
	// Find the first selected ROI of current image
	for( i = 0; i < [roiImageList count]; i++)
	{
		if( [[roiImageList objectAtIndex: i] ROImode] == ROI_selected || [[roiImageList objectAtIndex: i] ROImode] == ROI_selectedModify)
		{
			// We find it! What's his name?
			
			curROI = [roiImageList objectAtIndex: i];
			i = [roiImageList count];   //Break the loop
		}
	}
		
	[self refreshGraph: self];
	
	return self;
}

- (void) roiChange :(NSNotification*) note
{
	if( [[note name] isEqualToString:@"removeROI"])
	{
		curROI = 0L;
	}
	else
	{
		if( [[note object] ROImode] == ROI_selected || [[note object] ROImode] == ROI_selectedModify)
		{
			curROI = [note object];
		}
	}
	
	[self refreshGraph:self];
}

- (void) closeViewer :(NSNotification*) note
{
	if( [note object] == [filter viewerController])
	{
		NSLog(@"Viewer Window will close.... We have to close!");
		
		[self release];
	}
	
	if( [note object] == new2DViewer)
	{
		new2DViewer = 0L;
	}
}

- (void)windowWillClose:(NSNotification *)notification
{
	NSLog(@"Window will close.... and release his memory...");
	
	[self release];
}

- (void) dealloc
{
    NSLog(@"My window is deallocating a pointer");
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	[super dealloc];
}

@end
