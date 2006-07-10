//
//  ResampleDataFilter.m
//  Resample Data
//
//  Created by rossetantoine on Wed Jun 09 2004.
//  Copyright (c) 2004 Rosset Antoine. All rights reserved.
//

#import "ResampleDataFilter.h"
#include <Accelerate/Accelerate.h>

@implementation ResampleDataFilter

- (IBAction) setXYZValue:(id) sender
{
	DCMPix	*curPix = [[viewerController pixList] objectAtIndex: [[viewerController imageView] curImage]];
	
	if( [ForceRatioCheck state] == NSOnState)
	{
		switch( [sender tag])
		{
			case 0:
				[YText setIntValue:  originRatio * ([sender intValue]  * originHeight) / (originWidth)];
			break;
			
			case 1:
				[XText setIntValue: ([sender intValue]  * originWidth) / (originHeight * originRatio)];
			break;
			
			case 2:
			break;
		}
		
		[RatioText setFloatValue:1.0];
	}
	else
	{
		[RatioText setFloatValue: originRatio * ([XText floatValue] / (float) originWidth) / ([YText floatValue] / (float) originHeight) ];
	}
	
	[MemoryText setFloatValue: ([XText intValue] * [YText intValue] * [ZText intValue] * 4.) / (1024. * 1024.)];
}

- (IBAction) setForceRatio:(id) sender
{
	if( [sender state] == NSOnState)
	{
		[YText setIntValue: ([XText intValue] * originRatio * originHeight) / originWidth];
		
		[RatioText setFloatValue:1.0];
	}
	
	[MemoryText setFloatValue: ([XText intValue] * [YText intValue] * [ZText intValue] * 4.) / (1024. * 1024.)];
}

-(IBAction) endDialog:(id) sender
{
    [window orderOut:sender];
    
    [NSApp endSheet:window returnCode:[sender tag]];
    
    if( [sender tag])   //User clicks OK Button
    {
		long				i, y, x, z, imageSize, newX, newY, newZ, size;
		NSArray				*pixList = [viewerController pixList];
		float				*srcImage, *dstImage, *emptyData;
		DCMPix				*curPix;
		ViewerController	*new2DViewer;
		
		// Display a waiting window
		id waitWindow = [viewerController startWaitWindow:@"I'm working for you!"];
		
		newX = [XText intValue];
		newY = [YText intValue];
		newZ = [ZText intValue];
		
		imageSize = newX * newY;
		size = sizeof(float) * newZ * imageSize;
		
		// CREATE A NEW SERIES TO CONTAIN THIS NEW RE-SAMPLED SERIES
		emptyData = malloc( size);
		if( emptyData)
		{
			NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
			NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
			NSData	*newData = [NSData dataWithBytesNoCopy:emptyData length: size freeWhenDone:YES];
			
			for( z = 0 ; z < newZ; z ++)
			{
				curPix = [pixList objectAtIndex: (originZ * z) / newZ];
				
				DCMPix	*copyPix = [curPix copy];
				
				[newPixList addObject: copyPix];
				[copyPix release];
				
				[newDcmList addObject: [[viewerController fileList] objectAtIndex: (originZ * z) / newZ]];
				
				[[newPixList lastObject] setPwidth: newX];
				[[newPixList lastObject] setPheight: newY];
				
				[[newPixList lastObject] setfImage: (float*) (emptyData + imageSize * z)];
				[[newPixList lastObject] setTot: newZ];
				[[newPixList lastObject] setFrameNo: z];
				[[newPixList lastObject] setID: z];
				
				[[newPixList lastObject] setPixelSpacingX: ([curPix pixelSpacingX] * originWidth) / newX];
				[[newPixList lastObject] setPixelSpacingY: ([curPix pixelSpacingY] * originHeight) / newY];
				
				[[newPixList lastObject] setPixelRatio:  originRatio * ((float) newX / (float) originWidth) / ((float) newY / (float) originHeight)];
				
				[[newPixList lastObject] setSliceInterval: 0];
			}
		
			for( z = 0; z < newZ; z++)
			{
				vImage_Buffer	srcVimage, dstVimage;
				
				curPix = [pixList objectAtIndex: (originZ * z) / newZ];
				
				srcImage = [curPix  fImage];
				dstImage = emptyData + imageSize * z;
				
				srcVimage.data = srcImage;
				srcVimage.height =  originHeight;
				srcVimage.width = originWidth;
				srcVimage.rowBytes = originWidth*4;
				
				dstVimage.data = dstImage;
				dstVimage.height =  newY;
				dstVimage.width = newX;
				dstVimage.rowBytes = newX*4;
				
				if( [curPix isRGB])
				{
					vImageScale_ARGB8888( &srcVimage, &dstVimage, 0L, 0);
				}
				else
					vImageScale_PlanarF( &srcVimage, &dstVimage, 0L, 0);	//kvImageHighQualityResampling
			}
			
			// CREATE A SERIES
			new2DViewer = [viewerController newWindow	:newPixList
														:newDcmList
														:newData];
		}
		// Close the waiting window
		[viewerController endWaitWindow: waitWindow];
		
		// We modified the view: OsiriX please update the display!
		[viewerController needsDisplayUpdate];
    }
}

- (long) filterImage:(NSString*) menuName
{
	DCMPix			*curPix;
	long			i;
	
	[NSBundle loadNibNamed:@"DialogResampleData" owner:self];
	
	curPix = [[viewerController pixList] objectAtIndex: [[viewerController imageView] curImage]];
	
	originRatio = [curPix pixelRatio];
	originWidth = [curPix pwidth];
	originHeight = [curPix pheight];
	originZ = [[viewerController pixList] count];
	
	if( originRatio == 1.0) [ForceRatioCheck setState: NSOnState];
	else [ForceRatioCheck setState: NSOffState];
	
	[RatioText setFloatValue: originRatio];
	[XText setIntValue: originWidth];
	[YText setIntValue: originHeight];
	[ZText setIntValue: originZ];
	
	[oXText setIntValue: originWidth];
	[oYText setIntValue: originHeight];
	[oZText setIntValue: originZ];
	
	[MemoryText setFloatValue: ([XText intValue] * [YText intValue] * [ZText intValue] * 4.) / (1024. * 1024.)];
	
	[NSApp beginSheet: window modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
	
	return 0;
}

@end
