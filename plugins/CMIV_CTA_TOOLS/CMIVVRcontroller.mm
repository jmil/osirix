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
#import "CMIVVRcontroller.h"
#import "QuicktimeExport.h"
#include "VRMakeObject.h"

@implementation CMIVVRcontroller
-(NSImage*) imageForFrame:(NSNumber*) cur maxFrame:(NSNumber*) max
{
	float* newVolumeData=[originalViewController volumePtr:[cur intValue]%maxMovieIndex];
	[vrViewer movieChangeSource: newVolumeData];
	if ([max intValue]==220*maxMovieIndex&&[cur intValue]%maxMovieIndex==0)
	{
		int iteminrow=20,itemincolumn=10;
		int curint=[cur intValue]/maxMovieIndex;
		if(  curint == 0)
		{
			[vrViewer Vertical: 45];
			[vrViewer Vertical: 45];
			verticalAngleForVR=90;
		}
		else
		{
			if( verticalAngleForVR==-90 ) 
			{
				aCamera->Roll(360/iteminrow);
			}
			else if( verticalAngleForVR==90) 
			{
				aCamera->Roll(-360/iteminrow);
			}
			else
			{
				[vrViewer Vertical: -verticalAngleForVR];
			}
			
			if(curint%iteminrow==0)
			{
				if( verticalAngleForVR==-90 || verticalAngleForVR==90) 
				{
					[vrViewer Vertical: -45];
					[vrViewer Vertical: -45];
					aCamera->Azimuth(-360/iteminrow);
				}
				verticalAngleForVR-=180/itemincolumn;
				if( verticalAngleForVR==-90 ) 
				{
					aCamera->Azimuth(360/iteminrow);
					[vrViewer Vertical: -45];
					[vrViewer Vertical: -45];
				}
				
				
			}
			if( verticalAngleForVR!=-90 && verticalAngleForVR!=90)
			{
				aCamera->Azimuth(360/iteminrow);
				aCamera->Elevation(verticalAngleForVR);
			}
		}
	}
	return [vrViewer nsimageQuicktime];
	

}
-(NSImage*) imageForVR:(NSNumber*) cur maxFrame:(NSNumber*) max
{

	if ([max intValue]==220)
	{
		int iteminrow=20,itemincolumn=10;
		if( [cur intValue] == 0)
		{
			[vrViewer Vertical: 45];
			[vrViewer Vertical: 45];
			verticalAngleForVR=90;
		}
		else
		{
			if( verticalAngleForVR==-90 ) 
			{
				aCamera->Roll(360/iteminrow);
			}
			else if( verticalAngleForVR==90) 
			{
				aCamera->Roll(-360/iteminrow);
			}
			else
			{
				[vrViewer Vertical: -verticalAngleForVR];
			}
			
			if([cur intValue]%iteminrow==0)
			{
				if( verticalAngleForVR==-90 || verticalAngleForVR==90) 
				{
					[vrViewer Vertical: -45];
					[vrViewer Vertical: -45];
					aCamera->Azimuth(-360/iteminrow);
				}
				verticalAngleForVR-=180/itemincolumn;
				if( verticalAngleForVR==-90 ) 
				{
					aCamera->Azimuth(360/iteminrow);
					[vrViewer Vertical: -45];
					[vrViewer Vertical: -45];
				}
				
				
			}
			if( verticalAngleForVR!=-90 && verticalAngleForVR!=90)
			{
				aCamera->Azimuth(360/iteminrow);
				aCamera->Elevation(verticalAngleForVR);
			}
		}
	}
	return [vrViewer nsimageQuicktime];
}

- (IBAction)capureImage:(id)sender
{
	FSRef				fsref;
	FSSpec				spec, newspec;
	if(!isSegmentVR)
	{
		QuicktimeExport *mov = [[QuicktimeExport alloc] initWithSelector: self : @selector(imageForFrame: maxFrame:) :220*maxMovieIndex];

		NSString* path, *newpath;
		path=[mov createMovieQTKit:YES :NO :[[[originalViewController fileList] objectAtIndex:0] valueForKeyPath:@"series.study.name"]];
		if( path)
		{
			FSPathMakeRef((unsigned const char *)[path fileSystemRepresentation], &fsref, NULL);
			FSGetCatalogInfo( &fsref, kFSCatInfoNone,NULL, NULL, &spec, NULL);
			
			FSMakeFSSpec(spec.vRefNum, spec.parID, "\ptempMovie", &newspec);
			
			VRObject_MakeObjectMovie (&spec,&newspec, 220*maxMovieIndex);	
			
			[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
			
			newpath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"tempMovie"];
			
			[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
			
			[[NSFileManager defaultManager] movePath: newpath  toPath: path handler: nil];
			
			//[[NSWorkspace sharedWorkspace] openFile:path];
		}
		
		[mov release];
	}
	else
	{
		verticalAngleForVR = 0;
		QuicktimeExport *mov = [[QuicktimeExport alloc] initWithSelector: self : @selector(imageForVR: maxFrame:) :220];
		
		NSString* path, *newpath;
		
		path=[mov createMovieQTKit:YES :NO :[[[originalViewController fileList] objectAtIndex:0] valueForKeyPath:@"series.study.name"]];
		if( path)
		{
			FSPathMakeRef((unsigned const char *)[path fileSystemRepresentation], &fsref, NULL);
			FSGetCatalogInfo( &fsref, kFSCatInfoNone,NULL, NULL, &spec, NULL);
			
			FSMakeFSSpec(spec.vRefNum, spec.parID, "\ptempMovie", &newspec);
			
			VRObject_MakeObjectMovie (&spec,&newspec, 220);	
			
			[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
			
			newpath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"tempMovie"];
			
			[[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
			
			[[NSFileManager defaultManager] movePath: newpath  toPath: path handler: nil];
			
			//[[NSWorkspace sharedWorkspace] openFile:path];
		}
		
		
		
		
		[mov release];		
	}
	
}

- (IBAction)endPanel:(id)sender
{	
	if(isSegmentVR)
	{
		volumeOfVRView->SetProperty( volumePropteryOfVRView);
		[propertyDictList removeAllObjects];
	}
	[window setReleasedWhenClosed:YES];
	[window close];
	//[window orderOut:sender];
    [NSApp endSheet:window returnCode:[sender tag]];
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	

	if(isSegmentVR)
	{
		 unsigned int i;
		 for( i = 0; i < [toolbarList count]; i++)
		 {
			 [[toolbarList objectAtIndex: i] setVisible: YES];
			 
		 }
		 [toolbarList removeAllObjects];
	}

	[parent exitCurrentDialog];
	
}

- (IBAction)setColorProtocol:(id)sender
{
	unsigned int row = [segmentList selectedRow];
	[self applyCLUTToPropertyList:row];
	[self applyCLUT];
}
- (IBAction)setBackgroundColor:(id)sender
{
	[vrViewer changeColorWith:[colorControl color]];
	
}
- (IBAction)setOpacity:(id)sender
{
	unsigned int row = [segmentList selectedRow];
	float opacity = [opacitySlider floatValue];
	if(row>=0&&row<[propertyDictList count])
		[[propertyDictList objectAtIndex: row] setObject: [NSNumber numberWithFloat:opacity]  forKey:@"Opacity"];
	[self applyOpacity];
	[segmentList reloadData];
}

- (IBAction)setWLWW:(id)sender
{
	float ww,wl;
	ww = [wwSlider floatValue];
	wl = [wlSlider floatValue];	
	unsigned int i;	
	
	if([wlwwForAll state] == NSOnState)
	{

		for(i=0;i<[propertyDictList count];i++)
		{


			[[propertyDictList objectAtIndex:i] setObject: [NSNumber numberWithFloat:ww]  forKey:@"WW"];
			[[propertyDictList objectAtIndex:i] setObject: [NSNumber numberWithFloat:wl]  forKey:@"WL"];
		}
	}
	else
	{
		i = [segmentList selectedRow];
		if(i>=0&&i<[propertyDictList count])
		{
			[[propertyDictList objectAtIndex:i] setObject: [NSNumber numberWithFloat:ww]  forKey:@"WW"];
			[[propertyDictList objectAtIndex:i] setObject: [NSNumber numberWithFloat:wl]  forKey:@"WL"];			
		}
		
	}

	[self applyCLUT];
	[self applyOpacity];	

}

- (int) showVRPanel:(ViewerController *) vc:(CMIV_CTA_TOOLS*) owner
{

	originalViewController=vc;	
	parent = owner;
	maxMovieIndex=[vc maxMovieIndex];
	if(maxMovieIndex>1)
		isSegmentVR=0;
	else
		isSegmentVR=1;
	if(isSegmentVR)
		return [self initVRViewForSegmentalVR];
	else
		return [self initVRViewForDynamicVR];
}
- (int) initVRViewForSegmentalVR
{
	int err=0;
	DCMPix*				curPix = [[originalViewController pixList] objectAtIndex: [[originalViewController imageView] curImage]];;
	NSArray				*pixList = [originalViewController pixList];

	float maxInSeries,minInSeries;
	maxInSeries = [curPix maxValueOfSeries];
	minInSeries = [curPix minValueOfSeries];
	imageWidth = [curPix pwidth];
	imageHeight = [curPix pheight];
	imageAmount = [pixList count];
	//initilize proptery list
	propertyDictList = [[NSMutableArray alloc] initWithCapacity: 0];
	
	NSMutableArray *inROIArray = [[NSMutableArray alloc] initWithCapacity: 0];
	NSMutableArray *curRoiList = [originalViewController roiList];
	
	ROI * tempROI;	
	unsigned int i,j,k;
	int thereIsSameName ;
	for(i=0;i<[curRoiList count];i++)
		for(j=0;j<[[curRoiList objectAtIndex:i] count];j++)
		{
			tempROI = [[curRoiList objectAtIndex: i] objectAtIndex:j];
			thereIsSameName=0;
			if([tempROI type]==tPlain)
			{
				for(k=0;k<[inROIArray count];k++)
				{ 
					if ([[tempROI name] isEqualToString:[[inROIArray objectAtIndex: k] name]]==YES)
						thereIsSameName=1;
				}
				if(!thereIsSameName)
				{
					[inROIArray addObject:tempROI];
				}	
			}
			
		}

	NSMutableDictionary *tempProperyDict;
	float segmentWW,segmentWL;
//	segmentWW=[curPix ww];
//	segmentWL=[curPix wl];
	segmentWW = 600;
	segmentWL = 200;
	segmentWW = segmentWW*2047/(maxInSeries-minInSeries);
	segmentWL = (segmentWL-minInSeries)*2047/(maxInSeries-minInSeries);
	[wlSlider setFloatValue: segmentWL];
	[wwSlider setFloatValue: segmentWW];
	RGBColor	color;
	
	
	NSMutableArray *rArray,*gArray,*bArray,*xArray;
	
	rArray = [[NSMutableArray alloc] initWithCapacity: 0];
	gArray = [[NSMutableArray alloc] initWithCapacity: 0];
	bArray = [[NSMutableArray alloc] initWithCapacity: 0];
	xArray = [[NSMutableArray alloc] initWithCapacity: 0];
	
	[rArray addObject: [NSNumber numberWithFloat:0.0]];
	[gArray addObject: [NSNumber numberWithFloat:0.0]];
	[bArray addObject: [NSNumber numberWithFloat:0.0]];
	[xArray addObject: [NSNumber numberWithFloat:0.0]];

	[rArray addObject: [NSNumber numberWithFloat:1.0]];		
	[gArray addObject: [NSNumber numberWithFloat:0.0]];		
	[bArray addObject: [NSNumber numberWithFloat:0.0]];
	[xArray addObject: [NSNumber numberWithFloat:1024.0]];
	
	[rArray addObject: [NSNumber numberWithFloat:1.0]];		
	[gArray addObject: [NSNumber numberWithFloat:1.0]];		
	[bArray addObject: [NSNumber numberWithFloat:0.0]];
	[xArray addObject: [NSNumber numberWithFloat:1500.0]];

	[rArray addObject: [NSNumber numberWithFloat:1.0]];
	[gArray addObject: [NSNumber numberWithFloat:1.0]];	
	[bArray addObject: [NSNumber numberWithFloat:1.0]];
	[xArray addObject: [NSNumber numberWithFloat:2047.0]];	
	
	
	
	
	
	tempProperyDict = [NSMutableDictionary dictionary];
	[tempProperyDict setObject:[NSString stringWithString:@"other part"]  forKey:@"Name"];
	[tempProperyDict setObject: [NSNumber numberWithFloat:0.0] forKey:@"RangeFrom"];
	[tempProperyDict setObject: rArray forKey:@"RedTable"];
	[tempProperyDict setObject: gArray forKey:@"GreenTable"];
	[tempProperyDict setObject: bArray forKey:@"BlueTable"];
	[tempProperyDict setObject: xArray forKey:@"xTableForColorPoints"];
	[tempProperyDict setObject: [NSNumber numberWithFloat:0.001]  forKey:@"Opacity"];
	[tempProperyDict setObject: [NSNumber numberWithFloat:segmentWW]  forKey:@"WW"];
	[tempProperyDict setObject: [NSNumber numberWithFloat:segmentWL]  forKey:@"WL"];
	[propertyDictList addObject: tempProperyDict];	
	
	for(i=0;i<[inROIArray count];i++)
	{
		tempROI = [inROIArray objectAtIndex: i];	

		rArray = [[NSMutableArray alloc] initWithCapacity: 0];
		gArray = [[NSMutableArray alloc] initWithCapacity: 0];
		bArray = [[NSMutableArray alloc] initWithCapacity: 0];
		xArray = [[NSMutableArray alloc] initWithCapacity: 0];
		[rArray addObject: [NSNumber numberWithFloat:0.0]];
		[gArray addObject: [NSNumber numberWithFloat:0.0]];
		[bArray addObject: [NSNumber numberWithFloat:0.0]];
		[xArray addObject: [NSNumber numberWithFloat:0.0]];
		
		if([tempROI respondsToSelector:@selector(color)])
			color= [tempROI color];
		else
			color= [tempROI rgbcolor];
		[rArray addObject: [NSNumber numberWithFloat:color.red/65536.0]];		
		[gArray addObject: [NSNumber numberWithFloat:color.green /65536.0]];		
		[bArray addObject: [NSNumber numberWithFloat:color.blue/65536.0]];
		[xArray addObject: [NSNumber numberWithFloat:1024.0]];
		
		[rArray addObject: [NSNumber numberWithFloat:1.0]];
		[gArray addObject: [NSNumber numberWithFloat:1.0]];
		[bArray addObject: [NSNumber numberWithFloat:1.0]];
		[xArray addObject: [NSNumber numberWithFloat:2047.0]];

		
		
		
		
		
		tempProperyDict = [NSMutableDictionary dictionary];
		[tempProperyDict setObject: [tempROI name] forKey:@"Name"];
		[tempProperyDict setObject: [NSNumber numberWithFloat:(i+1)*2048.0] forKey:@"RangeFrom"];
		[tempProperyDict setObject: rArray forKey:@"RedTable"];
		[tempProperyDict setObject: gArray forKey:@"GreenTable"];
		[tempProperyDict setObject: bArray forKey:@"BlueTable"];
		[tempProperyDict setObject: xArray forKey:@"xTableForColorPoints"];
		[tempProperyDict setObject: [NSNumber numberWithFloat:1.0]  forKey:@"Opacity"];
		[tempProperyDict setObject: [NSNumber numberWithFloat:segmentWW]  forKey:@"WW"];
		[tempProperyDict setObject: [NSNumber numberWithFloat:segmentWL]  forKey:@"WL"];
		[propertyDictList addObject: tempProperyDict];
	}
	
	curProperyDict = [propertyDictList objectAtIndex: 0];

	wholeVolumeWW = [propertyDictList count]*2048;
	wholeVolumeWL = wholeVolumeWW/2;
		
	if([curPix SUVConverted])
	{
	NSRunCriticalAlertPanel( NSLocalizedString(@"SUVConverted",nil), NSLocalizedString( @"SUVConverted is true, can not apply segment volume rendering.",nil), NSLocalizedString(@"OK",nil), nil, nil);	
		return 0;
	}
	if( [curPix isRGB])
	{
		NSRunAlertPanel(NSLocalizedString(@"no RGB Support", nil), NSLocalizedString(@"This plugin doesn't surpport RGB images, please convert this series into BW images first", nil), NSLocalizedString(@"OK", nil), nil, nil);
		
		return 0;
	}	
	

	

		
	
	[NSBundle loadNibNamed:@"VR_Panel" owner:self];	
	[window setFrame:[[NSScreen mainScreen] visibleFrame] display:YES ];
	//initilize VR view	

	originalVolumeData=[originalViewController volumePtr:0];
	err = [vrViewer setPixSource:pixList :originalVolumeData ];
	clutViewPoints=[colorViewer getPoints];
	clutViewColors=[colorViewer getColors];
	NSString	*str =  @"/" ;
	
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: str];
	
	[vrViewer set3DStateDictionary:dict];
	if( err != 0)
	{
		NSRunCriticalAlertPanel( NSLocalizedString(@"Not Enough Memory",nil), NSLocalizedString( @"Not enough memory (RAM) to use the 3D engine.",nil), NSLocalizedString(@"OK",nil), nil, nil);
		return 0L;
	}
	
// get the control of color and opacity;	
	renderOfVRView = [vrViewer renderer];
	aCamera = renderOfVRView->GetActiveCamera();
	volumeCollectionOfVRView = renderOfVRView->GetVolumes();
	volumeOfVRView = (vtkVolume * )volumeCollectionOfVRView->GetItemAsObject (0);
	volumePropteryOfVRView = volumeOfVRView->GetProperty();
	myVolumeProperty = vtkVolumeProperty::New();
	myColorTransferFunction = vtkColorTransferFunction::New();
	myOpacityTransferFunction = vtkPiecewiseFunction::New();
	myVolumeProperty->SetColor( myColorTransferFunction );
	myVolumeProperty->SetScalarOpacity(myOpacityTransferFunction);
	myVolumeProperty->ShadeOn();
	myVolumeProperty->SetAmbient(0.15);
	myVolumeProperty->SetDiffuse(0.9);
	myVolumeProperty->SetSpecular(0.3);
	myVolumeProperty->SetSpecularPower(15);
	myVolumeProperty->SetShade( 1);
//	if( [[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask)
//		myVolumeProperty->SetInterpolationTypeToNearest();
 //   else 
//		myVolumeProperty->SetInterpolationTypeToLinear();// can not use linear interpolation because the CT value jump at edge
	volumeOfVRView->SetProperty( myVolumeProperty);
//	myGradientTransferFunction = vtkPiecewiseFunction::New();
//	myGradientTransferFunction->AddPoint(3,0.0);
//	myGradientTransferFunction->AddPoint(4,1.0);
////	myGradientTransferFunction->AddPoint(2000,1.0);
//	myGradientTransferFunction->AddPoint(2001,0.0);
//	volumePropteryOfVRView->SetGradientOpacity( myGradientTransferFunction );
//	volumePropteryOfVRView->ShadeOff ();
//	volumePropteryOfVRView->SetInterpolationTypeToLinear();// can not use linear interpolation because the CT value jump at edge



	//create new datevolume and new pixlist
	
	float tempfloat;

	volumeMapper=(vtkVolumeMapper *) volumeOfVRView->GetMapper() ;
	volumeImageData=(vtkImageData *)volumeMapper->GetInput();
	realVolumedata=(unsigned short*)volumeImageData->GetScalarPointer();
	unsigned int size=(unsigned int)(imageWidth*imageHeight*imageAmount);
	for(i=0;i<size;i++)
	{
		if(*(originalVolumeData+i)>10000)
			tempfloat=0;
		tempfloat=( (*(originalVolumeData+i))-minInSeries)*2047/(maxInSeries-minInSeries);
		if( tempfloat<0)
			tempfloat= 0.0;
		else if(tempfloat>2047.0)
			tempfloat = 2047.0;
		*(realVolumedata+i)=(unsigned short)tempfloat;
	}
	unsigned short segOffset;
	//set segment value
	int x,y,x1,x2,y1,y2,textureWidth;
	unsigned char * texture;
	for(i=0;i<[curRoiList count];i++)
		for(j=0;j<[[curRoiList objectAtIndex:i] count];j++)
		{
			tempROI = [[curRoiList objectAtIndex: i] objectAtIndex:j];

			if([tempROI type]==tPlain)
				for(k=0;k<[inROIArray count];k++)
					if ([[tempROI name] isEqualToString:[[inROIArray objectAtIndex: k] name]]==YES)
					{
						x1 = [tempROI textureUpLeftCornerX];
						y1 = [tempROI textureUpLeftCornerY];
						x2 = [tempROI textureDownRightCornerX];
						y2 = [tempROI textureDownRightCornerY];
						textureWidth = [tempROI textureWidth];
						texture = [tempROI textureBuffer];
						segOffset = (unsigned short)[[[propertyDictList objectAtIndex: k+1] objectForKey:@"RangeFrom"] floatValue];
						for(y=y1;y<=y2;y++)
							for(x=x1;x<=x2;x++)
							{
								if(*(texture+(y-y1)*textureWidth+x-x1))
									*(realVolumedata+imageWidth*imageHeight*i+imageWidth*y+x)+=segOffset;
									
							}

						
						
					}

			
		}

	osirixOffset=0;//[vrViewer offset];
	//osirixOffset-=100;
	float osirixValueFactor;
	osirixValueFactor =1.0;// [vrViewer valueFactor];
//	[vrViewer setShadingValues: 0:0 :0:0];
//	[vrViewer setEngine: 0];
//	[vrViewer setMode: 0];
	[self applyOpacity];	
	[self applyCLUT];
	


	
	
	[NSApp beginSheet: window modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
	[segmentList setDataSource:self];	
	//clean inROIArray

	

	NSArray				*winList = [NSApp windows];
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
	
	size=imageWidth*imageHeight*imageAmount;
	for(i=0;i<size;i++)
	{
		tempfloat=( (*(originalVolumeData+i))-minInSeries)*2047/(maxInSeries-minInSeries);
		if( tempfloat<0)
			tempfloat= 0.0;
		else if(tempfloat>2047.0)
			tempfloat = 2047.0;
		*(realVolumedata+i)=(unsigned short)tempfloat;
	}

	for(i=0;i<[curRoiList count];i++)
		for(j=0;j<[[curRoiList objectAtIndex:i] count];j++)
		{
			tempROI = [[curRoiList objectAtIndex: i] objectAtIndex:j];

			if([tempROI type]==tPlain)
				for(k=0;k<[inROIArray count];k++)
					if ([[tempROI name] isEqualToString:[[inROIArray objectAtIndex: k] name]]==YES)
					{
						x1 = [tempROI textureUpLeftCornerX];
						y1 = [tempROI textureUpLeftCornerY];
						x2 = [tempROI textureDownRightCornerX];
						y2 = [tempROI textureDownRightCornerY];
						textureWidth = [tempROI textureWidth];
						texture = [tempROI textureBuffer];
						segOffset = (unsigned short)[[[propertyDictList objectAtIndex: k+1] objectForKey:@"RangeFrom"] floatValue];
						for(y=y1;y<=y2;y++)
							for(x=x1;x<=x2;x++)
							{
								if(*(texture+(y-y1)*textureWidth+x-x1))
									*(realVolumedata+imageWidth*imageHeight*i+imageWidth*y+x)+=segOffset;
									
							}

						
						
					}

			
		}
		
	[inROIArray removeAllObjects];	
	[self selectASegment:nil];
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];	
	[nc addObserver: self selector: @selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];

		
	return err;

}
- (int) initVRViewForDynamicVR
{
	int err=0;
	
	NSArray				*pixList = [originalViewController pixList];
	[NSBundle loadNibNamed:@"VR_Panel" owner:self];	
	[window setFrame:[[NSScreen mainScreen] visibleFrame] display:YES ];
	//initilize VR view	

	originalVolumeData=[originalViewController volumePtr:0];
	err = [vrViewer setPixSource:pixList :originalVolumeData ];
	
	NSString	*str =  @"/" ;
	
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: str];
	
	[vrViewer set3DStateDictionary:dict];
	if( err != 0)
	{
		NSRunCriticalAlertPanel( NSLocalizedString(@"Not Enough Memory",nil), NSLocalizedString( @"Not enough memory (RAM) to use the 3D engine.",nil), NSLocalizedString(@"OK",nil), nil, nil);
		return 0L;
	}
	

	NSDictionary		*aCLUT,*aOpacity;
	NSArray				*array;
	long				i;
	unsigned char		red[256], green[256], blue[256];
	
	aCLUT = [[[NSUserDefaults standardUserDefaults] dictionaryForKey: @"CLUT"] objectForKey: @"VR Muscles-Bones"];
	if( aCLUT)
	{
		array = [aCLUT objectForKey:@"Red"];
		for( i = 0; i < 256; i++)
		{
			red[i] = [[array objectAtIndex: i] longValue];
		}
		
		array = [aCLUT objectForKey:@"Green"];
		for( i = 0; i < 256; i++)
		{
			green[i] = [[array objectAtIndex: i] longValue];
		}
		
		array = [aCLUT objectForKey:@"Blue"];
		for( i = 0; i < 256; i++)
		{
			blue[i] = [[array objectAtIndex: i] longValue];
		}
		
		[vrViewer setCLUT:red :green: blue];
		
	}
	aOpacity = [[[NSUserDefaults standardUserDefaults] dictionaryForKey: @"OPACITY"] objectForKey: NSLocalizedString(@"Logarithmic Inverse Table", nil)];
	if( aOpacity)
	{
		array = [aOpacity objectForKey:@"Points"];
		
		[vrViewer setOpacity:array];
	}

	renderOfVRView = [vrViewer renderer];
	aCamera = renderOfVRView->GetActiveCamera();

	[opacitySlider setEnabled: NO];
	[wlSlider setEnabled: NO];
	[wwSlider setEnabled: NO];
	[NSApp beginSheet: window modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
	[segmentList setDataSource:self];	
	return err;

}
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	if([segmentList isEqual:tableView])
	   {
		return [propertyDictList count];
	   }

	return 0;
	
}

- (id)tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(int)row
{
	if( originalViewController == 0L) return 0L;
	if([segmentList isEqual:tableView])
	   {
		
			if( [[tableColumn identifier] isEqualToString:@"Index"])
			{
				return [NSString stringWithFormat:@"%d", row+1];
			} 
			if( [[tableColumn identifier] isEqualToString:@"Name"])
			{
				return [[propertyDictList objectAtIndex:row] objectForKey:@"Name"];
			}
			if( [[tableColumn identifier] isEqualToString:@"Opacity"])
			{
				return [[propertyDictList objectAtIndex:row] objectForKey:@"Opacity"];
			}
	   }
		   
	
	return 0L;
}
- (void)applyOpacity
{
	int err=0;
	myOpacityTransferFunction->RemoveAllPoints ();
	unsigned int i;
	float offset,val;
	float ww,wl,start,end;
	for(i=0;i<[propertyDictList count];i++)
	{
		offset = [[[propertyDictList objectAtIndex:i] objectForKey:@"RangeFrom"] floatValue];
		offset += osirixOffset;
		val = 0.0;
		err=myOpacityTransferFunction->AddPoint (offset, val);
		ww = [[[propertyDictList objectAtIndex:i]objectForKey:@"WW"]floatValue];
		wl = [[[propertyDictList objectAtIndex:i]objectForKey:@"WL"]floatValue];	
		start = wl-ww/2;
		end = wl+ww/2;
		if(start>0)
			err=myOpacityTransferFunction->AddPoint (start+offset, val);			

		val = [[[propertyDictList objectAtIndex:i] objectForKey:@"Opacity"] floatValue];
		if(end<2047)
			err=myOpacityTransferFunction->AddPoint (offset+end, val);

		err=myOpacityTransferFunction->AddPoint (offset+2047.0, val);
	}
	[vrViewer setWLWW: wl :ww];
	
}
- (void)applyCLUT
{
 	myColorTransferFunction->RemoveAllPoints ();
	unsigned int i,j;
	float x,r,g,b;
	float offset,ww,wl;
	NSArray	*rArray,*gArray,*bArray,*xArray;

	
	for(i=0;i<[propertyDictList count];i++)
	{
		offset = [[[propertyDictList objectAtIndex:i] objectForKey:@"RangeFrom"] floatValue] + osirixOffset;
		rArray = [[propertyDictList objectAtIndex:i] objectForKey:@"RedTable"];
		gArray = [[propertyDictList objectAtIndex:i] objectForKey:@"GreenTable"];		
		bArray = [[propertyDictList objectAtIndex:i] objectForKey:@"BlueTable"];
		xArray = [[propertyDictList objectAtIndex:i] objectForKey:@"xTableForColorPoints"];
		ww = [[[propertyDictList objectAtIndex: i] objectForKey:@"WW"] floatValue];
		wl = [[[propertyDictList objectAtIndex: i] objectForKey:@"WL"] floatValue];	
		if(wl-ww/2>0)
			myColorTransferFunction->AddRGBPoint(offset,0,0,0);
		if(wl+ww/2<2047)
			myColorTransferFunction->AddRGBPoint(offset+2047,1.0,1.0,1.0);
		for(j=0;j<[xArray count];j++)
		{
			r = [[rArray objectAtIndex: j] floatValue];
			g = [[gArray objectAtIndex: j] floatValue];
			b = [[bArray objectAtIndex: j] floatValue];
			x = [[xArray objectAtIndex: j] floatValue];
			x = wl-ww/2+x*ww/2048;
			if(x<0)
				x=0;
			else if(x>2047)
				x=2047;
			x += offset;
			myColorTransferFunction->AddRGBPoint(x,r,g,b);
		}
	}
 	[vrViewer setWLWW: wholeVolumeWL :wholeVolumeWW];
}
- (IBAction)selectASegment:(id)sender
{
	unsigned int row = [segmentList selectedRow];
	float opacity,ww,wl;
	if(row>=0&&row<[propertyDictList count])
	{
		opacity = [[[propertyDictList objectAtIndex: row] objectForKey:@"Opacity"] floatValue];
		[opacitySlider setFloatValue: opacity];
		ww = [[[propertyDictList objectAtIndex: row] objectForKey:@"WW"] floatValue];
		wl = [[[propertyDictList objectAtIndex: row] objectForKey:@"WL"] floatValue];
		[wwSlider setFloatValue: ww];
		[wlSlider setFloatValue: wl];
		[self restoreCLUTFromPropertyList:row];
		[colorViewer display];
		
	}
	
}
- (void)restoreCLUTFromPropertyList:(int)index
{
	float x;
	NSArray	*rArray,*gArray,*bArray,*xArray;
	rArray = [[propertyDictList objectAtIndex:index] objectForKey:@"RedTable"];
	gArray = [[propertyDictList objectAtIndex:index] objectForKey:@"GreenTable"];		
	bArray = [[propertyDictList objectAtIndex:index] objectForKey:@"BlueTable"];
	xArray = [[propertyDictList objectAtIndex:index] objectForKey:@"xTableForColorPoints"];
	[clutViewPoints removeAllObjects] ;
	[clutViewColors removeAllObjects] ;
	unsigned int i;
	for(i=0;i<[xArray count];i++)
	{
		NSMutableArray* array=[NSMutableArray arrayWithCapacity:0];
		[array addObject:[rArray objectAtIndex: i]];
		[array addObject:[gArray objectAtIndex: i]];
		[array addObject:[bArray objectAtIndex: i]];
		[clutViewColors addObject: array];
		x = [[xArray objectAtIndex: i] floatValue];
		NSNumber *cur=[NSNumber numberWithInt:(int)(255*x/2048)];
		[clutViewPoints addObject: cur];
	}
}
- (void)applyCLUTToPropertyList:(int)index
{
	float x;
	NSMutableArray	*rArray,*gArray,*bArray,*xArray;
	rArray = [[propertyDictList objectAtIndex:index] objectForKey:@"RedTable"];
	gArray = [[propertyDictList objectAtIndex:index] objectForKey:@"GreenTable"];		
	bArray = [[propertyDictList objectAtIndex:index] objectForKey:@"BlueTable"];
	xArray = [[propertyDictList objectAtIndex:index] objectForKey:@"xTableForColorPoints"];
	[rArray removeAllObjects];
	[gArray removeAllObjects];
	[bArray removeAllObjects];
	[xArray removeAllObjects];
//	[clutViewPoints removeAllObjects] ;
//	[clutViewColors removeAllObjects] ;
	unsigned int i;
	for(i=0;i<[clutViewPoints count];i++)
	{
		NSArray* array=[clutViewColors objectAtIndex: i];
		
		[rArray addObject:[array objectAtIndex:0 ]];
		[gArray addObject:[array objectAtIndex:1 ]];
		[bArray addObject:[array objectAtIndex:2 ]];
		x = [[clutViewPoints objectAtIndex: i] floatValue];
		NSNumber *cur=[NSNumber numberWithInt:(int)(2048*x/255 )];
		[xArray addObject: cur];
	}
}

- (float) minimumValue
{
	return 0;
}
- (float) maximumValue
{
	return 1000;
}
- (ViewerController*) viewer2D
{
	return originalViewController;
}
- (IBAction)changeVRDirection:(id)sender
{
	int tag=[sender tag];
	if(tag==0)
		[vrViewer coView:sender];
	else if(tag==4)
		[vrViewer saView: sender];
	else if(tag==5)
		[vrViewer saViewOpposite:sender];
	else if(tag==3)
		[vrViewer axView:sender];
}
- (void) windowDidBecomeMain:(NSNotification *)aNotification
{
	[self reHideToolbar];
}

- (void)reHideToolbar
{
	unsigned int i;
	for( i = 0; i < [toolbarList count]; i++)
	{
		[[toolbarList objectAtIndex: i] setVisible: NO];
		
	}
	
}
@end
