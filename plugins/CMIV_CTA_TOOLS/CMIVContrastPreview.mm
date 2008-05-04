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
#import "CMIVContrastPreview.h"
#import "CMIVSegmentCore.h"
#import "CMIV3DPoint.h"
@implementation CMIVContrastPreview

- (IBAction)chooseASeed:(id)sender
{
	[mprView setCurrentTool:tPlain];
	[resultView setCurrentTool:tWL];
	
}

- (IBAction)chooseATool:(id)sender
{
		int tag=[sender tag];
	if(tag!=4&& tag>=0)
	{
		[mprView setCurrentTool:tag];
		[resultView setCurrentTool:tag];
		[vrView setCurrentTool: tag];
		
	}
	else if(tag==4)
	{
		[mprView setCurrentTool:tPlain];
		[resultView setCurrentTool:tWL];
		[vrView setCurrentTool: tag];
	}
}

- (IBAction)setBrushWidth:(id)sender
{
	[brushWidthText setIntValue: [sender intValue]];
	
	[[NSUserDefaults standardUserDefaults] setFloat:[sender floatValue] forKey:@"ROIRegionThickness"];
	
}
- (IBAction)setBrushMode:(id)sender
{
	[mprView setEraserFlag: [sender selectedSegment]];
}

- (IBAction)continueTheLoop:(id)sender
{
	int seedNumber=0;
	id waitWindow = [originalViewController startWaitWindow:@"processing"];	
	NSLog( @"step 3.1 start update");
	seedNumber=[self plantNewSeeds];
	if(seedNumber)
	{
		
		
		CMIVSegmentCore *segmentCoreFunc = [[CMIVSegmentCore alloc] init];
		[segmentCoreFunc setImageWidth:imageWidth Height: imageHeight Amount: imageAmount];
		if(segmentNeighborhood==6)
			[segmentCoreFunc startShortestPathSearchAsFloatWith6Neighborhood:inputData Out:outputData  Direction: directionData];
		else 
			[segmentCoreFunc optimizedContinueLoop:inputData Out:outputData :colorData Direction: directionData];
		
		int size=imageWidth*imageHeight*imageAmount*sizeof(unsigned char);
		memset(colorData,0,size);
		[segmentCoreFunc caculateColorMapFromPointerMap:colorData:directionData]; 
		[segmentCoreFunc release];
		
	}
	[self updateResultView];
	[self updateVRView];
	[originalViewController endWaitWindow: waitWindow];	
	NSLog( @"step 3.1 finish update");
	

		
}

- (IBAction)finishAdjustion:(id)sender
{
	NSArray				*pixList = [originalViewController pixList];
	unsigned int i;
	DCMPix* curPix;	
	curPix = [pixList objectAtIndex: 0];
	NSMutableArray      *roiList;
	short unsigned int* im;
	for(i=0;i<[pixList count];i++)
	{
		roiList= [[originalViewController roiList] objectAtIndex: i];
		im=newSeedsBuffer+imageSize*i;
		[self creatROIListFromSlices: roiList  :imageWidth :imageHeight :im :xSpacing :ySpacing :  [curPix originX]: [curPix originY]];
		
		
	}
	roiList= [originalViewController roiList] ;
	[self checkRootSeeds:roiList];
	if(isInWizardMode)
		[self checkRootSeeds:roiList];
	[[originalViewController window] setTitle:@"Seeds Planted"];
	[self onCancel: sender];
	
}
- (IBAction)pageMPRView:(id)sender
{
	float locate,step;
	locate=[sender floatValue];
	locate=round([sender floatValue]/minSpacing);
	step=locate-lastMPRViewTranslate;
	step*=minSpacing;
	lastMPRViewTranslate = locate;
	mprViewUserTransform->Translate(0,0,step);
	if(step!=0)
		[self updateMPRView];
	
	
}
- (IBAction)pageResultView:(id)sender
{
	int index= [resultPageSlider intValue];
	if(index!=lastResultSliderPos)
	{
		[self updateResultView];
		lastResultSliderPos=index;
		[self synchronizeMPRView:[resultPageSlider intValue]];
	}
	
}
- (void) updateMPRView
{
	vtkImageData	*tempIm,*tempROIIm;
	int				imExtent[ 6];
	
	if(interpolationMode)
		mprViewSlice->SetInterpolationModeToCubic();
	else
		mprViewSlice->SetInterpolationModeToNearestNeighbor();
	
	
	tempIm = mprViewSlice->GetOutput();
	tempIm->Update();
	tempIm->GetWholeExtent( imExtent);
	tempIm->GetSpacing( mprViewSpace);
	tempIm->GetOrigin( mprViewOrigin);	
	
	float *im = (float*) tempIm->GetScalarPointer();
	DCMPix*		mypix = [[DCMPix alloc] initwithdata:(float*) im :32 :imExtent[ 1]-imExtent[ 0]+1 :imExtent[ 3]-imExtent[ 2]+1 :mprViewSpace[0] :mprViewSpace[1] :mprViewOrigin[0] :mprViewOrigin[1] :mprViewOrigin[2]];
	[mypix copySUVfrom: firstPix];	
	
	//creat roi list
	double	 space[3], origin[3];
	tempROIIm = mprViewROISlice->GetOutput();
	tempROIIm->Update();
	tempROIIm->GetWholeExtent( imExtent);
	tempROIIm->GetSpacing( space);
	tempROIIm->GetOrigin( origin);	
	
	isRemoveROIBySelf=1;
	//to avoid 2.7.5fc3 put those ROIs into autorelease pool
	if(!IsVersion2_6)
	{
		unsigned i;
		ROI* tempROI;
		NSString* emptystr=[NSString stringWithString:@""];
		for(i=0;i<[[MPRROIList objectAtIndex: 0] count];i++)
		{
			tempROI=[[MPRROIList objectAtIndex: 0] objectAtIndex: i];
			[tempROI setComments:emptystr];
			//[tempROI setPix:nil];
		}
	}
	
	[[MPRROIList objectAtIndex: 0] removeAllObjects];
	isRemoveROIBySelf=0;
	short unsigned int *imROI = (short unsigned int*) tempROIIm->GetScalarPointer();	
	[self creatROIListFromSlices:[MPRROIList objectAtIndex: 0] :imExtent[ 1]-imExtent[ 0]+1  :imExtent[ 3]-imExtent[ 2]+1 :imROI : space[0]:space[1]:origin[0]:origin[1]];

	
	[MPRPixList removeAllObjects];
	[MPRPixList addObject: mypix];
	[mypix release];
	//to cheat DCMView not reset current roi;
	
	[mprView setIndex: 0 ];
	
	if([crossShowButton state]== NSOnState)
	{
		float crossX,crossY;
		crossX=-mprViewOrigin[0]/mprViewSpace[0];
		crossY=mprViewOrigin[1]/mprViewSpace[1];
		if(crossX<0)
			crossX=0;
		else if(crossX>imExtent[ 1]-imExtent[ 0])
			crossX=imExtent[ 1]-imExtent[ 0];
		if(crossY>0)
			crossY=0;
		else if(crossY<-(imExtent[ 3]-imExtent[ 2] ))
			crossY=-(imExtent[ 3]-imExtent[ 2] );
		[mprView setCrossCoordinates:crossX:crossY :YES];
	}
	
}
- (void) updateResultView
{
	int index= [resultPageSlider intValue];
	
	[self resultViewUpdateROI:index];
	
	DCMPix	*curPix = [[originalViewController pixList] objectAtIndex: index];
	
	DCMPix	*copyPix = [curPix copy];
	if(copyPix)
	{
		[resultPixList removeAllObjects];
		[resultPixList addObject: copyPix];
		[copyPix release];
	}
	
	[[resultPixList lastObject] setfImage: (float*) (outputData + imageSize * index)];
	[resultFileList removeAllObjects];
	[resultFileList addObject: [MPRFileList objectAtIndex: index]];
	[resultView setIndex: 0];

	
}
- (void) resetMPRSliders
{
	[mprXRotateSlider setIntValue:0];
	[mprYRotateSlider setIntValue:0];
	
	lastMPRViewXAngle=0;
	lastMPRViewYAngle=0;
	[oViewRotateXText setFloatValue: 0];
	[oViewRotateYText setFloatValue: 0];
	[self updateMPRPageSlider];		
}

- (void) updateMPRPageSlider
{
	float point[8][3];
	point[0][0] = vtkOriginalX;
	point[0][1] = vtkOriginalY;
	point[0][2] = vtkOriginalZ;
	
	point[1][0] = vtkOriginalX+imageWidth*xSpacing;
	point[1][1] = vtkOriginalY+imageHeight*ySpacing;
	point[1][2] = vtkOriginalZ;	
	
	point[2][0] = vtkOriginalX+imageWidth*xSpacing;
	point[2][1] = vtkOriginalY;
	point[2][2] = vtkOriginalZ;
	
	point[3][0] = vtkOriginalX;
	point[3][1] = vtkOriginalY+imageHeight*ySpacing;
	point[3][2] = vtkOriginalZ;
	
	point[4][0] = vtkOriginalX;
	point[4][1] = vtkOriginalY;
	point[4][2] = vtkOriginalZ+imageAmount*zSpacing;
	
	point[5][0] = vtkOriginalX+imageWidth*xSpacing;
	point[5][1] = vtkOriginalY;
	point[5][2] = vtkOriginalZ+imageAmount*zSpacing;
	
	point[6][0] = vtkOriginalX;
	point[6][1] = vtkOriginalY+imageHeight*ySpacing;
	point[6][2] = vtkOriginalZ+imageAmount*zSpacing;
	
	point[7][0] = vtkOriginalX+imageWidth*xSpacing;
	point[7][1] = vtkOriginalY+imageHeight*ySpacing;
	point[7][2] = vtkOriginalZ+imageAmount*zSpacing;
	
	float min[3],max[3];
	float pointout[3];
	int i,j;
	
	for(j=0;j<3;j++)
	{
		inverseTransform->TransformPoint(point[0],pointout);
		min[j]=max[j]=pointout[j];
		
		for(i=1;i<8;i++)
		{
			inverseTransform->TransformPoint(point[i],pointout);
			if(pointout[j]<min[j])
				min[j]=pointout[j];
			if(pointout[j]>max[j])
				max[j]=pointout[j];
			
		}
	}	
	
	
	[mprPageSlider setMaxValue: max[2]];
	[mprPageSlider setMinValue: min[2]];
	[mprPageSlider setIntValue:0];
	
	lastMPRViewTranslate=0;

	
}

- (IBAction)onCancel:(id)sender
{
	int tag=[sender tag];
	[window setHorizontalSlider:nil];
	[window setVerticalSlider:nil];
	[window setTranlateSlider:nil];
	[resultView setTranlateSlider:nil];
	if([[tab2D3DView tabViewItems] count]>1) 
	{
		NSWindow* superwindow=[vrView window];
		NSNotification* note=[NSNotification notificationWithName:@"cheat" object:superwindow];
		[vrView windowWillClose:note];
	}
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[window setReleasedWhenClosed:YES];
	[window close];
    [NSApp endSheet:window returnCode:[sender tag]];
	[[NSUserDefaults standardUserDefaults] setBool:roiShowNameOnly forKey: @"ROITEXTNAMEONLY"];
	[[NSUserDefaults standardUserDefaults] setBool:roiShowTextOnlyWhenSeleted forKey:@"ROITEXTIFSELECTED"];	
	if(!isInWizardMode)
	{
		if(outputData)
			free(outputData);
		if(colorData)
			free(colorData);
		if(newSeedsBuffer)
			free(newSeedsBuffer);
		[choosenSeedsArray release];
		[showSeedsArray release];

	}

		
	unsigned int i;
	
	for(i=0;i<[MPRROIList count];i++)
		[[MPRROIList objectAtIndex: i] removeAllObjects];

	[newSeedsROIList removeAllObjects ];
	
	if(reader)
	{
		reader->Delete();
		roiReader->Delete();
		mprViewSlice->Delete();
		mprViewBasicTransform->Delete();
		mprViewUserTransform->Delete();
		mprViewROISlice->Delete();
		///////////////

		
	}		
	
	
	
	for(i=0;i<[resultROIList count];i++)
	{
		[[resultROIList objectAtIndex: i] removeAllObjects];
	}
	[resultROIList removeAllObjects];
	[resultPixList removeAllObjects];
	[resultFileList removeAllObjects];
	[resultPrivateROIList removeAllObjects];
	[resultPrivateROIList release];
	for(i=0;i<[MPRROIList count];i++)
	{
		[[MPRROIList objectAtIndex: i] removeAllObjects];
	}
	[MPRROIList removeAllObjects];
	
	/*

	for( i = 0; i < [toolbarList count]; i++)
	{
		[[toolbarList objectAtIndex: i] setVisible: YES];
		
	}
	[toolbarList removeAllObjects];

	*/
	if(tag!=2)
	{
		for(i=0;i<[centerlinesList count];i++)
			[[centerlinesList objectAtIndex:i] removeAllObjects];
		[centerlinesList removeAllObjects];
		[centerlinesList release];
		[centerlinesNameList removeAllObjects];
		[centerlinesNameList release];
		[parent exitCurrentDialog];
	}
}
- (void)showPanelAsWizard:(ViewerController *) vc:(	CMIV_CTA_TOOLS*) owner
{
	float *indata,*outdata;
	unsigned char* colordata,*directdata;
	NSData	*newData;
	parent=owner;
	isInWizardMode=YES;
	choosenSeedsArray=[[parent dataOfWizard] objectForKey:@"SeedList"];
	showSeedsArray=[[parent dataOfWizard] objectForKey:@"ShownColorList"];
	newSeedsROIList=[[parent dataOfWizard] objectForKey:@"ROIList"];
	newData=[[parent dataOfWizard] objectForKey:@"SeedData"];	
	newSeedsBuffer = (unsigned short int*)[newData bytes];

	newData=[[parent dataOfWizard] objectForKey:@"InputData"];
	indata =(float *)[newData bytes];
	newData=[[parent dataOfWizard] objectForKey:@"OutputData"];
	outdata = (float *)[newData bytes];
	newData=[[parent dataOfWizard] objectForKey:@"DirectionData"];
	directdata=(unsigned char*)[newData bytes];
	newData=[[parent dataOfWizard] objectForKey:@"ColorData"];
	colordata=(unsigned char*)[newData bytes];
	NSNumber* neighborNumber=[[parent dataOfWizard] objectForKey:@"CFCTNeighborhood"];
	segmentNeighborhood = 26;
	if(neighborNumber)
		segmentNeighborhood=[neighborNumber intValue];
	

	[self showPreviewPanel:vc :indata :outdata :colordata :directdata];
	
}
- (int) showPreviewPanel:(ViewerController *) vc:(float*)inData:(float*)outData:(unsigned char*)colData:(unsigned char*)direData
{
	int err=0;
	originalViewController=vc;	
	inputData = inData;
	outputData = outData;
	colorData = colData;
	directionData = direData;
	
	[NSBundle loadNibNamed:@"SegPreview" owner:self];
	NSRect screenrect=[[[originalViewController window] screen] visibleFrame];
	screenrect.size.height -= 100;
	if( screenrect.size.height > 1100) screenrect.size.height = 1100;
	if( screenrect.size.width > 1900) screenrect.size.width = 1900;

	[window setFrame:screenrect display:YES ];	MPRFileList =[originalViewController fileList ];
	DCMPix* curPix;	
	curPix = [[originalViewController pixList] objectAtIndex: 0];
	imageWidth = [curPix pwidth];
	imageHeight = [curPix pheight];
	imageAmount = [[originalViewController pixList] count];	
	imageSize = imageWidth*imageHeight;
	minValueInCurSeries = [curPix minValueOfSeries];
	maxValueInCurSeries = [curPix maxValueOfSeries];
	
	err=[self initViews];
	interpolationMode=1;
	
	if(err!=1)
	{
	

		[self updateMPRView];
		[self resetMPRSliders];
		[self setBrushWidth: brushWidthSlider];
		if(!isInWizardMode)
			[wizardTips setHidden: YES];
		[NSApp beginSheet: window modalForWindow:[originalViewController window] modalDelegate:self didEndSelector:nil contextInfo:nil];	
		id waitWindow = [originalViewController startWaitWindow:@"processing"];	
		//[window setWindowController: self];


				//hide other segments
		if(err!=2)
		{
			osirixOffset=[vrView offset] ;
			osirixValueFactor=[vrView valueFactor] ;
			renderOfVRView = [vrView renderer];
			//volumeCollectionOfVRView = renderOfVRView->GetVolumes();
			volumeOfVRView = (vtkVolume * )[vrView volume];//volumeOfVRView = (vtkVolume * )volumeCollectionOfVRView->GetItemAsObject (0);
			volumeMapper=(vtkVolumeMapper *) volumeOfVRView->GetMapper() ;
			volumeImageData=(vtkImageData *)volumeMapper->GetInput();
			volumeDataOfVR=(unsigned short*)volumeImageData->GetScalarPointer();
			[self updateVRView];
		}
		/*
		 NSArray				*winList = [NSApp windows];

		toolbarList = [[NSMutableArray alloc] initWithCapacity: 0];
		unsigned int i;
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
		 */
		[window setHorizontalSlider:mprYRotateSlider];
		[window setVerticalSlider:mprXRotateSlider];
		[window setTranlateSlider:mprPageSlider];
		[resultView setTranlateSlider:resultPageSlider];
		roiShowTextOnlyWhenSeleted=[[NSUserDefaults standardUserDefaults] boolForKey:@"ROITEXTIFSELECTED"];
		roiShowNameOnly=[[NSUserDefaults standardUserDefaults] boolForKey: @"ROITEXTNAMEONLY"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"ROITEXTNAMEONLY"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ROITEXTIFSELECTED"];
		if(!segmentNeighborhood)
			segmentNeighborhood=26;
		
		NSNotificationCenter *nc;
		nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(defaultToolModified:) name:@"defaultToolModified" object:nil];
		[nc addObserver: self selector: @selector(roiChanged:) name:@"roiChange" object:nil];
		[nc addObserver: self selector: @selector(roiAdded:) name:@"addROI" object:nil];
		[nc addObserver: self selector: @selector(roiRemoved:) name:@"removeROI" object:nil];
		[nc	addObserver: self selector: @selector(changeWLWW:) name: @"changeWLWW" object: nil];	
		[nc	addObserver: self selector: @selector(crossMove:) name: @"crossMove" object: nil];	
		[nc	addObserver: self selector: @selector(Display3DPoint:) name: @"Display3DPoint" object: nil];
		[nc addObserver: self selector: @selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
		[seedList setDataSource: self];
		
		[originalViewController endWaitWindow: waitWindow];	
	}
	
	return err;
	
}

- (int) initViews
{
	DCMPix* curPix;	
	
	
	long                size;
	NSArray				*pixList = [originalViewController pixList];

	size = sizeof(short unsigned int) * imageWidth * imageHeight * imageAmount;
	if( !newSeedsBuffer)
	{
		newSeedsBuffer = (unsigned short int*) malloc( size);
		memset(newSeedsBuffer, 0, size);
	}
	if( !newSeedsBuffer)
	{
		NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM to build seed buffer", nil), NSLocalizedString(@"OK", nil), nil, nil);
		return 1;	
	}
	
	if(!newSeedsROIList)
	{
		newSeedsROIList = [[NSMutableArray alloc] initWithCapacity:0];
		uniIndex = 0;
	}
	else
		uniIndex = [newSeedsROIList count];
	firstPix = [pixList objectAtIndex: 0];
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
	centerX=0;
	centerY=0;
	centerZ=0;
	
	xSpacing=[curPix pixelSpacingX];
	ySpacing=[curPix pixelSpacingY];
	zSpacing=sliceThickness;
	minSpacing=xSpacing;
	if(minSpacing>ySpacing)minSpacing=ySpacing;
	if(minSpacing>zSpacing)minSpacing=zSpacing;
	minSpacing/=2;
	
	mprViewRotateAngleX=0;
	mprViewRotateAngleY=0;
	centerIsLocked=0;
	
	reader = vtkImageImport::New();
	reader->SetWholeExtent(0, imageWidth-1, 0, imageHeight-1, 0, imageAmount-1);
	reader->SetDataSpacing(xSpacing,ySpacing,zSpacing);
	reader->SetDataOrigin( vtkOriginalX,vtkOriginalY,vtkOriginalZ );
	reader->SetDataExtentToWholeExtent();
	reader->SetDataScalarTypeToFloat();
	reader->SetImportVoidPointer(inputData);
	
	roiReader = vtkImageImport::New();
	roiReader->SetWholeExtent(0, imageWidth-1, 0, imageHeight-1, 0, imageAmount-1);
	roiReader->SetDataSpacing(xSpacing,ySpacing,zSpacing);
	roiReader->SetDataOrigin( vtkOriginalX,vtkOriginalY,vtkOriginalZ );
	roiReader->SetDataExtentToWholeExtent();
	roiReader->SetDataScalarTypeToUnsignedShort();
	roiReader->SetImportVoidPointer(newSeedsBuffer);
	
	mprViewBasicTransform = vtkTransform::New();
	mprViewBasicTransform->Translate( vtkOriginalX+xSpacing*imageWidth/2, vtkOriginalY+ySpacing*imageHeight/2, vtkOriginalZ + sliceThickness*imageAmount/2 );
	
	mprViewUserTransform = vtkTransform::New();
	mprViewUserTransform->Identity ();
	mprViewUserTransform->SetInput(mprViewBasicTransform) ;
	mprViewUserTransform->RotateX(-90);
	
	inverseTransform = (vtkTransform*)mprViewUserTransform->GetLinearInverse();
	
	
	mprViewSlice = vtkImageReslice::New();
	mprViewSlice->SetAutoCropOutput( true);
	mprViewSlice->SetInformationInput( reader->GetOutput());
	mprViewSlice->SetInput( reader->GetOutput());
	mprViewSlice->SetOptimization( true);
	mprViewSlice->SetResliceTransform( mprViewUserTransform);
	mprViewSlice->SetResliceAxesOrigin( 0, 0, 0);
	mprViewSlice->SetInterpolationModeToCubic();
	mprViewSlice->SetOutputDimensionality( 2);
	mprViewSlice->SetBackgroundLevel( -1024);
	
	mprViewROISlice= vtkImageReslice::New();
	mprViewROISlice->SetAutoCropOutput( true);
	mprViewROISlice->SetInformationInput( roiReader->GetOutput());
	mprViewROISlice->SetInput( roiReader->GetOutput());
	mprViewROISlice->SetOptimization( true);
	mprViewROISlice->SetResliceTransform( mprViewUserTransform);
	mprViewROISlice->SetResliceAxesOrigin( 0, 0, 0);
	mprViewROISlice->SetInterpolationModeToNearestNeighbor();
	mprViewROISlice->SetOutputDimensionality( 2);
	mprViewROISlice->SetBackgroundLevel( -1024);	
	
	vtkImageData	*tempIm;
	int				imExtent[ 6];
	double		space[ 3], origin[ 3];
	tempIm = mprViewSlice->GetOutput();
	tempIm->Update();
	tempIm->GetWholeExtent( imExtent);
	tempIm->GetSpacing( space);
	tempIm->GetOrigin( origin);	
	
	float *im = (float*) tempIm->GetScalarPointer();
	DCMPix*		mypix = [[DCMPix alloc] initwithdata:(float*) im :32 :imExtent[ 1]-imExtent[ 0]+1 :imExtent[ 3]-imExtent[ 2]+1 :space[0] :space[1] :origin[0] :origin[1] :origin[2]];
	[mypix copySUVfrom: curPix];	
	
	MPRPixList = [[NSMutableArray alloc] initWithCapacity:0];
	[MPRPixList addObject: mypix];
	[mypix release];	

	MPRROIList = [[NSMutableArray alloc] initWithCapacity:0];
	[MPRROIList addObject:[NSMutableArray arrayWithCapacity:0]];
	[MPRROIList addObject:[NSMutableArray arrayWithCapacity:0]];
	[mprView setDCM:MPRPixList :MPRFileList :MPRROIList :0 :'i' :YES];
	NSString *viewName = [NSString stringWithString:@"Original"];
	[mprView setStringID: viewName];
	[mprView setMPRAngle: 0.0];
	[mprView setCross: 0 :0 :YES];
	
	[mprView setIndexWithReset: imageAmount/2 :YES];
	[mprView setOrigin: NSMakePoint(0,0)];
	[mprView setCurrentTool:tPlain];
	[mprView  scaleToFit];
	float scale=[mprView scaleValue];
	[mprView setScaleValue:scale*0.9];
	
	float iwl, iww;
	iww = [[originalViewController imageView] curWW] ;
	iwl = [[originalViewController imageView] curWL] ;
	[mprView setWLWW:iwl :iww];
	
	int i;
	for( i = 0; i < imageAmount; i++)
	{
		[MPRROIList addObject:[NSMutableArray arrayWithCapacity:0]];
	}
	
	
	


	
	//create result data
	// CREATE A NEW SERIES TO CONTAIN THIS NEW SERIES
	resultPixList = [NSMutableArray arrayWithCapacity: 0];
	resultROIList = [[NSMutableArray alloc] initWithCapacity: 0];
	resultFileList = [NSMutableArray arrayWithCapacity: 0];
	resultViewROIMode=1;
	[resultROIList addObject:[NSMutableArray arrayWithCapacity:0]];
	
	i=imageAmount/2;

	curPix = [pixList objectAtIndex: i];
	
	DCMPix	*copyPix = [curPix copy];
	
	[resultPixList addObject: copyPix];
	[copyPix release];
	
	[[resultPixList lastObject] setfImage: (float*) (outputData + imageSize * i)];
	[resultFileList addObject: [MPRFileList objectAtIndex: i]];

	
	[resultPageSlider setMaxValue: imageAmount-1];
	[resultPageSlider setIntValue:imageAmount/2];
	lastResultSliderPos=imageAmount/2;

	[resultView setDCM:resultPixList :resultFileList :resultROIList :0 :'i' :YES];
	[resultView setIndexWithReset: 0 :YES];
	viewName = [NSString stringWithString:@"Original"];
	[resultView setStringID: viewName];

	[resultView setOrigin: NSMakePoint(0,0)];
	[resultView setCurrentTool:tWL];

	
	

	[vrView setRotate: NO];
	int err=[vrView setPixSource:pixList :inputData];
	NSString	*str =  @"/" ;
	
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: str];
	
	[vrView set3DStateDictionary:dict];
	
	if(err)
		[tab2D3DView removeTabViewItem:[tab2D3DView tabViewItemAtIndex:1]];
	else
	{
		[vrView setRotate: NO];
		[vrView setRotate: NO];
		[vrView setMode: 1];
		NSDictionary		*aOpacity;
		NSArray				*array;

		
		aOpacity = [[[NSUserDefaults standardUserDefaults] dictionaryForKey: @"OPACITY"] objectForKey: NSLocalizedString(@"Logarithmic Inverse Table", nil)];
		if( aOpacity)
		{
			array = [aOpacity objectForKey:@"Points"];
			
			[vrView setOpacity:array];
		}
	}

	

	
	ROI* testROI=[[ROI alloc] initWithType: tOval :xSpacing :ySpacing : NSMakePoint( 0, 0)];
	if([testROI respondsToSelector:@selector(color)])
		IsVersion2_6=YES;
	else
		IsVersion2_6=NO;
	[testROI release];
	resultPrivateROIList=[[NSMutableArray alloc] initWithCapacity: 0];
	unsigned ii;
	for(ii=0;ii<[choosenSeedsArray count];ii++)
	{
		[self creatNewResultROI:ii];
	}
	[self resultViewUpdateROI:imageAmount/2 ];	
	[resultView  scaleToFit];
	if(err)
		return 2;
	else
		return 0;
}
- (void)creatNewResultROI:(int)index
{
	ROI* tempROI;
	RGBColor	color;
	NSString *roiName;
	unsigned char *textureBuffer=(unsigned char *) malloc(sizeof(unsigned char)*imageSize);
	*textureBuffer=0xff;
	*(textureBuffer+imageSize-1)=0xff;
	
	tempROI = [choosenSeedsArray objectAtIndex:index];
	roiName = [tempROI name];
	
	if(IsVersion2_6)
		color= [tempROI color];
	else
		color= [tempROI rgbcolor];
	DCMPix* curPix;	
	curPix = [resultPixList objectAtIndex: 0];
	
	ROI *newROI=[[ROI alloc] initWithTexture:textureBuffer textWidth:imageWidth textHeight:imageHeight textName:roiName positionX:0 positionY:0 spacingX:[curPix pixelSpacingX] spacingY:[curPix pixelSpacingY]  imageOrigin:NSMakePoint( [curPix originX], [curPix originY])];
	
//	[newROI reduceTextureIfPossible];

	
	
	[newROI setColor:color];
	
	[resultPrivateROIList insertObject:newROI atIndex:index];
	[newROI release];
	
	free(textureBuffer);
	
}

- (void)resultViewUpdateROI:(int)index
{
	if(index>=imageAmount)
		return;
	if(resultViewROIMode==1)
	{
		
		
		ROI* tempROI;
		unsigned int i;
		int colorIndex,j;
		
		float thresholdValue = [thresholdSlider floatValue];
		thresholdValue = round ( thresholdValue );
		[[resultROIList objectAtIndex: 0] removeAllObjects];
		
		unsigned char *textureBuffer;
		
		for(i=0;i< [showSeedsArray count];i++)
		{
			colorIndex = [[showSeedsArray objectAtIndex:i] intValue];
			tempROI = [resultPrivateROIList objectAtIndex: colorIndex-1];
			textureBuffer = [tempROI textureBuffer];
			memset(textureBuffer,0,sizeof(unsigned char)*imageSize);			
			for(j=0;j<imageSize;j++)
				if(((*(colorData+index*imageSize+j))&0x3f)== colorIndex&&(*(outputData+index*imageSize+j))>=thresholdValue)
					*(textureBuffer+j) = 0xff;
			*textureBuffer=0xff;
			*(textureBuffer+imageSize-1)=0xff;
			[[resultROIList objectAtIndex: 0] addObject: tempROI ];
			
			
		}	
	}	
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
   if([seedList isEqual:tableView])
   {
	   return [choosenSeedsArray count];
   }
	return 0;
	
}

- (id)tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(int)row
{
	
	if([seedList isEqual:tableView])
   {
	   if( [[tableColumn identifier] isEqualToString:@"Name"])
	   {
		   return [[choosenSeedsArray objectAtIndex:row] name];
	   }
	   if( [[tableColumn identifier] isEqualToString:@"IfExport"])
	   {
		   unsigned int i;
		   int colorIndex;
		   for(i=0;i< [showSeedsArray count];i++)
		   {
			  colorIndex = [[showSeedsArray objectAtIndex:i] intValue];
			  if(colorIndex-1==row)
				   return  [NSNumber numberWithBool:YES];
		   }
		   
		   return   [NSNumber numberWithBool:NO];
		   
		   
		   
	   }		
	   
   }
	
	
	return 0L;
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
	if([seedList isEqual:aTableView])
	{
		
		if( [[aTableColumn identifier] isEqualToString:@"IfExport"])
		{
			unsigned int i;
			int colorIndex;
			if( [anObject boolValue] == YES )
			{
				
				for(i=0;i< [showSeedsArray count];i++)
				{
					colorIndex = [[showSeedsArray objectAtIndex:i] intValue];
					if(colorIndex-1==rowIndex)
						return;
				}	
				[showSeedsArray addObject:[NSNumber numberWithInt:rowIndex+1]];
				[self updateResultView];
				[self updateVRView];

			}
			else
			{
				for(i=0;i< [showSeedsArray count];i++)
				{
					colorIndex =[[showSeedsArray objectAtIndex:i] intValue];
					if(colorIndex-1==rowIndex)
					{
						[showSeedsArray removeObjectAtIndex:i];
						[self updateResultView];
						[self updateVRView];

					}
				}	
			}
		}		
		
	}	
}
- (void)setSeedLists:(NSMutableArray *)choosenseedList: (NSMutableArray *)showSeedList
{
	choosenSeedsArray = choosenseedList;
	[choosenSeedsArray retain];
	showSeedsArray = showSeedList;
	[showSeedsArray retain];
}

- (int)plantNewSeeds
{
	long seedNumber=0;
	int x,y,z;
	int newSeedIndex;
	int colorIndex;
	unsigned char unsignedColorIndex;
	NSMutableArray		*seedIndexToColorIndexList=[[NSMutableArray alloc] initWithCapacity:0];
	unsigned int i,j;
	NSString *roiName;
	int itemp;
	int size=imageWidth*imageHeight*imageAmount*sizeof(unsigned char);
	memset(colorData,0,size);
	/*
	size=imageHeight*imageAmount;
	itemp=0;
	for(i=0;i<size;i++)
	{
		*(colorData+(itemp>>3))|=(0x01<<(itemp&0x07));
		itemp+=imageWidth;
	}
*/

	for(i=0;i<[newSeedsROIList count];i++)
	{
		colorIndex=0;
		roiName=[[newSeedsROIList objectAtIndex: i] name];
		for(j=0;j<[choosenSeedsArray count];j++)
		{
			if ([roiName isEqualToString:[[choosenSeedsArray objectAtIndex: j] name]]==YES)
				colorIndex=j+1;
			if ([roiName isEqualToString:@"barrier"]==YES)
				colorIndex=0;
			
		}
		[seedIndexToColorIndexList addObject:[NSNumber numberWithInt: colorIndex]];
	}
	for(z=0;z<imageAmount;z++)
		for(y=0;y<imageHeight;y++)
			for(x=0;x<imageWidth;x++)
			{
				itemp=z*imageSize+y*imageWidth+x;
				newSeedIndex=*(newSeedsBuffer+itemp);
				if(newSeedIndex)
				{
					newSeedIndex--;
					unsignedColorIndex=(unsigned char)[[seedIndexToColorIndexList objectAtIndex: newSeedIndex] intValue];
					if(unsignedColorIndex)
					{
						*(directionData+itemp) = unsignedColorIndex | 0x80;
						*(outputData+itemp) = *(inputData+itemp);
						int ii,jj,kk;
						itemp=itemp-imageSize-imageWidth-1;
						for(ii=0;ii<3;ii++)
						{
							for(jj=0;jj<3;jj++)
							{
								for(kk=0;kk<3;kk++)
								{
									if(x-1+kk<imageWidth && x-1+kk>=0 && y-1+jj<imageHeight && y-1+jj>=0 && z-1+ii<imageAmount && z-1+ii>=0)
									*(colorData+(itemp>>3))|=(0x01<<(itemp&0x07));
									itemp++;
								}
								itemp=itemp-3+imageWidth;
								
							}
							itemp=itemp-imageWidth-imageWidth-imageWidth+imageSize;
						}
						seedNumber++;
					}
				
				}
			}
	[seedIndexToColorIndexList release];

	return seedNumber;
}
- (void) roiAdded: (NSNotification*) note
{
	id sender =[note object];
	
	if( sender)
	{
		if ([sender isEqual:mprView])
		{
			
			ROI * roi = [[note userInfo] objectForKey:@"ROI"];
			if(roi)
			{
				
				RGBColor	color;
				NSString *roiName;
				ROI * tempROI;
				int seedIndex;
				seedIndex = [seedList selectedRow];
				tempROI = [choosenSeedsArray objectAtIndex: seedIndex];
				if([tempROI respondsToSelector:@selector(color)])
					color= [tempROI color];
				else
					color= [tempROI rgbcolor];
				roiName = [tempROI name];
				[roi setColor:color];
				[roi setName:roiName];
				if([roi type]==tPlain)
				{
					uniIndex++;
					NSString *indexstr=[NSString stringWithFormat:@"%d",uniIndex];
					[roi setComments:indexstr];	
					unsigned int i;
					for(i=0;i<[[MPRROIList objectAtIndex: 0] count];i++)
					{
						[[roi pix] retain];
					}
					DCMPix * curImage= [MPRPixList objectAtIndex:0];
					ROI* newROI=[[ROI alloc] initWithType: tROI :[curImage pixelSpacingX] :[curImage pixelSpacingY] : NSMakePoint( [curImage originX], [curImage originY])];
					[newROI setName:roiName];
					[newROI setComments:indexstr];	
					[newROI setColor:color];

					[newSeedsROIList addObject:newROI];
					
				}
				
			}
		}
	}
}
- (void) defaultToolModified: (NSNotification*) note
{
}
- (void) roiChanged: (NSNotification*) note
{
	id sender = [note object];

	if([[MPRROIList objectAtIndex: 0] containsObject: sender] )
	{
		ROI* roi=(ROI*)sender;
		int roitype =[roi type];
		if(roitype==tPlain)
		{
			short unsigned int marker=(short unsigned int)[[roi comments] intValue];
			int i,j;
			float point[3];
			unsigned char *texture=[roi textureBuffer];
			//if creating new roiList by self marker is 0
			if(texture&&marker)
			{
				int x,y,z;
				float curXSpacing,curYSpacing;
				float curOriginX,curOriginY;
				curXSpacing=[[roi pix] pixelSpacingX];
				curYSpacing=[[roi pix] pixelSpacingY];
				curOriginX = [roi textureUpLeftCornerX]*curXSpacing+[[roi pix] originX];
				curOriginY = [roi textureUpLeftCornerY]*curYSpacing+[[roi pix] originY];
				for(j=0;j<[roi textureHeight];j++)
					for(i=0;i<[roi textureWidth];i++)
					{
						point[0] = curOriginX + i * curXSpacing;
						point[1] = curOriginY + j * curYSpacing;
						point[2] = 0;
						mprViewUserTransform->TransformPoint(point,point);
						x=lround((point[0]-vtkOriginalX)/xSpacing);
						y=lround((point[1]-vtkOriginalY)/ySpacing);
						z=lround((point[2]-vtkOriginalZ)/zSpacing);
						if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
						{
							
							if(*(texture+j*[roi textureWidth]+i))
							{
								*(newSeedsBuffer+z*imageSize+y*imageWidth+x)=marker;
								//cover more area with spacing/2, hopeful to reduce holes in 3d plain
								if((i+1)<[roi textureWidth]&&*(texture+j*[roi textureWidth]+i+1))
								{
									point[0] = curOriginX + i * curXSpacing+curXSpacing/2;
									point[1] = curOriginY + j * curYSpacing;
									point[2] = 0;
									mprViewUserTransform->TransformPoint(point,point);
									x=lround((point[0]-vtkOriginalX)/xSpacing);
									y=lround((point[1]-vtkOriginalY)/ySpacing);
									z=lround((point[2]-vtkOriginalZ)/zSpacing);
									if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
										*(newSeedsBuffer+z*imageSize+y*imageWidth+x) = marker;
									
								}
								if((j+1)<[roi textureHeight]&&*(texture+(j+1)*[roi textureWidth]+i))
								{
									point[0] = curOriginX + i * curXSpacing;
									point[1] = curOriginY + j * curYSpacing+curYSpacing/2;
									point[2] = 0;
									mprViewUserTransform->TransformPoint(point,point);
									x=lround((point[0]-vtkOriginalX)/xSpacing);
									y=lround((point[1]-vtkOriginalY)/ySpacing);
									z=lround((point[2]-vtkOriginalZ)/zSpacing);
									if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
										*(newSeedsBuffer+z*imageSize+y*imageWidth+x) = marker;
									
								}
								if((i+1)<[roi textureWidth] && (j+1)<[roi textureHeight] && *(texture+(j+1)*[roi textureWidth]+i))
								{
									point[0] = curOriginX + i * curXSpacing+curXSpacing/2;
									point[1] = curOriginY + j * curYSpacing+curYSpacing/2;
									point[2] = 0;
									mprViewUserTransform->TransformPoint(point,point);
									x=lround((point[0]-vtkOriginalX)/xSpacing);
									y=lround((point[1]-vtkOriginalY)/ySpacing);
									z=lround((point[2]-vtkOriginalZ)/zSpacing);
									if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
										*(newSeedsBuffer+z*imageSize+y*imageWidth+x) = marker;
									
								}
								if((i-1)>0&&(j+1)<[roi textureHeight]&&*(texture+(j+1)*[roi textureWidth]+i))
								{
									point[0] = curOriginX + i * curXSpacing-curXSpacing/2;
									point[1] = curOriginY + j * curYSpacing+curYSpacing/2;
									point[2] = 0;
									mprViewUserTransform->TransformPoint(point,point);
									x=lround((point[0]-vtkOriginalX)/xSpacing);
									y=lround((point[1]-vtkOriginalY)/ySpacing);
									z=lround((point[2]-vtkOriginalZ)/zSpacing);
									if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
										*(newSeedsBuffer+z*imageSize+y*imageWidth+x) = marker;
									
								}
							}
							else if(*(newSeedsBuffer+z*imageSize+y*imageWidth+x)==marker)
								*(newSeedsBuffer+z*imageSize+y*imageWidth+x)=0;
							
							
						}
					}
			}
		}
	}
		
}

- (void) roiRemoved: (NSNotification*) note
{
	id sender = [note object];
	
	if(sender)
	{
		if ([sender isKindOfClass:[ROI class]])
		{
			ROI* roi=(ROI*)sender;
			if([roi type]==tPlain)
			{
				if(!isRemoveROIBySelf)
				{
					
					NSString * commentstr=[sender comments];
					if([commentstr length]==0)
						return;
					short unsigned int marker=(short unsigned int)[commentstr intValue];
					if(marker&&marker<=[newSeedsROIList count])
					{
						[newSeedsROIList removeObjectAtIndex: marker-1 ];
						unsigned int i;
						for(i = 0;i<[[MPRROIList objectAtIndex: 0] count];i++)
						{ 
							commentstr=[[[MPRROIList objectAtIndex: 0] objectAtIndex: i] comments];
							short unsigned int tempmarker=(short unsigned int)[commentstr intValue];
							if(tempmarker>marker)
								[[[MPRROIList objectAtIndex: 0] objectAtIndex: i] setComments: [NSString stringWithFormat:@"%d",tempmarker-1]];
							if(tempmarker==marker)
								[[[MPRROIList objectAtIndex: 0] objectAtIndex: i] setComments: [NSString stringWithFormat:@"%d",0]];
						}
						
						for(i = marker-1;i<[newSeedsROIList count];i++)
							[[newSeedsROIList objectAtIndex: i] setComments: [NSString stringWithFormat:@"%d",i+1]];
						long j,size;
						size =imageWidth * imageHeight * imageAmount;
						for(j=0;j<size;j++)
						{
							if(*(newSeedsBuffer + j)==marker)
								*(newSeedsBuffer + j)=0;
							else if (*(newSeedsBuffer + j)>marker)
								*(newSeedsBuffer + j)=*(newSeedsBuffer + j)-1;
						}
						uniIndex--;
					}
					
				}
			}
		}
	}
			
}
- (void) creatROIListFromSlices:(NSMutableArray*) roiList :(int) width:(int)height:(short unsigned int*)im:(float)spaceX:(float)spaceY:(float)originX:(float)originY
{
	int x,y;
	unsigned int i;
	short unsigned marker;
	RGBColor color;
	ROI* roi;
	NSRect rect;
	rect.origin.x=-1;
	rect.origin.y=-1;
	rect.size.width =-1;
	rect.size.height =-1;
	for(i=0;i<[newSeedsROIList count];i++)
		[[newSeedsROIList objectAtIndex:i] setROIRect:rect];
	
	for(y=0;y<height;y++)
		for(x=0;x<width;x++)
		{
			marker=*(im+y*width+x);
			if(marker>0&&marker<=[newSeedsROIList count])
			{
				roi=[newSeedsROIList objectAtIndex:marker-1];
				rect=[roi rect];
				if(rect.origin.x<0)
				{
					rect.origin.x=x;
					rect.origin.y=y;
					rect.size.width=0;
					rect.size.height=0;
				}
				else
				{
					if(rect.origin.x>x)
					{
						rect.size.width+=(rect.origin.x-x);
						rect.origin.x=x;
					}
					else if(rect.origin.x+rect.size.width <x)
						rect.size.width = x-rect.origin.x;
					if(rect.origin.y>y)
					{
						rect.size.height+=(rect.origin.y-y);
						rect.origin.y=y;
					}
					else if(rect.origin.y+rect.size.height <y)
						rect.size.height = y-rect.origin.y;
				}
				[roi setROIRect: rect];
				
				
				
			}
		}
			
			for(i=0;i<[newSeedsROIList count];i++)
			{
				roi=[newSeedsROIList objectAtIndex:i];
				rect = [roi rect];
	
				if(rect.origin.x>=0)
				{
					rect.size.width+=1;
					rect.size.height+=1; 
					unsigned char* textureBuffer= (unsigned char*)malloc((int)(rect.size.width *rect.size.height));
					
					for(y=0;y<rect.size.height;y++)
						for(x=0;x<rect.size.width;x++)
						{
							int ii=(int)((y+rect.origin.y)*width+x+rect.origin.x);
							int jj=(int)(y*rect.size.width + x);
							if(*(im+ii)==i+1)
								*(textureBuffer+jj)=0xff;
							else 
								*(textureBuffer+jj)=0x00;
						}
							
					ROI *newROI=[[ROI alloc] initWithTexture:textureBuffer textWidth:(int)rect.size.width textHeight:(int)rect.size.height textName:[roi name] positionX:(int)rect.origin.x positionY:(int)rect.origin.y spacingX:spaceX spacingY:spaceY imageOrigin:NSMakePoint( originX,  originY)];

					[newROI setComments:[NSString stringWithFormat:@"%d",i+1]];
					if(IsVersion2_6)
						color= [roi color];
					else
						color= [roi rgbcolor];	
						
					[newROI setColor:color];
					
					[newROI setROIMode:ROI_selected];
					//[newROI setParentROI:roi];
					[roiList addObject:newROI];
					[newROI release];
					free(textureBuffer);
				}
			}
			
			
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
		
		
		if( [MPRPixList containsObject: otherPix])
		{
			//if( iww != [originalView curWW] || iwl != [originalView curWL])
			[mprView setIndex: 0 ];
			if( iww != [resultView curWW] || iwl != [resultView curWL])
				[resultView setWLWW:iwl :iww];					
			
		}
		else if( [resultPixList containsObject: otherPix])
		{
			[resultView setIndex: 0];
			if( iww != [mprView curWW] || iwl != [mprView curWL])
				[mprView setWLWW:iwl :iww];				

		}
		
	}
	

}
- (void) crossMove:(NSNotification*) note
{
	   if([[[note userInfo] objectForKey:@"action"] isEqualToString:@"dragged"] == YES)
	   {
		   float oX,oY;
		   vtkImageData	*tempIm;
		   double		space[ 3], origin[ 3];
		   tempIm = mprViewSlice->GetOutput();
		   tempIm->Update();
		   tempIm->GetSpacing( space);
		   tempIm->GetOrigin( origin);	
		   
		   [mprView getCrossCoordinates: &oX  :&oY];
		   oY=-oY;
		   oX=oX*space[0]+origin[0];
		   oY=oY*space[1]+origin[1];
		   if(!(oX==0&&oY==0))
		   {
			   mprViewUserTransform->Translate(oX,oY,0);
	
			   
		   }
	   }
	if([[[note userInfo] objectForKey:@"action"] isEqualToString:@"mouseUp"] == YES)
	{	
		float angle= [mprView angle];
		if(angle!=0)
			[self rotateZMPRView:angle];
		else
			[self updateMPRView];
		//[self rotateZMPRView:angle];
		[mprView setMPRAngle: 0.0];
	}
	
}
- (IBAction)setConnectnessMapThreshold:(id)sender
{
	[thresholdForConnectedness setIntValue:[thresholdSlider intValue]];
	[self updateResultView];
}
- (IBAction)exportResults:(id)sender
{
	id waitWindow = [originalViewController startWaitWindow:@"processing"];		
	int tag=[sender tag];
	if(tag==1)
	{
		[self exportUnderMaskToImages];
	}
	else if(tag==2)
	{
		[self exportToROIs];
	}
	else if(tag==3)
	{
		[self exportToPreResult];
	}
	else if(tag==4)
	{
		[self exportToSeparateSeries];
	}
	[originalViewController endWaitWindow: waitWindow];
}
- (void) exportUnderMaskToImages
{

	NSArray				*pixList = [originalViewController pixList];
	DCMPix				*curPix = [pixList objectAtIndex: 0];
	
	long size=sizeof(float)*imageWidth*imageHeight*imageAmount;
	float* volumeData=(float*)malloc(size);
	[self createVolumDataUnderMask:volumeData :showSeedsArray];
	
	NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
	NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
	NSData	*newData = [NSData dataWithBytesNoCopy:volumeData length: size freeWhenDone:YES];
	int z;
	for( z = 0 ; z < imageAmount; z ++)
	{
		curPix = [pixList objectAtIndex: z];
		DCMPix	*copyPix = [curPix copy];
		[newPixList addObject: copyPix];
		[copyPix release];
		[newDcmList addObject: [[originalViewController fileList] objectAtIndex: z]];
		
		[[newPixList lastObject] setfImage: (float*) (volumeData + imageSize * z)];
	}
	ViewerController *new2DViewer;
	new2DViewer = [originalViewController newWindow	:newPixList
													:newDcmList
													:newData];  
	
	NSString* tempstr=[NSString stringWithString:@"Results of "];
	unsigned int i;
	int colorIndex;
	for(i=0;i< [showSeedsArray count];i++)
	{
		colorIndex = [[showSeedsArray objectAtIndex:i] intValue];
		tempstr=[tempstr stringByAppendingFormat:@" %@",[[choosenSeedsArray objectAtIndex:colorIndex-1] name]];
	}
	[new2DViewer checkEverythingLoaded];
	[[new2DViewer window] setTitle:tempstr];
	NSMutableArray	*temparray=[[parent dataOfWizard] objectForKey: @"VCList"];
	if(!temparray)
	{
		temparray=[NSMutableArray arrayWithCapacity:0];
		[[parent dataOfWizard] setObject:temparray forKey:@"VCList"];
	}
	[temparray addObject:new2DViewer];
	temparray=[[parent dataOfWizard] objectForKey: @"VCTitleList"];
	if(!temparray)
	{
		temparray=[NSMutableArray arrayWithCapacity:0];
		[[parent dataOfWizard] setObject:temparray forKey:@"VCTitleList"];
	}
	
	[temparray addObject:tempstr];
	
	
}
- (void) exportToSeparateSeries
{
	unsigned int index;
	for(index=0;index<[showSeedsArray count];index++)
	{
		
		NSArray				*pixList = [originalViewController pixList];
		DCMPix				*curPix = [pixList objectAtIndex: 0];
		
		long size=sizeof(float)*imageWidth*imageHeight*imageAmount;
		float* volumeData=(float*)malloc(size);
		NSMutableArray* templist=[NSMutableArray arrayWithCapacity:0];
		[templist addObject: [showSeedsArray objectAtIndex: index]];
		[self createVolumDataUnderMask:volumeData :templist];
		[templist removeAllObjects];
		
		NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
		NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
		NSData	*newData = [NSData dataWithBytesNoCopy:volumeData length: size freeWhenDone:YES];
		int z;
		for( z = 0 ; z < imageAmount; z ++)
		{
			curPix = [pixList objectAtIndex: z];
			DCMPix	*copyPix = [curPix copy];
			[newPixList addObject: copyPix];
			[copyPix release];
			[newDcmList addObject: [[originalViewController fileList] objectAtIndex: z]];
			
			[[newPixList lastObject] setfImage: (float*) (volumeData + imageSize * z)];
		}
		ViewerController *new2DViewer;
		new2DViewer = [originalViewController newWindow	:newPixList
														:newDcmList
														:newData];  
		
		NSString* tempstr=[NSString stringWithString:@"Results of "];
		unsigned int i;
		int colorIndex;
		for(i=0;i< [showSeedsArray count];i++)
		{
			colorIndex = [[showSeedsArray objectAtIndex:i] intValue];
			tempstr=[tempstr stringByAppendingFormat:@" %@",[[choosenSeedsArray objectAtIndex:colorIndex-1] name]];
		}
		[new2DViewer checkEverythingLoaded];
		[[new2DViewer window] setTitle:tempstr];
		NSMutableArray	*temparray=[[parent dataOfWizard] objectForKey: @"VCList"];
		if(!temparray)
		{
			temparray=[NSMutableArray arrayWithCapacity:0];
			[[parent dataOfWizard] setObject:temparray forKey:@"VCList"];
		}
		[temparray addObject:new2DViewer];
		temparray=[[parent dataOfWizard] objectForKey: @"VCTitleList"];
		if(!temparray)
		{
			temparray=[NSMutableArray arrayWithCapacity:0];
			[[parent dataOfWizard] setObject:temparray forKey:@"VCTitleList"];
		}
		
		[temparray addObject:tempstr];
		
		
	}
}
- (void) exportToROIs
{
	NSArray				*pixList = [originalViewController pixList];
	DCMPix				*curPix = [pixList objectAtIndex: 0];
	
	long size=sizeof(float)*imageWidth*imageHeight*imageAmount;
	float* volumeData=(float*)malloc(size);
	float* tempinput=[originalViewController volumePtr:0];
	memcpy(volumeData,tempinput,size);
	
	NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
	NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
	NSData	*newData = [NSData dataWithBytesNoCopy:volumeData length: size freeWhenDone:YES];
	int z;
	for( z = 0 ; z < imageAmount; z ++)
	{
		curPix = [pixList objectAtIndex: z];
		DCMPix	*copyPix = [curPix copy];
		[newPixList addObject: copyPix];
		[copyPix release];
		[newDcmList addObject: [[originalViewController fileList] objectAtIndex: z]];
		
		[[newPixList lastObject] setfImage: (float*) (volumeData + imageSize * z)];
	}
	ViewerController *new2DViewer=0L;
	new2DViewer = [originalViewController newWindow	:newPixList
													:newDcmList
													:newData];  
	if(new2DViewer)
	{
		ROI* tempROI;
		RGBColor	color;
		NSString *roiName;
		unsigned char *textureBuffer;
		NSMutableArray      *roiList= [new2DViewer roiList];
		unsigned int i,j;
		for(i=0;i<[roiList count];i++)
		{
			[self resultViewUpdateROI: i];
			for(j=0;j<[[resultROIList objectAtIndex: 0] count];j++)
			{
				
				
				tempROI = [[resultROIList objectAtIndex: 0] objectAtIndex:j];
				roiName = [tempROI name];
				textureBuffer=[tempROI textureBuffer];
				if(IsVersion2_6)
					color= [tempROI color];
				else
					color= [tempROI rgbcolor];
			
				ROI *newROI=[[ROI alloc] initWithTexture:textureBuffer textWidth:imageWidth textHeight:imageHeight textName:roiName positionX:0 positionY:0 spacingX:[curPix pixelSpacingY] spacingY:[curPix pixelSpacingY]  imageOrigin:NSMakePoint( [curPix originX], [curPix originY])];
				textureBuffer=[newROI textureBuffer];
				*textureBuffer=0x00;
				*(textureBuffer+imageSize-1)=0x00;	
				[newROI reduceTextureIfPossible];
				
				[newROI setColor:color];
				
				[[roiList objectAtIndex: i] addObject: newROI];
				[newROI release];
			}
		}
		NSString* tempstr=[NSString stringWithString:@"ROI results of "];
		int colorIndex;
		for(i=0;i< [showSeedsArray count];i++)
		{
			colorIndex = [[showSeedsArray objectAtIndex:i] intValue];
			tempstr=[tempstr stringByAppendingFormat:@" %@",[[choosenSeedsArray objectAtIndex:colorIndex-1] name]];
		}
		[new2DViewer checkEverythingLoaded];
		[[new2DViewer window] setTitle:tempstr];
		NSMutableArray	*temparray=[[parent dataOfWizard] objectForKey: @"VCList"];
		if(!temparray)
		{
			temparray=[NSMutableArray arrayWithCapacity:0];
			[[parent dataOfWizard] setObject:temparray forKey:@"VCList"];
		}
		
		[temparray addObject:new2DViewer];
		temparray=[[parent dataOfWizard] objectForKey: @"VCTitleList"];
		if(!temparray)
		{
			temparray=[NSMutableArray arrayWithCapacity:0];
			[[parent dataOfWizard] setObject:temparray forKey:@"VCTitleList"];
		}
		[temparray addObject:tempstr];
		
	}
}
- (void) exportToPreResult
{

		NSArray				*pixList = [originalViewController pixList];
		DCMPix				*curPix = [pixList objectAtIndex: 0];
		
		long size=sizeof(float)*imageWidth*imageHeight*imageAmount;
		float* volumeData=(float*)malloc(size);
		unsigned char* choosenColorList;
		int choosenColorNumber=[showSeedsArray count];
		int isAChoosenColor;
		float offset=maxValueInCurSeries-minValueInCurSeries;
		float curOffset;
		size=sizeof(unsigned char)*choosenColorNumber;
		choosenColorList=(unsigned char*)malloc(size);
		size=imageAmount*imageSize;
		int i,j;
		for(i=0;i<choosenColorNumber;i++)
			*(choosenColorList+i) = (unsigned char) [[showSeedsArray objectAtIndex:i] intValue];
		for(i=0;i<size;i++)
		{
			isAChoosenColor=0;
			for(j=0;j<choosenColorNumber;j++)
				if(*(choosenColorList+j)==*(colorData+i))
				{
					isAChoosenColor=1;
					curOffset=offset*j;
				}
			if(isAChoosenColor)
				*(volumeData+i)=*(inputData+i)+curOffset;
			else
				*(volumeData+i)=minValueInCurSeries;
				
			
		}
		
		free(choosenColorList);
		
		NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
		NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
		NSData	*newData = [NSData dataWithBytesNoCopy:volumeData length: size freeWhenDone:YES];
		int z;
		for( z = 0 ; z < imageAmount; z ++)
		{
			curPix = [pixList objectAtIndex: z];
			DCMPix	*copyPix = [curPix copy];
			[newPixList addObject: copyPix];
			[copyPix release];
			[newDcmList addObject: [[originalViewController fileList] objectAtIndex: z]];
			
			[[newPixList lastObject] setfImage: (float*) (volumeData + imageSize * z)];
		}
		ViewerController *new2DViewer;
		new2DViewer = [originalViewController newWindow	:newPixList
														:newDcmList
														:newData];  
		NSString* tempstr=[NSString stringWithString:@"Mixture"];
		[new2DViewer checkEverythingLoaded];
		[[new2DViewer window] setTitle:tempstr];
		NSMutableArray	*temparray=[[parent dataOfWizard] objectForKey: @"VCList"];
		if(!temparray)
		{
			temparray=[NSMutableArray arrayWithCapacity:0];
			[[parent dataOfWizard] setObject:temparray forKey:@"VCList"];
		}
		[temparray addObject:new2DViewer];
		temparray=[[parent dataOfWizard] objectForKey: @"VCTitleList"];
		if(!temparray)
		{
			temparray=[NSMutableArray arrayWithCapacity:0];
			[[parent dataOfWizard] setObject:temparray forKey:@"VCTitleList"];
		}
		[temparray addObject:tempstr];
		

}
- (IBAction)rotateXMPRView:(id)sender
{
	float angle;
	angle=[sender floatValue] - lastMPRViewXAngle;
	
	if(angle!=0)
	{
		lastMPRViewXAngle = [sender floatValue];
		mprViewUserTransform->RotateX(angle);	
		
		[self updateMPRView];
		[self updateMPRPageSlider];		
		[oViewRotateXText setFloatValue: [sender floatValue]];
	}	
	
	
}
- (IBAction)rotateYMPRView:(id)sender
{
	float angle;
	angle=[sender floatValue] - lastMPRViewYAngle;
	if(angle!=0)
	{
		lastMPRViewYAngle = [sender floatValue];
		mprViewUserTransform->RotateY(angle);
		
		[self updateMPRView];
		[self updateMPRPageSlider];		
		[oViewRotateYText setFloatValue: [sender floatValue]];
	}
	
}
- (void)    rotateZMPRView:(float)angle
{
	
	if(angle!=0)
	{
		
		mprViewUserTransform->RotateZ(angle);	
		
		[self updateMPRView];
		[self updateMPRPageSlider];				
	}	
}
- (IBAction)changMPRViewDirection:(id)sender
{
	if(!centerIsLocked)
	{
		float origin[3]={0,0,0};
		mprViewUserTransform->TransformPoint(origin,origin);
		mprViewBasicTransform->Identity();
		mprViewBasicTransform->Translate( origin[0], origin[1], origin[2] );
		
	}
	
	mprViewUserTransform->Identity();	
	mprViewUserTransform->RotateX(-90);
	if([sender tag]==0)
	{
		
	}
	else if([sender tag]==1)
	{
		mprViewUserTransform->RotateY(180);
	}
	else if([sender tag]==2)
	{
		mprViewUserTransform->RotateX(-90);
	}
	else if([sender tag]==3)
	{
		mprViewUserTransform->RotateX(90);
	}
	else if([sender tag]==4)
	{
		mprViewUserTransform->RotateY(90);
	}
	else if([sender tag]==5)
	{
		mprViewUserTransform->RotateY(-90);
	}
	[self updateMPRView];
	[self resetMPRSliders];
	
}
- (IBAction)resetMPRView:(id)sender
{
	mprViewBasicTransform->Identity();
	mprViewBasicTransform->Translate( vtkOriginalX+xSpacing*imageWidth/2, vtkOriginalY+ySpacing*imageHeight/2, vtkOriginalZ + sliceThickness*imageAmount/2 );
	mprViewBasicTransform->RotateX(-90);
	mprViewUserTransform->Identity ();
	
	[self updateMPRView];
	[self resetMPRSliders];	
}
- (void) synchronizeMPRView:(int)page
{
	mprViewBasicTransform->Identity();
	mprViewBasicTransform->Translate( vtkOriginalX+xSpacing*imageWidth/2, vtkOriginalY+ySpacing*imageHeight/2, vtkOriginalZ + sliceThickness*page );
	mprViewUserTransform->Identity ();
	
	[self updateMPRView];
	[self resetMPRSliders];	
}
- (IBAction)showCross:(id)sender
{
	if([sender state]== NSOnState)
	{
		mprViewUserTransform->Translate(0,0,0.5);
		mprViewUserTransform->Translate(0,0,-0.5);
		[self updateMPRView];
	}
	else
	{
		[mprView setCrossCoordinates:-9999 :-9999 :YES];
	}
	
}
- (void) createVolumDataUnderMask:(float*)volumeData:(NSArray*)exportList
{
	unsigned char* choosenColorList;
	int choosenColorNumber=[exportList count];
	int isAChoosenColor;
	int size;
	size=sizeof(unsigned char)*choosenColorNumber;
	choosenColorList=(unsigned char*)malloc(size);
	size=imageAmount*imageSize;
	int i,j;
	for(i=0;i<choosenColorNumber;i++)
		*(choosenColorList+i) = (unsigned char) [[exportList objectAtIndex:i] intValue];
	float thresholdValue = [thresholdSlider floatValue];
	for(i=0;i<size;i++)
	{
		isAChoosenColor=0;
		for(j=0;j<choosenColorNumber;j++)
			if(*(choosenColorList+j)==*(colorData+i))
				isAChoosenColor=1;
		if(isAChoosenColor&&((*(outputData+i))>=thresholdValue))
			*(volumeData+i)=*(inputData+i);
		else
			*(volumeData+i)=minValueInCurSeries;
			
		
	}
	
	free(choosenColorList);
	
}
- (void) createUnsignedShortVolumDataUnderMask:(unsigned short*)volumeData
{
	unsigned char* choosenColorList;
	int choosenColorNumber=[showSeedsArray count];
	int isAChoosenColor;
	int size;
	size=sizeof(unsigned char)*choosenColorNumber;
	choosenColorList=(unsigned char*)malloc(size);
	size=imageAmount*imageSize;
	int i,j;
	for(i=0;i<choosenColorNumber;i++)
		*(choosenColorList+i) = (unsigned char) [[showSeedsArray objectAtIndex:i] intValue];
	float thresholdValue = [thresholdSlider floatValue];
	for(i=0;i<size;i++)
	{
		isAChoosenColor=0;
		for(j=0;j<choosenColorNumber;j++)
			if(*(choosenColorList+j)==*(colorData+i))
				isAChoosenColor=1;
		if(isAChoosenColor&&((*(outputData+i))>=thresholdValue))
			*(volumeData+i)=(unsigned short)((*(inputData+i)+osirixOffset)*osirixValueFactor);
		else
			*(volumeData+i)=0;
				
	}
	
	free(choosenColorList);
	
}
- (void) updateVRView
{
	if(!volumeDataOfVR)
		return;
	else
		[self createUnsignedShortVolumDataUnderMask:volumeDataOfVR];
	float ww,wl;
	[vrView getWLWW: &wl :&ww];
	[vrView setWLWW: wl : ww];
	
}


- (void) Display3DPoint:(NSNotification*) note
{
	float x,y,z;

	x = [[[note userInfo] valueForKey:@"x"] intValue];
	y = [[[note userInfo] valueForKey:@"y"] intValue];
	z = [[[note userInfo] valueForKey:@"z"] intValue];
	x *= xSpacing;
	y *= ySpacing;
	z *= zSpacing;
	mprViewBasicTransform->Identity();
	mprViewBasicTransform->Translate( vtkOriginalX+x, vtkOriginalY+y, vtkOriginalZ + z );
	mprViewUserTransform->Identity ();
	
	[self updateMPRView];
	[self resetMPRSliders];	

}

- (IBAction)createSkeleton:(id)sender
{
	int tag=[sender tag];
	if(tag<=1)
	{
		[skeletonWindow orderOut:sender];
		[NSApp endSheet:skeletonWindow returnCode:tag];
	}
	if(tag)
	{


		NSLog( @"start step 4");
		//get parameters
		float  pathWeightLength,lengthThreshold,weightThreshold;
		weightThreshold=[thresholdForDistalEnd floatValue] ;
		lengthThreshold=[thresholdForBranch floatValue];
		if(lengthThreshold<5.0)
			lengthThreshold=5.0;
		lengthThreshold/=minSpacing;
		
		id waitWindow = [originalViewController startWaitWindow:@"processing"];	
		
		if(![self prepareForSkeletonizatin])
		{	
			NSRunAlertPanel(NSLocalizedString(@"no root seeds are found, try seed planting again", nil), NSLocalizedString(@"no root seeds", nil), NSLocalizedString(@"OK", nil), nil, nil);
			[originalViewController endWaitWindow: waitWindow];


			return;
		}
		
		CMIVSegmentCore *segmentCoreFunc = [[CMIVSegmentCore alloc] init];
		centerlinesList=[[NSMutableArray alloc] initWithCapacity: 0];
		centerlinesNameList=[[NSMutableArray alloc] initWithCapacity: 0];
		[segmentCoreFunc setImageWidth:imageWidth Height: imageHeight Amount: imageAmount];
		if(segmentNeighborhood==6)
			[segmentCoreFunc startShortestPathSearchAsFloatWith6Neighborhood:inputData Out:outputData Direction: directionData];
		else 
			[segmentCoreFunc startShortestPathSearchAsFloat:inputData Out:outputData :colorData Direction: directionData];
		unsigned short* pdismap=nil;
		if([[tab2D3DView tabViewItems] count]>1)  
			pdismap = volumeDataOfVR;
		else
			pdismap = (unsigned short*)malloc(imageSize*imageAmount*sizeof(unsigned short));
		if(!pdismap)
		{
			NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM to build distance map", nil), NSLocalizedString(@"OK", nil), nil, nil);
			return;
		}
		
		[self prepareForCaculateLength:pdismap];
		[segmentCoreFunc localOptmizeConnectednessTree:inputData :outputData :pdismap Pointer: directionData :minValueInCurSeries];

		int* indexForEachSeeds=(int*)malloc(sizeof(int)*[choosenSeedsArray count]);
		unsigned int i;
		for(i=0;i<[choosenSeedsArray count];i++)
			*(indexForEachSeeds+i)=0;
		
		do
		{
			[self prepareForCaculateWightedLength];
			int endindex=[segmentCoreFunc caculatePathLengthWithWeightFunction:inputData:outputData Pointer: directionData:weightThreshold:maxValueInCurSeries];
			pathWeightLength = *(outputData+endindex);
			if(endindex>0)
			{
				[centerlinesList addObject:[NSMutableArray arrayWithCapacity:0]];
				unsigned char colorindex;
				int len=[self searchBackToCreatCenterlines: centerlinesList: endindex :&colorindex];
				NSString *pathName = [[choosenSeedsArray objectAtIndex:colorindex-1] name];
				*(indexForEachSeeds+colorindex-1)=*(indexForEachSeeds+colorindex-1)+1;
				[centerlinesNameList addObject: [pathName stringByAppendingFormat:@"%d",*(indexForEachSeeds+colorindex-1)] ];
			
				if(len < lengthThreshold)
				{
					[[centerlinesList lastObject] removeAllObjects];
					[centerlinesList removeLastObject];
					[centerlinesNameList removeLastObject]; 
					pathWeightLength=-1;
				}
			}
		}while( pathWeightLength>0);
		
		

		
		[segmentCoreFunc release];
		[updateButton setEnabled: NO]; 
		[skeletonztionButton setEnabled:NO];
		[exportButton removeItemAtIndex: 3];
		[exportButton removeItemAtIndex: 1];
		[[exportButton itemAtIndex:1 ] setTitle:@"Export Skeleton"] ;
		[thresholdSlider setFloatValue:[thresholdSlider minValue]];
		[thresholdSlider setEnabled: NO];
		float ww,wl;
		ww=[resultView curWW];
		wl=[resultView curWL];
		[resultView setWLWW:wl:ww];
		[originalViewController endWaitWindow: waitWindow];
		if(isInWizardMode)
		{
			if([saveBeforeSkeletonization state]== NSOnState)
				[self finishAdjustion:skeletonztionButton];
			else
				[self onCancel: sender];
			[parent cleanDataOfWizard];
			[[parent dataOfWizard] setObject:centerlinesList forKey:@"CenterlinesList"] ;
			[[parent dataOfWizard] setObject:centerlinesNameList forKey:@"CenterlinesNameList"] ;
			[centerlinesList release];	
			[centerlinesNameList release];

			[parent gotoStepNo:4];
		}
		else
		{
			[self createROIfrom3DPaths:centerlinesList:centerlinesNameList];
			[self replaceDistanceMap];//should release memory
		}


	}
	
}
- (BOOL) prepareForSkeletonizatin
{
	unsigned char* choosenColorList;
	int choosenColorNumber=[showSeedsArray count];
	int isAChoosenColor;
	int size;
	float thresholdValue = [thresholdSlider floatValue];
	thresholdValue = round ( thresholdValue );
	size=sizeof(unsigned char)*choosenColorNumber;
	choosenColorList=(unsigned char*)malloc(size);
	size=imageAmount*imageSize;
	int i,j;
	for(i=0;i<choosenColorNumber;i++)
		*(choosenColorList+i) = (unsigned char) [[showSeedsArray objectAtIndex:i] intValue];
	for(i=0;i<size;i++)
	{
		isAChoosenColor=0;
		for(j=0;j<choosenColorNumber;j++)
			if(*(choosenColorList+j)==((*(colorData+i))&0x3f)&&(*(outputData+i))>=thresholdValue)
				isAChoosenColor=1;
		if(!isAChoosenColor)
		{
			*(directionData+i)=(*(directionData+i)) | 0x80;
			*(outputData+i)=minValueInCurSeries;
		}
		else
		{
			//*(directionData+i)=0x40;
			*(outputData+i)=minValueInCurSeries;
		}
		
	}

	if([self plantRootSeeds]<1)
		return NO;
	
	[[resultROIList objectAtIndex: 0] removeAllObjects];	
	resultViewROIMode=2;
	
	free(choosenColorList);
	return YES;
	
	
}
- (int)plantRootSeeds
{
	int seedNumber=0;

	if(isInWizardMode)// inherited from history
	{
		unsigned k;
		NSMutableArray		*rootSeedIndexList=[[NSMutableArray alloc] initWithCapacity:0];
		ROI* tempROI1;
		for(k=0;k<[newSeedsROIList count];k++)
		{
			tempROI1=[newSeedsROIList objectAtIndex: k];
			if([tempROI1 type]==tOval&&![[tempROI1 name] isEqualToString: @"barrier"])
				[rootSeedIndexList addObject:[NSNumber numberWithInt: k+1]];
		}
		int i,j;
		int size=imageWidth*imageHeight*imageAmount;
		int rootnumber=[rootSeedIndexList count];
		unsigned short int* rootColorList=(unsigned short int*)malloc(sizeof(unsigned short int)*rootnumber);
		for(j=0;j<rootnumber;j++)
			*(rootColorList+j)=(unsigned short int)[[rootSeedIndexList objectAtIndex: j] intValue];
		for(i=0;i<size;i++)
			for(j=0;j<rootnumber;j++)
			{
				if((*(newSeedsBuffer+i))==(*(rootColorList+j)))
				{
					*(directionData+i)=(*(colorData+i))| 0x80;
					*(outputData+i)=*(inputData+i);		
					seedNumber++;
				}
			}
		[rootSeedIndexList removeAllObjects];
		[rootSeedIndexList release];
	}
	if(!seedNumber)
	{
		unsigned int i,j;
		NSArray* roiList= [originalViewController roiList] ;
		ROI* tempROI;

		int x,y;
		int lefttopx, lefttopy,rightbottomx,rightbottomy;
		int textureOriginX,textureOriginY,textureWidth;
		for(i=0;i<[roiList count];i++)
			for(j=0;j<[[roiList objectAtIndex:i] count];j++)
			{
				tempROI=[[roiList objectAtIndex: i] objectAtIndex: j];
				if([[tempROI comments] isEqualToString: @"root"]&&[tempROI type]==tPlain)
				{
					unsigned char *textureBuffer= [tempROI textureBuffer];
		
					textureOriginX=lefttopx = [tempROI textureUpLeftCornerX];
					textureOriginY=lefttopy = [tempROI textureUpLeftCornerY];
					rightbottomx = [tempROI textureDownRightCornerX]+1;
					rightbottomy = [tempROI textureDownRightCornerY]+1;
					textureWidth = rightbottomx-lefttopx;
					if(lefttopx>rightbottomx)
					{	
						lefttopx = [tempROI textureDownRightCornerX];
						rightbottomx = [tempROI textureUpLeftCornerX];						
					}
					if(lefttopy>rightbottomy)
					{
						lefttopy = [tempROI textureDownRightCornerY];
						rightbottomy = [tempROI textureUpLeftCornerY];
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
							{
								*(directionData+i*imageWidth*imageHeight + y*imageWidth + x)=(*(colorData+i*imageWidth*imageHeight + y*imageWidth + x)) | 0x80;
								*(outputData+i*imageWidth*imageHeight + y*imageWidth + x)=*(inputData+i*imageWidth*imageHeight + y*imageWidth + x);		
								seedNumber++;
							}					
								
					
				}
			}	
	}		
	return seedNumber;

}
- (void) prepareForCaculateLength:(unsigned short*)dismap
{
	int size,i;
	size=imageAmount*imageSize;
	for(i=0;i<size;i++)
	{
		if((*(directionData+i)) & 0xC0)
			*(dismap+i)=1;
		else
			*(dismap+i)=0;
	}
	
}
- (void) prepareForCaculateWightedLength
{
	int size,i;
	size=imageAmount*imageSize;
	for(i=0;i<size;i++)
	{
		if((*(directionData+i)) & 0xC0)
			*(outputData+i)=1;
		else
			*(outputData+i)=0;
	}
}
- (void)createROIfrom3DPaths:(NSArray*)pathsList:(NSArray*)namesList
{
	//doesn't work anymore after change result view stratergy
	return;
	RGBColor color;
	color.red = 65535;
	color.blue = 0;
	color.green = 0;
	unsigned char * textureBuffer;
	DCMPix* curPix;
	CMIV3DPoint* temp3dpoint;
	NSString* roiName;
	int x,y,z;
	int pointIndex=0;
	unsigned int i,j;
	for(i=0;i<[pathsList count];i++)
	{
		pointIndex=0;
		for(j=0;j<[[pathsList objectAtIndex:i] count];j++)
		{
			temp3dpoint=[[pathsList objectAtIndex:i] objectAtIndex: j];
			x=[temp3dpoint x];
			y=[temp3dpoint y];
			z=[temp3dpoint z];
			roiName=[namesList objectAtIndex: i];
			curPix = [resultPixList objectAtIndex: 0];
			textureBuffer = (unsigned char *) malloc(sizeof(unsigned char ));
			*textureBuffer = 0xff;
			ROI *newROI=[[ROI alloc] initWithTexture:textureBuffer textWidth:1 textHeight:1 textName:roiName positionX:x positionY:y spacingX:[curPix pixelSpacingY] spacingY:[curPix pixelSpacingY]  imageOrigin:NSMakePoint( [curPix originX], [curPix originY])];
			
			[[resultROIList objectAtIndex: z] addObject:newROI];
			[newROI setColor: color];
			NSString *indexstr=[NSString stringWithFormat:@"%d",pointIndex];
			[newROI setComments:indexstr];	
			pointIndex++;
			[newROI release];
		}
	temp3dpoint=[[pathsList objectAtIndex:i] objectAtIndex: 0];
	x=[temp3dpoint x];
	y=[temp3dpoint y];
	z=[temp3dpoint z];
	NSRect roiRect;
	roiRect.origin.x=x;
	roiRect.origin.y=y;
	ROI *endPointROI = [[ROI alloc] initWithType: t2DPoint :[curPix pixelSpacingX] :[curPix pixelSpacingY] : NSMakePoint( [curPix originX], [curPix originY])];
	[endPointROI setName:roiName];
	[endPointROI setROIRect:roiRect];
	[[resultROIList objectAtIndex: z] addObject:endPointROI];
	[endPointROI release];
	}
	
}
- (int) searchBackToCreatCenterlines:(NSMutableArray *)pathsList:(int)endpointindex:(unsigned char*)color
{

	int branchlen=0;
	int x,y,z;
	unsigned char pointerToUpper;
	z = endpointindex/imageSize ;
	y = (endpointindex-imageSize*z)/imageWidth ;
	x = endpointindex-imageSize*z-imageWidth*y;
	
	
	CMIV3DPoint* new3DPoint=[[CMIV3DPoint alloc] init] ;
	[new3DPoint setX: x];
	[new3DPoint setY: y];
	[new3DPoint setZ: z];
	[[pathsList lastObject] addObject: new3DPoint];
	
	do{
		if(!(*(directionData + endpointindex)&0x40))
			branchlen++;
		pointerToUpper = ((*(directionData + endpointindex))&0x3f);
		*(directionData + endpointindex)=pointerToUpper|0x40;
		int itemp;
		switch(pointerToUpper)
		{
			case 1: itemp =  (-imageSize-imageWidth-1);
				x--;y--;z--;
				break;
			case 2: itemp =  (-imageSize-imageWidth);
				y--;z--;
				break;
			case 3: itemp = (-imageSize-imageWidth+1);
				x++;y--;z--;
				break;
			case 4: itemp = (-imageSize-1);
				x--;z--;
				break;
			case 5: itemp = (-imageSize);
				z--;
				break;
			case 6: itemp = (-imageSize+1);
				x++;z--;
				break;
			case 7: itemp = (-imageSize+imageWidth-1);
				x--;y++;z--;
				break;
			case 8: itemp = (-imageSize+imageWidth);
				y++;z--;
				break;
			case 9: itemp = (-imageSize+imageWidth+1);
				x++;y++;z--;
				break;
			case 10: itemp = (-imageWidth-1);
				x--;y--;
				break;
			case 11: itemp = (-imageWidth);
				y--;
				break;
			case 12: itemp = (-imageWidth+1);
				x++;y--;
				break;
			case 13: itemp = (-1);
				x--;
				break;
			case 14: itemp = 0;
				break;
			case 15: itemp = 1;
				x++;
				break;
			case 16: itemp = imageWidth-1;
				x--;y++;
				break;
			case 17: itemp = imageWidth;
				y++;
				break;
			case 18: itemp = imageWidth+1;
				x++;y++;
				break;
			case 19: itemp = imageSize-imageWidth-1;
				x--;y--;z++;
				break;
			case 20: itemp = imageSize-imageWidth;
				y--;z++;
				break;
			case 21: itemp = imageSize-imageWidth+1;
				x++;y--;z++;
				break;
			case 22: itemp = imageSize-1;
				x--;z++;
				break;
			case 23: itemp = imageSize;
				z++;
				break;
			case 24: itemp = imageSize+1;
				x++;z++;
				break;
			case 25: itemp = imageSize+imageWidth-1;
				x--;y++;z++;
				break;
			case 26: itemp = imageSize+imageWidth;
				y++;z++;
				break;
			case 27: itemp = imageSize+imageWidth+1;
				x++;y++;z++;
				break;
		}
		
		endpointindex+=itemp;
		new3DPoint=[[CMIV3DPoint alloc] init] ;
		[new3DPoint setX: x];
		[new3DPoint setY: y];
		[new3DPoint setZ: z];
		[[pathsList lastObject] addObject: new3DPoint];
		
					
		
	}while(!((*(directionData + endpointindex))&0x80));
	
	*color=(*(directionData + endpointindex))&0x3f;
	
	return branchlen;
	
}
- (void) replaceDistanceMap
{
	int size,i;
	size=imageAmount*imageSize;
	for(i=0;i<size;i++)
	{
			*(outputData+i)=*(inputData+i);

	}
	
}
- (float)valueAfterConvolutionAt:(int)x:(int)y:(int)z
{
	int ii,jj,kk;
	float sum;
	int xx,yy,zz;

	for(ii=-1;ii<2;ii++)
		for(jj=-1;jj<2;jj++)
			for(kk=-1;kk<2;kk++)
			{
				zz=z+ii;
				yy=y+jj;
				xx=x+kk;
				if(xx>=0 && xx<imageWidth && yy>=0 && yy<imageHeight && zz>=0 && zz<imageAmount && (!((*(directionData + zz*imageWidth * imageHeight + yy*imageWidth + xx))&0x80)))
					sum+=*(inputData + zz*imageWidth * imageHeight + yy*imageWidth + xx);
				else
					sum+=minValueInCurSeries;
				

			}
	sum=sum/27;
	return sum;
}
- (IBAction)changeVRMode:(id)sender
{
	if([vrMode selectedRow] == 0)
		[vrView setMode: 1];
	else
		[vrView setMode: 0];


	
}
- (IBAction)changeVRColor:(id)sender
{
	if([sender state]== NSOnState)
	{
		NSDictionary		*aCLUT;
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
			
			[vrView setCLUT:red :green: blue];
		}
	}
	else
		[vrView setCLUT: 0L :0L :0L];	
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
		[vrView coView:sender];
	else if(tag==4)
		[vrView saView: sender];
	else if(tag==5)
		[vrView saViewOpposite:sender];
	else if(tag==3)
		[vrView axView:sender];
}
-(NSMutableArray*) curPixList { return [originalViewController pixList];}

- (IBAction)showSkeletonDialog:(id)sender
{
	if(!isInWizardMode)
		[saveBeforeSkeletonization setHidden: YES];
	[NSApp beginSheet: skeletonWindow modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}
- (void) checkRootSeeds:(NSArray*)roiList
{
	unsigned int i,j,k;
	ROI* tempROI1,*tempROI2;
	NSString* comments;
	NSString* newComments=[NSString stringWithString:@"root"];
	for(k=0;k<[newSeedsROIList count];k++)
	{
		tempROI1=[newSeedsROIList objectAtIndex: k];
		if([tempROI1 type]==tOval&&![[tempROI1 name] isEqualToString: @"barrier"])
		{
			
			comments=[tempROI1 comments];
			for(i=0;i<[roiList count];i++)
				for(j=0;j<[[roiList objectAtIndex:i] count];j++)
				{
					tempROI2=[[roiList objectAtIndex: i] objectAtIndex: j];
					if([[tempROI2 comments] isEqualToString: comments])
						[tempROI2 setComments:newComments];
					
				}
		}
	}
		
}
- (void) windowDidBecomeMain:(NSNotification *)aNotification
{
	[self reHideToolbar];
}

- (void)reHideToolbar
{
	/*
	unsigned int i;
	for( i = 0; i < [toolbarList count]; i++)
	{
		[[toolbarList objectAtIndex: i] setVisible: NO];
		
	}*/

}
@end
