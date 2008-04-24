/*=========================================================================
 Author: Chunliang Wang (chunliang.wang@imv.liu.se)
 
 
 Program:  CMIV CTA image processing Plugin for OsiriX
 
 This file is part of CMIV CTA image processing Plugin for OsiriX.
 
 Copyright (c) 2007,
 Center for Medical Image Science and Visualization (CMIV),
 Linköping University, Sweden, http://www.cmiv.liu.se/
 
 CMIV CTA image processing Plugin for OsiriX is free software;
 you can redistribute it and/or modify it under the terms of the
 GNU General Public License as published by the Free Software 
 Foundation, either version 3 of the License, or (at your option)
 any later version.
 
 CMIV CTA image processing Plugin for OsiriX is distributed in
 the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 =========================================================================*/


#import "CMIV_AutoSeeding.h"
#import "CMIVAutoSeedingCore.h"


@implementation CMIV_AutoSeeding
-(int)runAutoSeeding:(ViewerController *) vc: (CMIV_CTA_TOOLS*) owner;
{
	parent=owner;
	originalViewController=vc;
	int err=0;

	DCMPix* curPix = [[originalViewController pixList] objectAtIndex: [[originalViewController imageView] curImage]];

	if( [curPix isRGB])
	{
		NSRunAlertPanel(NSLocalizedString(@"no RGB Support", nil), NSLocalizedString(@"This plugin doesn't surpport RGB images, please convert this series into BW images first", nil), NSLocalizedString(@"OK", nil), nil, nil);
		
		return 0;
	}	

	NSArray				*pixList = [originalViewController pixList];

	long origin[3],dimension[3];
	dimension[0] = [curPix pwidth];
	dimension[1] = [curPix pheight];
	dimension[2] = [pixList count];	
	imageWidth = [curPix pwidth];
	imageHeight = [curPix pheight];
	imageAmount = [pixList count];	
	imageSize= imageWidth*imageHeight;
	
	origin[0]=origin[1]=origin[2]=0;
	float*	volumeData=[originalViewController volumePtr:0];
	unsigned char* markerdata=(unsigned char* )malloc(imageWidth*imageHeight*imageAmount*sizeof(unsigned char));
	if(markerdata==nil)
	{
		NSRunAlertPanel(NSLocalizedString(@"no enough memory", nil), NSLocalizedString(@"no enough memory", nil), NSLocalizedString(@"OK", nil), nil, nil);
		
		return 0;
	}	
	memset(markerdata,0x00,imageWidth*imageHeight*imageAmount*sizeof(unsigned char));
//	[self readROIFromViewer:markerdata];
	id waitWindow = [originalViewController startWaitWindow:@"processing"];
	CMIVAutoSeedingCore* coreAlgorithm=[[CMIVAutoSeedingCore alloc] init];
	float lungthreshold = [curPix minValueOfSeries];
	if(lungthreshold<-300)
		lungthreshold=-300;
	else
		lungthreshold=700;
	[coreAlgorithm autoCroppingBasedOnLungSegment:volumeData:markerdata:lungthreshold:20:origin:dimension:1.0];
	[coreAlgorithm release];
	[originalViewController endWaitWindow: waitWindow];
	[self replaceOriginImage:markerdata];
	//[self exportResults:markerdata:origin:dimension];
	free(markerdata);
	return err;
	
	
}
-(void)readROIFromViewer:(unsigned char*)colorData

{

	int             x,y;
	NSMutableArray  *roiSeriesList;
	NSMutableArray  *roiImageList;
	ROI				*curROI = 0L;
	unsigned int			i,j;
	long            lefttopx, lefttopy,rightbottomx,rightbottomy;
	
	
	// All rois contained in the current series
	roiSeriesList = [originalViewController roiList];
	for( j = 0; j < [roiSeriesList count]; j++)
	{
		// All rois contained in the current image
		roiImageList = [roiSeriesList objectAtIndex: j];
		
		
		for( i = 0; i < [roiImageList count]; i++)
		{
			curROI = [roiImageList objectAtIndex: i];
			unsigned char colorindex=0;


			colorindex=[[curROI name] intValue];
			if(colorindex>0)
			{
				int roitype =[curROI type];
				if(roitype == tPlain)
				{
					unsigned char *textureBuffer= [curROI textureBuffer];
					int textureOriginX,textureOriginY,textureWidth;
					textureOriginX=lefttopx = [curROI textureUpLeftCornerX];
					textureOriginY=lefttopy = [curROI textureUpLeftCornerY];
					rightbottomx = [curROI textureDownRightCornerX]+1;
					rightbottomy = [curROI textureDownRightCornerY]+1;
					textureWidth = rightbottomx-lefttopx;
					if(lefttopx>rightbottomx)
					{	
						lefttopx = [curROI textureDownRightCornerX];
						rightbottomx = [curROI textureUpLeftCornerX];						
					}
					if(lefttopy>rightbottomy)
					{
						lefttopy = [curROI textureDownRightCornerY];
						rightbottomy = [curROI textureUpLeftCornerY];
					}
					if(lefttopx<0)
						lefttopx=0;
					if(lefttopy<0)
						lefttopy=0;
					if(rightbottomx>=imageWidth)
						rightbottomx=imageWidth-1;
					if(rightbottomy>=imageHeight)
						rightbottomy=imageHeight-1;
					
					
					for( y = lefttopy; y < rightbottomy ; y++)
						for(x=lefttopx; x < rightbottomx ; x++)
							if(*(textureBuffer+(y-textureOriginY)*textureWidth+x-textureOriginX))

								*(colorData + j*imageSize + y*imageWidth + x) = colorindex;					
					
				}
			}
		}
	}
	
	
	

}
-(void)replaceOriginImage:(unsigned char*)outData
{
	DCMPix* curPix;
	float*	volumeData=[originalViewController volumePtr:0];
	NSArray* pixList = [originalViewController pixList];
	curPix = [pixList objectAtIndex: 0];
	float minValueInCurSeries = [curPix minValueOfSeries];
	long size=imageAmount*imageWidth*imageHeight;
	long i;
	/*
	for(i=0;i<size;i++)
			volumeData[i]=outData[i];*/

	for(i=0;i<size;i++)
		if(!outData[i])
			volumeData[i]=minValueInCurSeries;
	DCMView* origninImageView=[originalViewController imageView];
	float wl,ww;
	[origninImageView getWLWW:&wl :&ww];
	[origninImageView setWLWW:wl :ww];
}
-(void)exportResults:(unsigned char*)outData:(long*)origin:(long*)dimesion

{
	
	float				*srcImage, *dstImage;
	int                 x,y,z;
	int                 x1,x2,y1,y2,z1,z2;
	long                size;
	DCMPix*             curPix;
	NSArray				*pixList = [originalViewController pixList];
	x1 = origin[0];
	x2 = origin[0]+dimesion[0];
	y1 = origin[1];
	y2 = origin[1]+dimesion[1];
	z1 = origin[2];
	z2 = origin[2]+dimesion[2];
	int tempint;	
	size = sizeof(float) * (x2-x1) * (y2-y1) * (z2-z1);

	
	float* outputVolumeData = (float*) malloc(size);
	if( !outputVolumeData)
	{
		NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);

		return ;	
	}
	curPix = [pixList objectAtIndex: 0];
	float minValueInCurSeries = [curPix minValueOfSeries];

	for( z = z1; z < z2; z++)
	{
		curPix = [pixList objectAtIndex: z];
		
		srcImage = [curPix  fImage];
		dstImage = outputVolumeData + (x2-x1) * (y2-y1) * (z-z1);
		
		for(y = y1;y <y2; y++)
			for(x = x1; x < x2; x++)
				if(*(outData+z*imageSize+imageWidth*y+x))
				*( dstImage + (x2-x1)*(y-y1) + x-x1) = *( srcImage + imageWidth*y + x);
				else
					*( dstImage + (x2-x1)*(y-y1) + x-x1)=minValueInCurSeries;
					
	}	

	NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
	NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
	NSData	*newData = [NSData dataWithBytesNoCopy:outputVolumeData length: size freeWhenDone:YES];
	for( z = z1 ; z < z2; z ++)
	{
		curPix = [pixList objectAtIndex: z];
		DCMPix	*copyPix = [curPix copy];
		[newPixList addObject: copyPix];
		[copyPix release];
		[newDcmList addObject: [[originalViewController fileList] objectAtIndex: z]];
		[[newPixList lastObject] setPwidth: x2-x1];
		[[newPixList lastObject] setPheight: y2-y1];
		[[newPixList lastObject] setfImage: (float*) (outputVolumeData + (x2-x1)* (y2-y1)* (z-z1))];
		[[newPixList lastObject] setTot: (z2-z1)];
		[[newPixList lastObject] setFrameNo: (z-z1)];
		[[newPixList lastObject] setID: (z-z1)];
		
	}
	
	// CREATE A SERIES

		[originalViewController replaceSeriesWith:newPixList
												 :newDcmList
												 :newData];

	

	[originalViewController checkEverythingLoaded];
	[[originalViewController window] setTitle:@"VOI"];

}

@end
