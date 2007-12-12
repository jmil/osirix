/*=========================================================================
Author: Chunliang Wang (chunliang.wang@imv.liu.se)


Program:  CMIV CTA image processing Plugin for OsiriX

This file is part of CMIV CTA image processing Plugin for OsiriX.

Copyright (c) 2007,
Center for Medical Image Science and Visualization (CMIV),
Linkšping University, Sweden, http://www.cmiv.liu.se/

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

#import "CMIVChopperController.h"

#define id Id
#include <vtkImageData.h>
#undef id


@implementation CMIVChopperController



- (IBAction)changeReformView:(id)sender
{
	if([reformViewState selectedSegment])
	{
		[reformViewSlider setMaxValue: imageHeight];
		[reformViewSlider setIntValue: imageHeight/2];
		[curReformROI setROIRect:sagittalROIRect];
	}
	else
	{
		[reformViewSlider setMaxValue: imageHeight];
		[reformViewSlider setIntValue: imageHeight/2];
		[curReformROI setROIRect:coronalROIRect];
	}
	[self setReformViewIndex:reformViewSlider ];

}

- (IBAction)setImageFromTo:(id)sender
{
	iImageFrom = [imageFrom intValue];
	iImageTo = [imageTo intValue];
	coronalROIRect.origin.y = (iImageFrom-1) / ratioYtoThick ;	
	coronalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick;
	sagittalROIRect.origin.y = (iImageFrom-1)/ ratioYtoThick ;
	sagittalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick ;	
	[self updateImageFromToSliders];
	[self updateALLROIs];	
}

- (IBAction)setImageFromToSlider:(id)sender
{
	iImageFrom = [imageFromSlider intValue];
	iImageTo = [imageToSlider intValue];
	coronalROIRect.origin.y = (iImageFrom-1) / ratioYtoThick ;	
	coronalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick;
	sagittalROIRect.origin.y = (iImageFrom-1)/ ratioYtoThick ;
	sagittalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick ;	
	[self updateAllTextField];
	[self updateALLROIs];
}
- (IBAction)setCurrentToImageFromTo:(id)sender
{

	if([sender tag])
		iImageTo= imageAmount - [ originalView curImage ];
	else
	    iImageFrom = imageAmount - [ originalView curImage ];
	coronalROIRect.origin.y = (iImageFrom-1) / ratioYtoThick ;	
	coronalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick;
	sagittalROIRect.origin.y = (iImageFrom-1)/ ratioYtoThick ;
	sagittalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick ;	
	[self updateALLROIs];
	[self updateAllTextField];
	[self updateImageFromToSliders];
	
}
- (IBAction)setROIRect:(id)sender
{
	roiRect.origin.x = [leftTopX intValue];
	roiRect.origin.y = [leftTopY intValue];
	roiRect.size.width = [rightBottomX intValue] - [leftTopX intValue];
	roiRect.size.height  = [rightBottomY intValue] - [leftTopX intValue];
	
	coronalROIRect.origin.x = roiRect.origin.x;

	coronalROIRect.size.width = roiRect.size.width ;

	
	sagittalROIRect.origin.x = roiRect.origin.y / ratioXtoY ;
	sagittalROIRect.size.width = roiRect.size.height / ratioXtoY;
	
	[self updateALLROIs];
}

- (IBAction)endPanel:(id)sender
{
	NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];

	if(reader)
	{
		reader->Delete() ;
		sliceTransform->Delete();
		rotate->Delete();
		
	}
	//if(outputVolumeData)
	//	free(outputVolumeData);
	unsigned int i;
	for( i = 0; i < [[originalViewController pixList] count]; i++)
	{
		[[roiListAxial objectAtIndex:i] removeAllObjects];
	}
	
	[roiListAxial removeAllObjects];
	[roiListAxial release];
	[curAxialROI release];
	[[roiListReform objectAtIndex: 0] removeAllObjects];
	[roiListReform removeAllObjects];
	[roiListReform release];
	[curReformROI release];
    [reformPixList removeAllObjects];
	[reformPixList release];
    if( [sender tag]&&!isSelectAll)   //User clicks OK Button
    {
		
		float				*srcImage, *dstImage;
		int                 x,y,z;
		int                 x1,x2,y1,y2,z1,z2;
		long                size;
		NSArray				*pixList = [originalViewController pixList];
		x1 = [leftTopX intValue];
		x2 = [rightBottomX intValue];
		y1 = [leftTopY intValue];
		y2 = [rightBottomY intValue];
		z1 = imageAmount - [imageFrom intValue];
		z2 = imageAmount - [imageTo intValue];
		int tempint;
		if(x1>x2)
		{
			tempint = x1;
			x1=x2;
			x2=tempint;
		}
		if(y1>y2)
		{
			tempint = y1;
			y1=y2;
			y2=tempint;
		}
		if(z1>z2)
		{
			tempint = z1;
			z1=z2;
			z2=tempint;
		}
		if(z1<0)
			z1=0;
		if(z2>=imageAmount)
			z2=imageAmount-1;
		
		size = sizeof(float) * (x2-x1+1) * (y2-y1+1) * (z2-z1+1);
		id waitWindow = [originalViewController startWaitWindow:@"processing"];
		
		outputVolumeData = (float*) malloc(size);
		if( !outputVolumeData)
		{
			NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);
			[originalViewController endWaitWindow: waitWindow];
			return ;	
		}
		
		for( z = z1; z <= z2; z++)
		{
			curPix = [pixList objectAtIndex: z];
			
			srcImage = [curPix  fImage];
			dstImage = outputVolumeData + (x2-x1+1) * (y2-y1+1) * (z-z1);
			
			for(y = y1;y <= y2; y++)
				for(x = x1; x <= x2; x++)
					*( dstImage + (x2-x1+1)*(y-y1) + x-x1) = *( srcImage + imageWidth*y + x);
		}	
		
		NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
		NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
		NSData	*newData = [NSData dataWithBytesNoCopy:outputVolumeData length: size freeWhenDone:YES];
		for( z = z1 ; z <= z2; z ++)
		{
			curPix = [pixList objectAtIndex: z];
			DCMPix	*copyPix = [curPix copy];
			[newPixList addObject: copyPix];
			[copyPix release];
			[newDcmList addObject: [[originalViewController fileList] objectAtIndex: z]];
			[[newPixList lastObject] setPwidth: x2-x1+1];
			[[newPixList lastObject] setPheight: y2-y1+1];
			[[newPixList lastObject] setfImage: (float*) (outputVolumeData + (x2-x1+1)* (y2-y1+1)* (z-z1))];
			[[newPixList lastObject] setTot: (z2-z1+1)];
			[[newPixList lastObject] setFrameNo: (z-z1+1)];
			[[newPixList lastObject] setID: (z-z1+1)];
			
		}
		
		// CREATE A SERIES
		if([sender tag])
		{
			[originalViewController replaceSeriesWith:newPixList
												     :newDcmList
												     :newData];
	
		}

		[originalViewController endWaitWindow: waitWindow];
		
		if([sender tag])
		{
			[originalViewController checkEverythingLoaded];
			[[originalViewController window] setTitle:@"VOI"];
		}
		
	}
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[window setReleasedWhenClosed:YES];
	[window close];
    [NSApp endSheet:window returnCode:[sender tag]];
//	[originalView release];
//	[reformView release];
	/*
	for( i = 0; i < [toolbarList count]; i++)
	{
		[[toolbarList objectAtIndex: i] setVisible: YES];
		
	}
	[toolbarList removeAllObjects];*/
	
	[pool release];
	if([sender tag]==2)
		[parent gotoStepNo:2];
	else
		[parent exitCurrentDialog];
	
	

}
- (void)showPanelAsWizard:(ViewerController *) vc:(	CMIV_CTA_TOOLS*) owner
{
	isInWizardMode=YES;

	[self showChopperPanel: vc:owner];
	
}
- (int) showChopperPanel:(ViewerController *) vc:(CMIV_CTA_TOOLS*) owner
{
	int err=0;
	originalViewController=vc;
	parent = owner;
	curPix = [[originalViewController pixList] objectAtIndex: [[originalViewController imageView] curImage]];;
	NSArray				*pixList = [originalViewController pixList];
	NSArray             *fileList =[originalViewController fileList ];

	if( [curPix isRGB])
	{
		NSRunAlertPanel(NSLocalizedString(@"no RGB Support", nil), NSLocalizedString(@"This plugin doesn't surpport RGB images, please convert this series into BW images first", nil), NSLocalizedString(@"OK", nil), nil, nil);
		
		return 0;
	}	

	
	[NSBundle loadNibNamed:@"Chopper_Panel" owner:self];
	NSRect screenrect=[[[originalViewController window] screen] visibleFrame];
	[window setFrame:screenrect display:YES ];


	imageWidth = [curPix pwidth];
	imageHeight = [curPix pheight];
	imageAmount = [pixList count];
	
	roiRect.origin.x=imageWidth/8;
	roiRect.origin.y=imageHeight/8;
	roiRect.size.width=imageWidth*3/4;
	roiRect.size.height=imageHeight*3/4;
	iImageFrom = 1;
	iImageTo = imageAmount;
	[imageFromSlider setMaxValue: imageAmount];
	[imageToSlider setMaxValue: imageAmount];
	[originalViewSlider setMaxValue: imageAmount-1];
	[originalViewSlider setIntValue: imageAmount/2];
	[reformViewSlider setMaxValue: imageHeight];
	[reformViewSlider setIntValue: imageHeight/2];
	
	[reformViewState setSelectedSegment:0];
	
	RGBColor color;
	color.red = 0;
	color.blue = 0;
	color.green =65535;
	
	NSString *roiName = [NSString stringWithString:@"ROI"];
	curAxialROI = [[ROI alloc] initWithType: tROI :[curPix pixelSpacingX] :[curPix pixelSpacingY] : NSMakePoint( [curPix originX], [curPix originY])];
	[curAxialROI setName:roiName];
	[curAxialROI setROIRect:roiRect];
	[curAxialROI setColor:color];

	roiListAxial = [[NSMutableArray alloc] initWithCapacity: 0];
	unsigned int i;
	for( i = 0; i < [pixList count]; i++)
	{
		[roiListAxial addObject:[NSMutableArray arrayWithCapacity:0]];
		[[roiListAxial objectAtIndex:i] addObject:curAxialROI];
	}
	
	
	[originalView setDCM:pixList :fileList :roiListAxial :0 :'i' :YES];
	[originalView setStringID: roiName];
	[originalView setIndexWithReset: [pixList count]/2 :YES];
	[originalView setOrigin: NSMakePoint(0,0)];
	[originalView setCurrentTool:tROI];
	[originalView  scaleToFit];	
	[curAxialROI setROIMode:ROI_selected]; 
	
	err = [self initReformView];
	[curReformROI setROIMode:ROI_selected];
	if(!err)
	{
	
		[self  updateImageFromToSliders];
		[self updateAllTextField];
		
		
		
		NSNotificationCenter *nc;
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(defaultToolModified:) name:@"defaultToolModified" object:nil];
		[nc addObserver:self selector:@selector(roiChanged:) name:@"roiChange" object:nil];
		[nc	addObserver: self selector: @selector(changeWLWW:) name: @"changeWLWW" object: nil];
		[NSApp beginSheet: window modalForWindow:[originalViewController window] modalDelegate:self didEndSelector:nil contextInfo:nil];
		[nc addObserver: self selector: @selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];

		if(!isInWizardMode)
		{
			[nextStep setHidden:YES];
			[wizardTips  setHidden:YES];
		}
	/*
		{
			NSArray				*winList = [NSApp windows];
			unsigned int i;
			toolbarList = [[NSMutableArray alloc] initWithCapacity: 0];
			for( i = 0; i < [winList count]; i++)
			{
				if( [[winList objectAtIndex:i] toolbar])
				{
					NSToolbar *aToolbar=[[winList objectAtIndex:i] toolbar];
					if([aToolbar isVisible])
					{
						[toolbarList addObject: aToolbar];
						[aToolbar setVisible:NO];
					}
					
					
				}
				
			}
		}*/
	}
	
	return err;
	
}
- (void) updateAllTextField
{
	[leftTopX setIntValue: (int)(roiRect.origin.x)];
	[leftTopY setIntValue: (int)(roiRect.origin.y)];
	[rightBottomX setIntValue: (int)(roiRect.origin.x+roiRect.size.width)];
	[rightBottomY setIntValue: (int)(roiRect.origin.y+roiRect.size.height)];
	[imageFrom setIntValue:iImageFrom];
	[imageTo setIntValue:iImageTo];
	isSelectAll=NO;
	
}
- (void) updateImageFromToSliders
{
	[imageFromSlider setIntValue: iImageFrom];
	[imageToSlider  setIntValue: iImageTo];
}
-(void) defaultToolModified: (NSNotification*) note
{
	id sender = [note object];
	int tag;
	
	if( sender)
	{
		if ([sender isKindOfClass:[NSMatrix class]])
		{
			NSButtonCell *theCell = [sender selectedCell];
			tag = [theCell tag];
		}
		else
		{
			tag = [sender tag];
		}
	}
	else tag = [[[note userInfo] valueForKey:@"toolIndex"] intValue];
	
	if( tag >= 0 ) 
	{
		if( tag > 4)
			tag = 6;
		[originalView setCurrentTool: tag];
		[reformView setCurrentTool: tag];
	}
}
-(void) roiChanged: (NSNotification*) note
{

	id sender = [note object];
	
	if( sender)
	{
		if ([sender isKindOfClass:[ROI class]])
		{
			if([curAxialROI isEqual:sender]==YES)
			{
				int lefttopx,lefttopy,rightbottomx,rightbottomy,pointamount;
				NSMutableArray  *ptsTemp = [curAxialROI points];
				pointamount = [ptsTemp count];
				
				lefttopx = rightbottomx =  (int)([[ptsTemp objectAtIndex: 0] point].x);
				lefttopy = rightbottomy =  (int)([[ptsTemp objectAtIndex: 0] point].y);
				int k,tempxx,tempyy;
				for( k = 1; k < pointamount; k++)
				{
					tempxx = (int)([[ptsTemp objectAtIndex: k] point].x);
					tempyy = (int)([[ptsTemp objectAtIndex: k] point].y);
					if(tempxx < lefttopx) 
						lefttopx = tempxx;
					if(tempxx > rightbottomx )
						rightbottomx = tempxx;
					if( tempyy < lefttopy )
						lefttopy = tempyy;
					if( tempyy > rightbottomy )
						rightbottomy = tempyy;
				}
				if(lefttopx<0)
					lefttopx=0;
				if(lefttopy<0)
					lefttopy=0;
				if(rightbottomx>=imageWidth)
					rightbottomx=imageWidth-1;
				if(rightbottomy>=imageHeight)
					rightbottomy=imageHeight-1;	
				roiRect.origin.x = lefttopx;
				roiRect.origin.y = lefttopy;
				roiRect.size.width = rightbottomx - lefttopx;
				roiRect.size.height = rightbottomy - lefttopy;
				
				coronalROIRect.origin.x = roiRect.origin.x;
				coronalROIRect.size.width = roiRect.size.width ;
				sagittalROIRect.origin.x = roiRect.origin.y / ratioXtoY ;
				sagittalROIRect.size.width = roiRect.size.height / ratioXtoY;
				
				if([reformViewState selectedSegment])
					[curReformROI setROIRect:sagittalROIRect];
				else
					[curReformROI setROIRect:coronalROIRect];
				[reformView setIndex: 0];

				
				
				
				[self updateAllTextField];
			}	
			else if ([curReformROI isEqual:sender]==YES)
			{
				int lefttopx,lefttopy,rightbottomx,rightbottomy,pointamount;
				NSMutableArray  *ptsTemp = [curReformROI points];
				pointamount = [ptsTemp count];
				
				lefttopx = rightbottomx =  (int)([[ptsTemp objectAtIndex: 0] point].x);
				lefttopy = rightbottomy =  (int)([[ptsTemp objectAtIndex: 0] point].y);
				int k,tempxx,tempyy;
				for( k = 1; k < pointamount; k++)
				{
					tempxx = (int)([[ptsTemp objectAtIndex: k] point].x);
					tempyy = (int)([[ptsTemp objectAtIndex: k] point].y);
					if(tempxx < lefttopx) 
						lefttopx = tempxx;
					if(tempxx > rightbottomx )
						rightbottomx = tempxx;
					if( tempyy < lefttopy )
						lefttopy = tempyy;
					if( tempyy > rightbottomy )
						rightbottomy = tempyy;
				}
				
				
				if([reformViewState selectedSegment])
				{
					if(lefttopx<0)
						lefttopx=0;

					if(rightbottomx>=imageHeight)
						rightbottomx=imageHeight-1;

					
					sagittalROIRect.origin.x = lefttopx;
					sagittalROIRect.origin.y = lefttopy;
					sagittalROIRect.size.width = rightbottomx - lefttopx;
					sagittalROIRect.size.height = rightbottomy - lefttopy;
					
					iImageFrom = (int)(sagittalROIRect.origin.y * ratioYtoThick+1);
					iImageTo = (int)(sagittalROIRect.size.height * ratioYtoThick + sagittalROIRect.origin.y * ratioYtoThick+1);
					roiRect.origin.y = sagittalROIRect.origin.x *ratioXtoY;			
					roiRect.size.height = sagittalROIRect.size.width * ratioXtoY;
		
					coronalROIRect.origin.y = (iImageFrom-1) / ratioYtoThick ;
					coronalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick;
					
					
				}
				else
				{
					if(lefttopx<0)
						lefttopx=0;
					
					if(rightbottomx>=imageWidth)
						rightbottomx=imageWidth-1;
					
					coronalROIRect.origin.x = lefttopx;
					coronalROIRect.origin.y = lefttopy;
					coronalROIRect.size.width = rightbottomx - lefttopx;
					coronalROIRect.size.height = rightbottomy - lefttopy;
					
					iImageFrom = (int)(coronalROIRect.origin.y * ratioYtoThick+1);
					iImageTo = (int)(coronalROIRect.size.height * ratioYtoThick + coronalROIRect.origin.y * ratioYtoThick+1);
					

					roiRect.origin.x = coronalROIRect.origin.x ;

					roiRect.size.width = coronalROIRect.size.width ;
				

					sagittalROIRect.origin.y = (iImageFrom-1)/ ratioYtoThick ;
					sagittalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick ;
					
					
				}
				if(iImageFrom<1)
					iImageFrom = 1 ;
				if(iImageTo > imageAmount)
					iImageTo = imageAmount;

				[curAxialROI setROIRect:roiRect];
				[originalView setIndex: [originalView curImage ]];
				[self updateImageFromToSliders];
				[self updateAllTextField];
			}
		}
	}
	

		return;
}
- (int)  initReformView
{

	long                size;

	NSArray				*pixList = [originalViewController pixList];
	size = sizeof(float) * imageWidth * imageHeight * imageAmount;
	outputVolumeData=[originalViewController volumePtr:0];
	
	
	curPix = [pixList objectAtIndex: 0];
	
	float vectors[9];
	[curPix orientation:vectors];			
	vtkOriginalX = ([curPix originX] ) * vectors[0] + ([curPix originY]) * vectors[1] + ([curPix originZ] )*vectors[2];
	vtkOriginalY = ([curPix originX] ) * vectors[3] + ([curPix originY]) * vectors[4] + ([curPix originZ] )*vectors[5];
	 vtkOriginalZ = ([curPix originX] ) * vectors[6] + ([curPix originY]) * vectors[7] + ([curPix originZ] )*vectors[8];
	sliceThickness = [curPix sliceInterval];   
	if( sliceThickness == 0)
	{
		NSLog(@"Slice interval = slice thickness!");
		sliceThickness = [curPix sliceThickness];
	}
	
	ratioXtoThick = [curPix pixelSpacingX]/sliceThickness;
	ratioYtoThick = [curPix pixelSpacingY]/sliceThickness;
	ratioXtoY = [curPix pixelSpacingX]/[curPix pixelSpacingY];
		
	reader = vtkImageImport::New();
	reader->SetWholeExtent(0, imageWidth-1, 0, imageHeight-1, 0, imageAmount-1);
	reader->SetDataSpacing( [curPix pixelSpacingX], [curPix pixelSpacingY], sliceThickness);
	reader->SetDataOrigin( vtkOriginalX,vtkOriginalY,vtkOriginalZ );
	//reader->SetDataOrigin(  [firstObject originX],[firstObject originY],[firstObject originZ]);
	reader->SetDataExtentToWholeExtent();
	reader->SetDataScalarTypeToFloat();
	
	reader->SetImportVoidPointer(outputVolumeData);
	
	
	
	sliceTransform = vtkTransform::New();
	sliceTransform->RotateX( -90);
	sliceTransform->Translate( 0, 0, vtkOriginalY + [curPix pixelSpacingY]*imageWidth/2 );	
	// FINAL IMAGE RESLICE
	
	rotate = vtkImageReslice::New();
	rotate->SetAutoCropOutput( true);
	rotate->SetInformationInput( reader->GetOutput());
	rotate->SetInput( reader->GetOutput());
	rotate->SetOptimization( true);
	rotate->SetResliceTransform( sliceTransform);
	rotate->SetResliceAxesOrigin( 0, 0, 0);
	

	
	
	//	rotate->SetTransformInputSampling( false);
	rotate->SetInterpolationModeToNearestNeighbor();	//SetInterpolationModeToLinear(); //SetInterpolationModeToCubic();	//SetInterpolationModeToCubic();
	rotate->SetOutputDimensionality( 2);
	//	rotate->SetOutputOrigin( 0,0,0);
	rotate->SetBackgroundLevel( -1024);
	
	vtkImageData	*tempIm;
	int				imExtent[ 6];
	double		space[ 3], origin[ 3];
	tempIm = rotate->GetOutput();
	tempIm->Update();
	tempIm->GetWholeExtent( imExtent);
	tempIm->GetSpacing( space);
	tempIm->GetOrigin( origin);	
	
	float *im = (float*) tempIm->GetScalarPointer();
	DCMPix*		mypix = [[DCMPix alloc] initwithdata:(float*) im :32 :imExtent[ 1]-imExtent[ 0]+1 :imExtent[ 3]-imExtent[ 2]+1 :space[0] :space[1] :origin[0] :origin[1] :origin[2]];
	[mypix copySUVfrom: curPix];	
	
	reformPixList = [[NSMutableArray alloc] initWithCapacity:0];
	[reformPixList addObject: mypix];

	reformFileList = [originalViewController fileList ];
	
	//initlize roi 
	
	
	coronalROIRect.origin.x = roiRect.origin.x;
	coronalROIRect.origin.y = (iImageFrom-1) / ratioYtoThick ;
	coronalROIRect.size.width = roiRect.size.width ;
	coronalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick;
	
	sagittalROIRect.origin.x = roiRect.origin.y / ratioXtoY ;
	sagittalROIRect.origin.y = (iImageFrom-1)/ ratioYtoThick ;
	sagittalROIRect.size.width = roiRect.size.height / ratioXtoY;
	sagittalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick ;
	
	RGBColor color;
	color.red = 0;
	color.blue = 0;
	color.green =65535;
	
	NSString *roiName = [NSString stringWithString:@"reformROI"];
	
	curReformROI = [[ROI alloc] initWithType: tROI :[mypix pixelSpacingX] :[mypix pixelSpacingY] : NSMakePoint( [mypix originX], [mypix originY])];
	[curReformROI setName:roiName];
	[curReformROI setROIRect:coronalROIRect];
	[curReformROI setColor:color];
	roiListReform = [[NSMutableArray alloc] initWithCapacity: 0];

	[roiListReform addObject:[NSMutableArray arrayWithCapacity:0]];
	[[roiListReform objectAtIndex:0] addObject:curReformROI];


	

	[reformView setDCM:reformPixList :reformFileList :roiListReform :0 :'i' :YES];
	[reformView setStringID:roiName];
	[reformView setIndexWithReset: 0 :YES];
	[reformView setOrigin: NSMakePoint(0,0)];
	[reformView setCurrentTool:tROI];
	[reformView  scaleToFit];
	float iwl, iww;
	iww = [originalView curWW];
	iwl = [originalView curWL];
	[reformView setWLWW:iwl :iww];
	
	[mypix release];
	return 0;
}
- (void) updateALLROIs
{
	[curAxialROI setROIRect:roiRect];
	int i=[originalView curImage ];
	[originalView setIndex: i];
	if([reformViewState selectedSegment])
		[curReformROI setROIRect:sagittalROIRect];
	else
		[curReformROI setROIRect:coronalROIRect];
	[reformView setIndex: 0];
	isSelectAll=NO;
	
}
- (IBAction)setReformViewIndex:(id)sender
{
	int i;
	i=[sender intValue];
	sliceTransform->Identity();
	if([reformViewState selectedSegment])
	{
		sliceTransform->RotateY( -90);
		sliceTransform->RotateZ( 90);
		sliceTransform->Translate( 0, 0 ,-( vtkOriginalX + [curPix pixelSpacingX]*i));

	}
	else
	{
		sliceTransform->RotateX( -90);
		sliceTransform->Translate( 0, 0 , vtkOriginalY + [curPix pixelSpacingY]*i);
	}

	
	rotate->SetResliceAxesOrigin( 0, 0, 0);
	vtkImageData	*tempIm;
	int				imExtent[ 6];
	double		space[ 3], origin[ 3];
	tempIm = rotate->GetOutput();
	tempIm->Update();
	tempIm->GetWholeExtent( imExtent);
	tempIm->GetSpacing( space);
	tempIm->GetOrigin( origin);	
	
	float *im = (float*) tempIm->GetScalarPointer();
	DCMPix*		mypix = [[DCMPix alloc] initwithdata:(float*) im :32 :imExtent[ 1]-imExtent[ 0]+1 :imExtent[ 3]-imExtent[ 2]+1 :space[0] :space[1] :origin[0] :origin[1] :origin[2]];
	[mypix copySUVfrom: curPix];	
	
	//	finalPixList = [[NSMutableArray alloc] initWithCapacity:0];
	[reformPixList removeAllObjects];
	[reformPixList addObject: mypix];
	[mypix release];
	[reformView setIndex: 0 ];
	

	
	
}
- (void) changeWLWW: (NSNotification*) note
{
	id sender = [note object] ;
	if ([sender isKindOfClass:[DCMPix class]])
	{
		DCMPix	*otherPix = sender;
		float iwl, iww;
		
		iww = [otherPix ww];
		iwl = [otherPix wl];


		if( [reformPixList containsObject: otherPix])
		{

			if( iww != [originalView curWW] || iwl != [originalView curWL])
				[originalView setWLWW:iwl :iww];

		}
		else
		{

			if( iww != [reformView curWW] || iwl != [reformView curWL])
				[reformView setWLWW:iwl :iww];

		}
	}
	
}
- (IBAction)selectAll:(id)sender
{
	roiRect.origin.x = 0;
	roiRect.origin.y = 0;
	roiRect.size.width = imageWidth;
	roiRect.size.height = imageHeight;
	
	coronalROIRect.origin.x = roiRect.origin.x;
	coronalROIRect.size.width = roiRect.size.width ;
	sagittalROIRect.origin.x = roiRect.origin.y / ratioXtoY ;
	sagittalROIRect.size.width = roiRect.size.height / ratioXtoY;
	
	iImageFrom = 1;
	iImageTo = imageAmount;
	coronalROIRect.origin.y = (iImageFrom-1) / ratioYtoThick ;
	coronalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick;
	sagittalROIRect.origin.y = (iImageFrom-1)/ ratioYtoThick ;
	sagittalROIRect.size.height = (iImageTo-iImageFrom-1)/ ratioYtoThick ;
	[curAxialROI setROIRect:roiRect];
	[originalView setIndex: [originalView curImage ]];	
	if([reformViewState selectedSegment])
		[curReformROI setROIRect:sagittalROIRect];
	else
		[curReformROI setROIRect:coronalROIRect];
	[reformView setIndex: 0];
	[self updateImageFromToSliders];
	[self updateAllTextField];
	isSelectAll=YES;
}
- (void) windowDidBecomeMain:(NSNotification *)aNotification
{
	[self reHideToolbar];
}

- (void) reHideToolbar
{/*
	unsigned int i;
	for( i = 0; i < [toolbarList count]; i++)
	{
		[[toolbarList objectAtIndex: i] setVisible: NO];
		
	}*/
	
}
@end
