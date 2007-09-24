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
#import "CMIVScissorsController.h"
#import "CMIV3DPoint.h"
#import "CMIVSegmentCore.h"
static		float						deg2rad = 3.14159265358979/180.0; 

@implementation CMIVScissorsController

- (IBAction)addSeed:(id)sender
{
	NSMutableDictionary *contrast;
	
	contrast = [NSMutableDictionary dictionary];
	[contrast setObject:[NSString stringWithString:[seedName stringValue] ]  forKey:@"Name"];
	[contrast setObject: [seedColor color] forKey:@"Color"];
	[contrast setObject: [NSNumber numberWithFloat:2.0] forKey:@"BrushWidth"];
	[contrast setObject: [NSNumber numberWithInt:8] forKey:@"CurrentTool"];
	[contrastList addObject: contrast];
	[seedsList reloadData];
	[seedsList selectRow:[contrastList count]-1 byExtendingSelection:NO];
	[self selectAContrast: seedsList];
	
}


- (IBAction)setPathMode:(id)sender
{
	int tag=[sender tag];
	if(tag==1)
		currentPathMode=ROI_drawing;
	else if(tag==2)
		currentPathMode=ROI_selectedModify;
	[self changeCurrentTool:5];
	
}
- (void) changeCurrentTool:(int) tag
{
	if(currentTool==4)
	{
		unsigned int i;
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"ROITEXTNAMEONLY"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ROITEXTIFSELECTED"];
		for ( i=0;i<[[oViewROIList objectAtIndex: 0] count];i++)
		{
			ROI* temproi=[[oViewROIList objectAtIndex: 0] objectAtIndex: i] ;
			if([temproi type] == tMesure)
			{
				
					[[oViewROIList objectAtIndex: 0] removeObjectAtIndex:i];
					i--;
			}
		}
		for ( i=0;i<[[cViewROIList objectAtIndex: 0] count];i++)
		{
			ROI* temproi=[[cViewROIList objectAtIndex: 0] objectAtIndex: i] ;
			if([temproi type] == tMesure)
			{
				
				[[cViewROIList objectAtIndex: 0] removeObjectAtIndex:i];
				i--;
			}
		}
		for ( i=0;i<[[axViewROIList objectAtIndex: 0] count];i++)
		{
			ROI* temproi=[[axViewROIList objectAtIndex: 0] objectAtIndex: i] ;
			if([temproi type] == tMesure)
			{
				
				[[axViewROIList objectAtIndex: 0] removeObjectAtIndex:i];
				i--;
			}
		}
		
	}
	if(tag>=0&&tag<4)
	{
		[originalView setCurrentTool: tag];
		[cPRView setCurrentTool: tag];
		[crossAxiasView setCurrentTool:tag];
		
		
	}
	else if(tag==4)
	{
		[originalView setCurrentTool: tMesure];
		[cPRView setCurrentTool: tMesure];
		[crossAxiasView setCurrentTool:tMesure];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey: @"ROITEXTNAMEONLY"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ROITEXTIFSELECTED"];
	}
	else if(tag==5)
	{
		[originalView setCurrentTool: tOPolygon];
		[cPRView setCurrentTool: tTranslate];
		[crossAxiasView setCurrentTool: tWL];
		currentTool=tag;
		[self updateOView];
		[self cAndAxViewReset];
		[self updatePageSliders];
	}
	else if(tag==6)
	{
		[originalView setCurrentTool: tMesure];
		[cPRView setCurrentTool: tROI];
		[crossAxiasView setCurrentTool: tWL];
		unsigned int row = currentStep;
		if(row>=0&&row<[contrastList count])
		{
			[[contrastList objectAtIndex: row] setObject: [NSNumber numberWithInt:7] forKey:@"CurrentTool"];
		}		
		if(currentTool==7||currentTool==5)
		{
			currentTool=tag;
			[self updateOView];
			[self cAndAxViewReset];
			[self updatePageSliders];
		}
	}
	else if(tag==7)
	{
		[originalView setCurrentTool: tArrow];
		[cPRView setCurrentTool: tArrow];
		[crossAxiasView setCurrentTool: tOval];	

		unsigned int row = currentStep;
		if(row>=0&&row<[contrastList count])
		{
			[[contrastList objectAtIndex: row] setObject: [NSNumber numberWithInt:7] forKey:@"CurrentTool"];
		}
			if(currentTool==6||currentTool==5)
		{	
			currentTool=tag;
			[self updateOView];
			[self cAndAxViewReset];
			[self updatePageSliders];
			
		}		
		
	}
	else if(tag==8)
	{
		[originalView setCurrentTool: tPlain];
		if(!isInWizardMode)
			[brushStatSegment setSelectedSegment: 0];
		[originalView setEraserFlag:0];
		unsigned int row = currentStep;
		if(row>=0&&row<[contrastList count])
		{
			[[contrastList objectAtIndex: row] setObject: [NSNumber numberWithInt:8] forKey:@"CurrentTool"];
		}
		if(!isInWizardMode)
			[[NSUserDefaults standardUserDefaults] setFloat:[brushWidthSlider floatValue] forKey:@"ROIRegionThickness"];
		[cPRView setCurrentTool: tWL];
		[crossAxiasView setCurrentTool: tWL];
		if(currentTool==6||currentTool==7||currentTool==5)
		{	
			currentTool=tag;
			[self updateOView];
			[self cAndAxViewReset];
			[self updatePageSliders];
			
		}
		
	}
	else
		return;
	
	if(isInWizardMode)
	{
		if(tag!=6&&tag!=7&&tag!=8)
		{
			[currentTips setStringValue: howToContinueTip];
			[continuePlantingButton setHidden:NO];
			[nextButton setEnabled: NO];
			[previousButton setEnabled: NO];
		}
		else
			[continuePlantingButton setHidden:YES];
	}
		
	currentTool=tag;
	
}
- (IBAction)changeDefaultTool:(id)sender
{
	int tag=[sender tag];
	[self changeCurrentTool:tag];
}

- (IBAction)changeSeedColor:(id)sender
{
}

- (IBAction)changeSeedName:(id)sender
{
}
- (IBAction)resetOriginalView:(id)sender
{
	oViewBasicTransform->Identity();
	oViewBasicTransform->Translate( vtkOriginalX+xSpacing*imageWidth/2, vtkOriginalY+ySpacing*imageHeight/2, vtkOriginalZ + sliceThickness*imageAmount/2 );
	oViewBasicTransform->RotateX(-90);
	oViewUserTransform->Identity ();
	[self updateOView];
	[self cAndAxViewReset];
	[self resetSliders];	
}
- (IBAction)lockCenter:(id)sender
{

	if([centerLock state]== NSOnState)
	{
		centerIsLocked=1;

		[oImageSlider setEnabled: NO]; 
	}
	else
	{
		centerIsLocked=0;
		[oImageSlider setEnabled: YES]; 
	}
	
	[self updateOView];
	[self cAndAxViewReset];
	[self resetSliders];
	
}
- (IBAction)changOriginalViewDirection:(id)sender
{
	if(!centerIsLocked)
	{
		float origin[3]={0,0,0};
		oViewUserTransform->TransformPoint(origin,origin);
		oViewBasicTransform->Identity();
		oViewBasicTransform->Translate( origin[0], origin[1], origin[2] );
		
	}

	oViewUserTransform->Identity();	
	oViewUserTransform->RotateX(-90);
	if([sender tag]==0)
	{

	}
	else if([sender tag]==1)
	{
		oViewUserTransform->RotateY(180);
	}
	else if([sender tag]==2)
	{
		oViewUserTransform->RotateX(-90);
	}
	else if([sender tag]==3)
	{
		oViewUserTransform->RotateX(90);
	}
	else if([sender tag]==4)
	{
		oViewUserTransform->RotateY(90);
	}
	else if([sender tag]==5)
	{
		oViewUserTransform->RotateY(-90);
	}
	[self updateOView];
	[self resetSliders];
	[self updatePageSliders];
	[self cAndAxViewReset];

}

- (IBAction)onCancel:(id)sender
{
	int tag=[sender tag];
	
	[window setReleasedWhenClosed:YES];
	[window close];
//	[window orderOut:sender];
    
    [NSApp endSheet:window returnCode:[sender tag]];
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[[NSUserDefaults standardUserDefaults] setInteger: annotations forKey: @"ANNOTATIONS"];
	[[NSUserDefaults standardUserDefaults] setBool:roiShowNameOnly forKey: @"ROITEXTNAMEONLY"];
	[[NSUserDefaults standardUserDefaults] setBool:roiShowTextOnlyWhenSeleted forKey:@"ROITEXTIFSELECTED"];
	[[oViewROIList objectAtIndex: 0] removeAllObjects];
	[[oViewROIList objectAtIndex: 1] removeAllObjects];
	[oViewROIList removeAllObjects];
	[oViewROIList release];
	[oViewPixList removeAllObjects];
	[oViewPixList release];
	[cViewPixList removeAllObjects];
	[cViewPixList release];
	[[cViewROIList objectAtIndex: 0]  removeAllObjects];
	[cViewROIList removeAllObjects];
	[cViewROIList release];
	[axViewPixList removeAllObjects];
	[axViewPixList release];
	[[axViewROIList objectAtIndex: 0]  removeAllObjects];
	[axViewROIList removeAllObjects];
	[axViewROIList release];
	unsigned int i;
	for(i=0;i<[contrastList count];i++)
		[[contrastList objectAtIndex: i] removeAllObjects];
	[contrastList removeAllObjects];
	[contrastList release];

	if(tag!=2)
		[totalROIList  removeAllObjects];
	[totalROIList release];

	[curvedMPR3DPath removeAllObjects];
	[curvedMPR3DPath release];
	[curvedMPRProjectedPaths removeAllObjects];
	[curvedMPRProjectedPaths release];
	if(curvedMPRReferenceLineOfAxis)
		[curvedMPRReferenceLineOfAxis release];
	[curvedMPR2DPath release];
	if(tag!=2&&!isInCPROnlyMode)
		free(contrastVolumeData);
	
	if(reader)
	{
		reader->Delete();
				
		oViewSlice->Delete();

		oViewBasicTransform->Delete();
		oViewUserTransform->Delete();
		cViewTransform->Delete();
		axViewTransform->Delete();
		cViewSlice->Delete();
		axViewSlice->Delete();
		if(!isInCPROnlyMode)
		{
			roiReader->Delete();
			oViewROISlice->Delete();
		}
		if(narrowRibbonofCenterline)
			narrowRibbonofCenterline->Delete();
		///////////////
	}
	if(howToContinueTip)
		[howToContinueTip release];
	


	for( i = 0; i < [toolbarList count]; i++)
	{
		[[toolbarList objectAtIndex: i] setVisible: YES];
		
	}
	[toolbarList removeAllObjects];

	if(tag!=2)
		[parent exitCurrentDialog];
	
}

- (IBAction)onOK:(id)sender
{
	NSArray				*pixList = [originalViewController pixList];
	unsigned int i;
	id waitWindow = [originalViewController startWaitWindow:@"processing"];
	NSMutableArray      *roiList;
	short unsigned int* im;
	for(i=0;i<[pixList count];i++)
	{
		roiList= [[originalViewController roiList] objectAtIndex: i];
		im=contrastVolumeData+imageSize*i;
		[self creatROIListFromSlices: roiList  :imageWidth :imageHeight :im :xSpacing :ySpacing :  [curPix originX]: [curPix originY]];
		
		
	}
	roiList= [originalViewController roiList] ;
	[self checkRootSeeds:roiList];
	[originalViewController endWaitWindow: waitWindow];
	[[originalViewController window] setTitle:@"Seeds Planted"];
	[self onCancel:sender];
}
- (void) checkRootSeeds:(NSArray*)roiList
{
	unsigned int i,j,k;
	ROI* tempROI1,*tempROI2;
	NSString* comments;
	NSString* newComments=[NSString stringWithString:@"root"];
	for(k=0;k<[totalROIList count];k++)
	{
		tempROI1=[totalROIList objectAtIndex: k];
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

- (IBAction)pageAxView:(id)sender
{
	float locate;
	locate=[sender minValue]+[sender maxValue]-[sender floatValue];
	axViewTransform->Identity();
	axViewTransform->Translate(cPRViewCenter.x,cPRViewCenter.y,0 );
	axViewTransform->RotateZ(oViewToCViewZAngle);
	axViewTransform->RotateX(90+cViewToAxViewZAngle);
	axViewTransform->Translate(0,0,-locate);
	isNeedShowReferenceLine=YES;
	[self updateAxView];
	isNeedShowReferenceLine=NO;
}

- (IBAction)pageCView:(id)sender
{

	float locate;
	locate=[sender floatValue] - lastCViewTranslate;
	lastCViewTranslate = [sender floatValue];
	cViewTransform->Translate(0,0,locate);
	if(locate!=0)
		[self updateCView];
	
//	[self updateCViewAsCurvedMPR];
	
}

- (IBAction)pageOView:(id)sender
{
	

	NSSliderCell* testcell=[sender cell];
	 int event= [testcell mouseDownFlags];
	 
	 if(event!=256)
		 event++;

	float locate,step;
	locate=[sender floatValue];
	locate=round([sender floatValue]/minSpacing);
	step=locate-lastOViewTranslate;
	step*=minSpacing;
	lastOViewTranslate = locate;
	oViewUserTransform->Translate(0,0,step);
	if(step!=0)
	{
		[self updateOView];
		if(currentTool!=5&&!isInCPROnlyMode) 
			[self updateAxView];
	}

	
}

- (IBAction)removeSeed:(id)sender
{

	unsigned int i;
	int row=[seedsList selectedRow];
	NSString *name;
	name =[[contrastList objectAtIndex: row]objectForKey:@"Name"];
	
	for(i=0;i<[totalROIList count];i++)
		if([[[totalROIList objectAtIndex: i] name] isEqualToString:name])
		{
			[[NSNotificationCenter defaultCenter] postNotificationName: @"removeROI" object:[totalROIList objectAtIndex: i] userInfo: 0L];
			i--;
		}

	

	[contrastList removeObjectAtIndex:row];

	[seedsList reloadData];
	if(row>=(int)([contrastList count]))
		row=(int)([contrastList count])-1;
	[seedsList selectRow:row byExtendingSelection:NO];
	[self selectAContrast: seedsList];	

	[self updateOView];
	[self cAndAxViewReset];
	[self updatePageSliders];		

}

- (IBAction)rotateXCView:(id)sender
{

	float angle;
	angle=[sender floatValue];
	if([sender isMouseLeftKeyDown])
		interpolationMode=0;
	else
		interpolationMode=1;
	
	if(angle!=0||interpolationMode)
	{
		cViewTransform->Identity();
		cViewTransform->Translate(cPRViewCenter.x,cPRViewCenter.y,0 );
		cViewTransform->RotateZ(oViewToCViewZAngle);
		cViewTransform->RotateY(-90);
		
		cViewTransform->RotateY(angle);	
		
		[self updateCView];

		[cImageSlider setFloatValue:0];
		lastCViewTranslate=0;
		[cViewRotateYText setFloatValue: [sender floatValue]];
	}		

	
}

- (IBAction)rotateXOView:(id)sender
{

		float angle;
		angle=[sender floatValue] - lastOViewXAngle;
		if([sender isMouseLeftKeyDown])
			interpolationMode=0;
		else
			interpolationMode=1;

		if(angle!=0||interpolationMode)
		{

				
			lastOViewXAngle = [sender floatValue];
			oViewUserTransform->RotateX(angle);	

			[self updateOView];
			[self cAndAxViewReset];
			[self updatePageSliders];
			[oViewRotateXText setFloatValue: [sender floatValue]];
		}	
		 
}
- (void)    rotateZOView:(float)angle
{
	if(angle!=0)
	{

		oViewUserTransform->RotateZ(angle);	
		
		[self updateOView];
		[self cAndAxViewReset];
		[self updatePageSliders];		
	}	
}
- (IBAction)rotateYOView:(id)sender
{

		float angle;
		angle=[sender floatValue] - lastOViewYAngle;
		if([sender isMouseLeftKeyDown])
			interpolationMode=0;
		else
			interpolationMode=1;
		
		if(angle!=0||interpolationMode)
		{
			lastOViewYAngle = [sender floatValue];
			oViewUserTransform->RotateY(angle);
			[self updateOView];
			[self cAndAxViewReset];
			[self updatePageSliders];	
			[oViewRotateYText setFloatValue: [sender floatValue]];
		}


}
- (void)showPanelAsWizard:(ViewerController *) vc:(	CMIV_CTA_TOOLS*) owner
{
	isInWizardMode=YES;
	[self showScissorsPanel: vc:owner];
	
}
- (void)showPanelAsCPROnly:(ViewerController *) vc: (CMIV_CTA_TOOLS*) owner
{
	isInCPROnlyMode=YES;

	[self showScissorsPanel: vc:owner];
	cpr3DPaths=[[parent dataOfWizard] objectForKey:@"CenterlinesList"];
	centerlinesNameArrays=[[parent dataOfWizard] objectForKey:@"CenterlinesNameList"];
	[resampleRatioSlider setFloatValue:2.5];
	[resampleRatioText setFloatValue:2.5];
	[self convertCenterlinesToVTKCoordinate:cpr3DPaths];
	[self setCurrentCPRPathWithPath:[cpr3DPaths objectAtIndex: 0]:[resampleRatioSlider floatValue]];
	[centerlinesList setDataSource:self];
	[cImageSlider setEnabled: NO];
	[cYRotateSlider setEnabled: NO];

}
- (int) showScissorsPanel:(ViewerController *) vc : (CMIV_CTA_TOOLS*) owner
 {

	int err=0;
	originalViewController=vc;	
	curPix = [[originalViewController pixList] objectAtIndex: [[originalViewController imageView] curImage]];
	parent = owner;	
	if( [curPix isRGB])
	{
		NSRunAlertPanel(NSLocalizedString(@"no RGB Support", nil), NSLocalizedString(@"This plugin doesn't surpport RGB images, please convert this series into BW images first", nil), NSLocalizedString(@"OK", nil), nil, nil);
		
		return 0;
	}	
	interpolationMode=1;
	NSArray				*pixList = [originalViewController pixList];
	imageWidth = [curPix pwidth];
	imageHeight = [curPix pheight];
	imageAmount = [pixList count];	
	imageSize = imageWidth*imageHeight;
	fileList =[originalViewController fileList ];
	
	minValueInSeries = [curPix minValueOfSeries]; 
	
	
	[NSBundle loadNibNamed:@"Scissors_Panel" owner:self];
	[window setFrame:[[NSScreen mainScreen] visibleFrame] display:YES ];
	
	
	//initilize original view CPRView and Axial View;
	err = [self initViews];
	if(err)
		return err;
	[self resetSliders];
	
	err = [self initSeedsList];
	if(err)
		return err;
	currentTool=0;
	currentPathMode=ROI_sleep;
	curvedMPR3DPath = [[NSMutableArray alloc] initWithCapacity: 0];
	curvedMPRProjectedPaths=[[NSMutableArray alloc] initWithCapacity: 0];

	DCMPix * curImage= [cViewPixList objectAtIndex:0];
	curvedMPRReferenceLineOfAxis=[[ROI alloc] initWithType: tMesure :[curImage pixelSpacingX] :[curImage pixelSpacingY] : NSMakePoint( [curImage originX], [curImage originY])];
	[curvedMPRReferenceLineOfAxis setName:[NSString stringWithString: @"Axis Reference Line"] ];
	[curvedMPRReferenceLineOfAxis setROIMode:ROI_sleep];
	MyPoint* lastPoint=[[MyPoint alloc] initWithPoint:NSMakePoint(0,0)];
	[[curvedMPRReferenceLineOfAxis points] addObject: lastPoint];
	[lastPoint release];
	lastPoint=[[MyPoint alloc] initWithPoint:NSMakePoint(0,0)];
	[[curvedMPRReferenceLineOfAxis points] addObject: lastPoint];
	[lastPoint release];


	
	//store annotation state
	annotations	= [[NSUserDefaults standardUserDefaults] integerForKey: @"ANNOTATIONS"];
	
	defaultROIThickness=[[NSUserDefaults standardUserDefaults] floatForKey:@"ROIThickness"];
	
	[curvedMPRReferenceLineOfAxis setThickness:0.5];
	
	[[NSUserDefaults standardUserDefaults] setFloat:defaultROIThickness forKey:@"ROIThickness"];
	
	[[NSUserDefaults standardUserDefaults] setInteger: 1 forKey: @"ANNOTATIONS"];
	roiShowTextOnlyWhenSeleted=[[NSUserDefaults standardUserDefaults] boolForKey:@"ROITEXTIFSELECTED"];
	roiShowNameOnly=[[NSUserDefaults standardUserDefaults] boolForKey: @"ROITEXTNAMEONLY"];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"ROITEXTNAMEONLY"];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ROITEXTIFSELECTED"];
	
	//registe the notificationcenter

	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc addObserver: self selector: @selector(defaultToolModified:) name:@"defaultToolModified" object:nil];
	[nc addObserver: self selector: @selector(roiChanged:) name:@"roiChange" object:nil];
	[nc addObserver: self selector: @selector(roiAdded:) name:@"addROI" object:nil];
	[nc addObserver: self selector: @selector(roiRemoved:) name:@"removeROI" object:nil];
	[nc	addObserver: self selector: @selector(changeWLWW:) name: @"changeWLWW" object: nil];	
	[nc	addObserver: self selector: @selector(crossMove:) name: @"crossMove" object: nil];	
	[nc addObserver: self selector: @selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
	
	
	if(isInWizardMode)
	{
		[seedToolTipsTabView removeTabViewItem:[seedToolTipsTabView tabViewItemAtIndex:2]];
		[seedToolTipsTabView removeTabViewItem:[seedToolTipsTabView tabViewItemAtIndex:0]];
		[convertToSeedButton setHidden:YES];
		[exportOrthogonalImagesButton setHidden:YES];
		totalSteps=3;
		[self goSubStep:0:YES];
		[previousButton setEnabled: NO];
		howToContinueTip = [[NSString alloc] initWithString:@"You are using a general tools, to contiue seed planting, please click the button below."];
		[continuePlantingButton setHidden:YES];
	}
	else if(isInCPROnlyMode)
	{
		[seedToolTipsTabView removeTabViewItem:[seedToolTipsTabView tabViewItemAtIndex:1]];
		[seedToolTipsTabView removeTabViewItem:[seedToolTipsTabView tabViewItemAtIndex:0]];
		[convertToSeedButton setHidden:YES];
		[nextButton setHidden:YES];
		[previousButton setHidden:YES];
		[saveButton setHidden:YES];
		[exportOrthogonalImagesButton setHidden:YES];
		[cancelButton setTitle: @"exit"];
		
	}
	else
	{
		[seedToolTipsTabView removeTabViewItem:[seedToolTipsTabView tabViewItemAtIndex:2]];
		[seedToolTipsTabView removeTabViewItem:[seedToolTipsTabView tabViewItemAtIndex:1]];
		[nextButton setHidden:YES];
		[previousButton setHidden:YES];

		
	}


	
	[NSApp beginSheet: window modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];	
	[seedsList setDataSource:self];	
	if(!isInWizardMode)
		[self selectAContrast:seedsList];
//	if(!parent)
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
	}
	
	
	return err;
	
}
- (int) initViews
{


	long                size;
	NSArray				*pixList = [originalViewController pixList];

	volumeData=[originalViewController volumePtr:0];
	 if(!isInCPROnlyMode)
	 {
		 
		size = sizeof(short unsigned int) * imageWidth * imageHeight * imageAmount;
		contrastVolumeData = (unsigned short int*) malloc( size);
		if( !contrastVolumeData)
		{
			NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);
			free(volumeData);
			return -1;	
		}	
	 }
	
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
	
	oViewRotateAngleX=0;
	oViewRotateAngleY=0;
	cViewRotateAngleY=0;
	centerIsLocked=0;

	reader = vtkImageImport::New();
	reader->SetWholeExtent(0, imageWidth-1, 0, imageHeight-1, 0, imageAmount-1);
	reader->SetDataSpacing(xSpacing,ySpacing,zSpacing);
	reader->SetDataOrigin( vtkOriginalX,vtkOriginalY,vtkOriginalZ );
	reader->SetDataExtentToWholeExtent();
	reader->SetDataScalarTypeToFloat();
	reader->SetImportVoidPointer(volumeData);
	if(!isInCPROnlyMode)
	{
		roiReader = vtkImageImport::New();
		roiReader->SetWholeExtent(0, imageWidth-1, 0, imageHeight-1, 0, imageAmount-1);
		roiReader->SetDataSpacing(xSpacing,ySpacing,zSpacing);
		roiReader->SetDataOrigin( vtkOriginalX,vtkOriginalY,vtkOriginalZ );
		roiReader->SetDataExtentToWholeExtent();
		roiReader->SetDataScalarTypeToUnsignedShort();
		roiReader->SetImportVoidPointer(contrastVolumeData);
	}
	
	oViewBasicTransform = vtkTransform::New();
	oViewBasicTransform->Translate( vtkOriginalX+xSpacing*imageWidth/2, vtkOriginalY+ySpacing*imageHeight/2, vtkOriginalZ + sliceThickness*imageAmount/2 );

	oViewUserTransform = vtkTransform::New();
	oViewUserTransform->Identity ();
	oViewUserTransform->SetInput(oViewBasicTransform) ;
	oViewUserTransform->RotateX(-90);
	
	inverseTransform = (vtkTransform*)oViewUserTransform->GetLinearInverse();

	
	cViewTransform = vtkTransform::New();
	cViewTransform->SetInput(oViewUserTransform) ;
	cViewTransform->RotateY(-90);
	
	axViewTransform = vtkTransform::New();
	axViewTransform->SetInput(oViewUserTransform) ;
	axViewTransform->RotateX(90);
	
	axViewTransformForStraightenCPR = vtkTransform::New();
	avViewinverseTransform = (vtkTransform*)axViewTransformForStraightenCPR->GetLinearInverse();
	oViewSlice = vtkImageReslice::New();
	oViewSlice->SetAutoCropOutput( true);
	oViewSlice->SetInformationInput( reader->GetOutput());
	oViewSlice->SetInput( reader->GetOutput());
	oViewSlice->SetOptimization( true);
	oViewSlice->SetResliceTransform( oViewUserTransform);
	oViewSlice->SetResliceAxesOrigin( 0, 0, 0);
	oViewSlice->SetInterpolationModeToCubic();//    >SetInterpolationModeToNearestNeighbor();
	oViewSlice->SetOutputDimensionality( 2);
	oViewSlice->SetBackgroundLevel( -1024);
	if(!isInCPROnlyMode)
	{
		oViewROISlice= vtkImageReslice::New();
		oViewROISlice->SetAutoCropOutput( true);
		oViewROISlice->SetInformationInput( roiReader->GetOutput());
		oViewROISlice->SetInput( roiReader->GetOutput());
		oViewROISlice->SetOptimization( true);
		oViewROISlice->SetResliceTransform( oViewUserTransform);
		oViewROISlice->SetResliceAxesOrigin( 0, 0, 0);
		oViewROISlice->SetInterpolationModeToNearestNeighbor();
		oViewROISlice->SetOutputDimensionality( 2);
		oViewROISlice->SetBackgroundLevel( -1024);	
	}
	
	vtkImageData	*tempIm;
	int				imExtent[ 6];
	double		space[ 3], origin[ 3];
	tempIm = oViewSlice->GetOutput();
	tempIm->Update();
	tempIm->GetWholeExtent( imExtent);
	tempIm->GetSpacing( oViewSpace);
	tempIm->GetOrigin( oViewOrigin);
	tempIm->GetSpacing( space);
	tempIm->GetOrigin( origin);	
	
	float *im = (float*) tempIm->GetScalarPointer();
	DCMPix*		mypix = [[DCMPix alloc] initwithdata:(float*) im :32 :imExtent[ 1]-imExtent[ 0]+1 :imExtent[ 3]-imExtent[ 2]+1 :space[0] :space[1] :origin[0] :origin[1] :origin[2]];
	[mypix copySUVfrom: curPix];	
	
	oViewPixList = [[NSMutableArray alloc] initWithCapacity:0];
	[oViewPixList addObject: mypix];
	[mypix release];	
	
	oViewROIList = [[NSMutableArray alloc] initWithCapacity:0];
	[oViewROIList addObject:[NSMutableArray arrayWithCapacity:0]];
	[oViewROIList addObject:[NSMutableArray arrayWithCapacity:0]];
	[originalView setDCM:oViewPixList :fileList :oViewROIList :0 :'i' :YES];
	NSString *viewName = [NSString stringWithString:@"Original"];
	[originalView setStringID: viewName];
	[originalView setMPRAngle: 0.0];
	[originalView setCross: 0 :0 :YES];

	[originalView setIndexWithReset: 0 :YES];
	[originalView setOrigin: NSMakePoint(0,0)];
	[originalView setCurrentTool:tWL];
	[originalView  scaleToFit];
	float iwl, iww;
	iww = [[originalViewController imageView] curWW] ;
	iwl = [[originalViewController imageView] curWL] ;
	[originalView setWLWW:iwl :iww];
	float crossX,crossY;
	crossX=-origin[0]/space[0];
	crossY=origin[1]/space[1];

	if(crossX<0)
		crossX=0;
	else if(crossX>imExtent[ 1]-imExtent[ 0])
		crossX=imExtent[ 1]-imExtent[ 0];
	if(crossY>0)
		crossY=0;
	else if(crossY<-(imExtent[ 3]-imExtent[ 2] ))
		crossY=-(imExtent[ 3]-imExtent[ 2] );
	[originalView setCrossCoordinates:crossX:crossY :YES];
	

	
	cViewSlice = vtkImageReslice::New();
	cViewSlice->SetAutoCropOutput( true);
	cViewSlice->SetInformationInput( reader->GetOutput());
	cViewSlice->SetInput( reader->GetOutput());
	cViewSlice->SetOptimization( true);
	cViewSlice->SetResliceTransform( cViewTransform);
	cViewSlice->SetResliceAxesOrigin( 0, 0, 0);
	cViewSlice->SetInterpolationModeToCubic();
	cViewSlice->SetOutputDimensionality( 2);
	cViewSlice->SetBackgroundLevel( -1024);


	tempIm = cViewSlice->GetOutput();
	tempIm->Update();
	tempIm->GetWholeExtent( imExtent);
	tempIm->GetSpacing( space);
	tempIm->GetOrigin( origin);	
	tempIm->GetSpacing( cViewSpace);
	tempIm->GetOrigin( cViewOrigin);
	
	im = (float*) tempIm->GetScalarPointer();
	mypix = [[DCMPix alloc] initwithdata:(float*) im :32 :imExtent[ 1]-imExtent[ 0]+1 :imExtent[ 3]-imExtent[ 2]+1 :space[0] :space[1] :origin[0] :origin[1] :origin[2]];
	[mypix copySUVfrom: curPix];	
	
	cViewPixList = [[NSMutableArray alloc] initWithCapacity:0];
	[cViewPixList addObject: mypix];
	[mypix release];	
	
	cViewROIList = [[NSMutableArray alloc] initWithCapacity:0];
	[cViewROIList addObject:[NSMutableArray arrayWithCapacity:0]];
	
	viewName = [NSString stringWithString:@"CPR"];
	
	[cPRView setDCM:cViewPixList :fileList :cViewROIList :0 :'i' :YES];
//	viewName = [NSString stringWithString:@"Original"];
	[cPRView setStringID: viewName];
//	[cPRView setMPRAngle: 0.0];
//	[cPRView setCross: 0 :0 :YES];
	
	[cPRView setIndexWithReset: 0 :YES];
	[cPRView setOrigin: NSMakePoint(0,0)];
	[cPRView setCurrentTool:tWL];
	[cPRView  scaleToFit];
	[cPRView setWLWW:iwl :iww];	
	
	axViewSlice = vtkImageReslice::New();
	axViewSlice->SetAutoCropOutput( true);
	axViewSlice->SetInformationInput( reader->GetOutput());
	axViewSlice->SetInput( reader->GetOutput());
	axViewSlice->SetOptimization( true);
	axViewSlice->SetResliceTransform( axViewTransform);
	axViewSlice->SetResliceAxesOrigin( 0, 0, 0);
	axViewSlice->SetInterpolationModeToCubic();
	axViewSlice->SetOutputDimensionality( 2);
	axViewSlice->SetBackgroundLevel( -1024);
	
	
	tempIm = axViewSlice->GetOutput();
	tempIm->Update();
	tempIm->GetWholeExtent( imExtent);
	tempIm->GetSpacing( space);
	tempIm->GetOrigin( origin);	
	
	im = (float*) tempIm->GetScalarPointer();
	mypix = [[DCMPix alloc] initwithdata:(float*) im :32 :imExtent[ 1]-imExtent[ 0]+1 :imExtent[ 3]-imExtent[ 2]+1 :space[0] :space[1] :origin[0] :origin[1] :origin[2]];
	[mypix copySUVfrom: curPix];	
	
	axViewPixList = [[NSMutableArray alloc] initWithCapacity:0];
	[axViewPixList addObject: mypix];
	[mypix release];	
	
	axViewROIList = [[NSMutableArray alloc] initWithCapacity:0];
	[axViewROIList addObject:[NSMutableArray arrayWithCapacity:0]];
	
	[crossAxiasView setDCM:axViewPixList :fileList :axViewROIList :0 :'i' :YES];
	viewName = [NSString stringWithString:@"CrossAxial"];
	[crossAxiasView setStringID: viewName];
	//	[cPRView setMPRAngle: 0.0];
	//	[cPRView setCross: 0 :0 :YES];
	
	[crossAxiasView setIndexWithReset: 0 :YES];
	[crossAxiasView setOrigin: NSMakePoint(0,0)];
	[crossAxiasView setCurrentTool:tWL];
	[crossAxiasView setScaleValue: 1.5*[originalView scaleValue]];
	[crossAxiasView setWLWW:iwl :iww];	
	
	cprImageBuffer=0L;
	
	ROI* testROI=[[ROI alloc] initWithType: tOval :xSpacing :ySpacing : NSMakePoint( 0, 0)];
	if([testROI respondsToSelector:@selector(color)])
		IsVersion2_6=YES;
	else
		IsVersion2_6=NO;
	[testROI release];	
	
	return 0;
	
	
}
- (int) initSeedsList
{
	//initilize contrast list
	contrastList= [[NSMutableArray alloc] initWithCapacity: 0];
	NSMutableDictionary *contrast;
	if(!isInWizardMode)
	{
		contrast = [NSMutableDictionary dictionary];
		[contrast setObject:[NSString stringWithString:@"Artery"]  forKey:@"Name"];
		[contrast setObject: [NSNumber numberWithInt:8] forKey:@"CurrentTool"];
		[contrast setObject: [NSColor redColor] forKey:@"Color"];
		[contrast setObject: [NSNumber numberWithFloat:2.0] forKey:@"BrushWidth"];
		[contrast setObject:[NSString stringWithString:@"Seeds for arteries"]  forKey:@"Tips"];
		[contrastList addObject: contrast];
		
		contrast = [NSMutableDictionary dictionary];
		[contrast setObject:[NSString stringWithString:@"Vein"]  forKey:@"Name"];
		[contrast setObject: [NSColor blueColor] forKey:@"Color"];
		[contrast setObject: [NSNumber numberWithInt:8] forKey:@"CurrentTool"];
		[contrast setObject: [NSNumber numberWithFloat:2.0] forKey:@"BrushWidth"];
		[contrast setObject:[NSString stringWithString:@"Seeds for veins"]  forKey:@"Tips"];
		[contrastList addObject: contrast];

		contrast = [NSMutableDictionary dictionary];
		[contrast setObject:[NSString stringWithString:@"Bone"]  forKey:@"Name"];
		[contrast setObject: [NSColor brownColor] forKey:@"Color"];
		[contrast setObject: [NSNumber numberWithInt:8] forKey:@"CurrentTool"];
		[contrast setObject: [NSNumber numberWithFloat:4.0] forKey:@"BrushWidth"];
		[contrast setObject:[NSString stringWithString:@"Seeds for bones"]  forKey:@"Tips"];
		[contrastList addObject: contrast];
		
	}	
	contrast = [NSMutableDictionary dictionary];
	[contrast setObject:[NSString stringWithString:@"LCA"]  forKey:@"Name"];
	[contrast setObject: [NSNumber numberWithInt:7] forKey:@"CurrentTool"];
	[contrast setObject: [NSColor redColor] forKey:@"Color"];
	[contrast setObject: [NSNumber numberWithFloat:2.0] forKey:@"BrushWidth"];
	[contrast setObject:[NSString stringWithString:@"Step2 Place Virtual catheter in LCA\nDraw an arrow in the left window at the root of LCA, adjust the arrow's direction along the long axis artery in the right buttom window if necessary, move and zoom the circle in right top window to include the whole cross section of the vessel."]  forKey:@"Tips"];
	[contrastList addObject: contrast];	
	
	contrast = [NSMutableDictionary dictionary];
	[contrast setObject:[NSString stringWithString:@"RCA"]  forKey:@"Name"];
	[contrast setObject: [NSColor greenColor] forKey:@"Color"];
	[contrast setObject: [NSNumber numberWithInt:7] forKey:@"CurrentTool"];
	[contrast setObject: [NSNumber numberWithFloat:2.0] forKey:@"BrushWidth"];
	[contrast setObject:[NSString stringWithString:@"Step3 Place Virtual catheter in RCA\nDraw an arrow in the left window at the root of RCA, adjust the arrow's direction along the long axis artery in the right buttom window if necessary, move and zoom the circle in right top window to include the whole cross section of the vessel."]  forKey:@"Tips"];
	[contrastList addObject: contrast];
	
	contrast = [NSMutableDictionary dictionary];
	[contrast setObject:[NSString stringWithString:@"other"]  forKey:@"Name"];
	[contrast setObject: [NSColor yellowColor] forKey:@"Color"];
	[contrast setObject: [NSNumber numberWithFloat:3.0] forKey:@"BrushWidth"];
	[contrast setObject: [NSNumber numberWithInt:8] forKey:@"CurrentTool"];
	[contrast setObject:[NSString stringWithString:@"Step4 Mark Unwanted Structure\nDraw yellow lines in the left window. Make sure you have marked following structures: both ventricles, desending aorta, vertebra, sternum and vein of liver."]  forKey:@"Tips"];
	[contrastList addObject: contrast];
	
	contrast = [NSMutableDictionary dictionary];
	[contrast setObject:[NSString stringWithString:@"barrier"]  forKey:@"Name"];
	[contrast setObject: [NSColor purpleColor] forKey:@"Color"];
	[contrast setObject: [NSNumber numberWithFloat:1.0] forKey:@"BrushWidth"];
	[contrast setObject: [NSNumber numberWithInt:6] forKey:@"CurrentTool"];
	[contrast setObject:[NSString stringWithString:@"Sepcial seed to stop propagation."]  forKey:@"Tips"];
	[contrastList addObject: contrast];
	
	contrast = [contrastList objectAtIndex: 0];
	[seedColor setColor:  [contrast objectForKey:@"Color"] ];
	[seedName setStringValue: [contrast objectForKey:@"Name"] ];
	[brushWidthText setIntValue:[[contrast objectForKey: @"BrushWidth"] intValue]];
	[brushWidthSlider setFloatValue:[[contrast objectForKey: @"BrushWidth"] floatValue]];
	[brushStatSegment setSelectedSegment:0];
	
	
	//intilize roi list
	totalROIList = [[NSMutableArray alloc] initWithCapacity: 0];
	uniIndex = 0;
	isRemoveROIBySelf=0;
	
	
	
	return [self reloadSeedsFromExportedROI];
}
- (int) reloadSeedsFromExportedROI
{
	
	return 0;
}
- (void) updateOView
{
	vtkImageData	*tempIm,*tempROIIm;
	int				imExtent[ 6];

	if(interpolationMode)
		oViewSlice->SetInterpolationModeToCubic();
	else
		oViewSlice->SetInterpolationModeToNearestNeighbor();
	tempIm = oViewSlice->GetOutput();
	tempIm->Update();
	tempIm->GetWholeExtent( imExtent);
	tempIm->GetSpacing( oViewSpace);
	tempIm->GetOrigin( oViewOrigin);	
	
	float *im = (float*) tempIm->GetScalarPointer();
	DCMPix*		mypix = [[DCMPix alloc] initwithdata:(float*) im :32 :imExtent[ 1]-imExtent[ 0]+1 :imExtent[ 3]-imExtent[ 2]+1 :oViewSpace[0] :oViewSpace[1] :oViewOrigin[0] :oViewOrigin[1] :oViewOrigin[2]];
	[mypix copySUVfrom: curPix];	
	
	isRemoveROIBySelf=1;
	//to avoid 2.7.5fc3 put those ROIs into autorelease pool
	if(!IsVersion2_6)
	{
		unsigned i;
		NSString* emptystr=[NSString stringWithString:@""];
		for(i=0;i<[[oViewROIList objectAtIndex: 0] count];i++)
			[[[oViewROIList objectAtIndex: 0] objectAtIndex: i] setComments:emptystr];
	}
	[[oViewROIList objectAtIndex: 0] removeAllObjects];
	if(curvedMPR2DPath)
	{

		[[oViewROIList objectAtIndex: 1] removeAllObjects];
		[[oViewROIList objectAtIndex: 1] addObject:curvedMPR2DPath ];
	}
	isRemoveROIBySelf=0;
	//creat roi list
	if(!isInCPROnlyMode)
	{
		tempROIIm = oViewROISlice->GetOutput();
		tempROIIm->Update();
		tempROIIm->GetWholeExtent( imExtent);
		tempROIIm->GetSpacing( oViewSpace);
		tempROIIm->GetOrigin( oViewOrigin);	
		short unsigned int *imROI = (short unsigned int*) tempROIIm->GetScalarPointer();
		[self creatROIListFromSlices:[oViewROIList objectAtIndex: 0] :imExtent[ 1]-imExtent[ 0]+1  :imExtent[ 3]-imExtent[ 2]+1 :imROI : oViewSpace[0]:oViewSpace[1]:oViewOrigin[0]:oViewOrigin[1]];
	}
	if((currentTool==5||isInCPROnlyMode)&&curvedMPR2DPath)
		[self reCaculateCPRPath:[oViewROIList objectAtIndex: 0] :imExtent[ 1]-imExtent[ 0]+1  :imExtent[ 3]-imExtent[ 2]+1 :oViewSpace[0]:oViewSpace[1]:oViewSpace[2]:oViewOrigin[0]:oViewOrigin[1]:oViewOrigin[3]];
	
	[oViewPixList removeAllObjects];
	[oViewPixList addObject: mypix];
	[mypix release];
	//to cheat DCMView not reset current roi;

	[originalView setIndex: 0 ];

	if([crossShowButton state]== NSOnState)
	{
		float crossX,crossY;
		crossX=-oViewOrigin[0]/oViewSpace[0];
		crossY=oViewOrigin[1]/oViewSpace[1];
		if(crossX<0)
			crossX=0;
		else if(crossX>imExtent[ 1]-imExtent[ 0])
			crossX=imExtent[ 1]-imExtent[ 0];
		if(crossY>0)
			crossY=0;
		else if(crossY<-(imExtent[ 3]-imExtent[ 2] ))
			crossY=-(imExtent[ 3]-imExtent[ 2] );
		[originalView setCrossCoordinates:crossX:crossY :YES];
	}
	if(curvedMPR2DPath)
		[curvedMPR2DPath setROIMode:currentPathMode];
	tempIm->GetSpacing( oViewSpace);
	tempIm->GetOrigin( oViewOrigin);	
	
}
- (void) updatePageSliders
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
	if(currentTool!=5&&!isInCPROnlyMode)
	{
	
		[cImageSlider setMaxValue: max[0]];
		[cImageSlider setMinValue: min[0]];
		[cImageSlider setFloatValue: 0];	

		[axImageSlider setMaxValue:max[1]];
		[axImageSlider setMinValue:min[1]];
		[axImageSlider setFloatValue: max[1]+min[1]];
	}

[oImageSlider setMaxValue: max[2]];
[oImageSlider setMinValue: min[2]];
[oImageSlider setIntValue:0];

lastOViewTranslate=0;
lastCViewTranslate=0;



}
- (void) updateCView
{
if(currentTool==5||isInCPROnlyMode)
	[self updateCViewAsCurvedMPR];
else 
	[self updateCViewAsMPR];


}

- (void) updateAxView
{
	if(currentTool==5||isInCPROnlyMode)
	{
		if(!isStraightenedCPR)
			[self recaculateAxViewForCPR];
		else
			[self recaculateAxViewForStraightenedCPR];
	}
	vtkImageData	*tempIm;
	int				imExtent[ 6];
	if(interpolationMode)
		axViewSlice->SetInterpolationModeToCubic();
	else
		axViewSlice->SetInterpolationModeToNearestNeighbor();
	tempIm = axViewSlice->GetOutput();
	tempIm->Update();
	tempIm->GetWholeExtent( imExtent);
	tempIm->GetSpacing( axViewSpace);
	tempIm->GetOrigin( axViewOrigin);	
	
	float *im = (float*) tempIm->GetScalarPointer();
	DCMPix*		mypix = [[DCMPix alloc] initwithdata:(float*) im :32 :imExtent[ 1]-imExtent[ 0]+1 :imExtent[ 3]-imExtent[ 2]+1 :axViewSpace[0] :axViewSpace[1] :axViewOrigin[0] :axViewOrigin[1] :axViewOrigin[2]];
	[mypix copySUVfrom: curPix];	
	
	[axViewPixList removeAllObjects];
	[axViewPixList addObject: mypix];
	[mypix release];
	float scale=[crossAxiasView scaleValue];
	NSPoint newOrigin;
	newOrigin.x = scale*round(axViewOrigin[0]/axViewSpace[0]+(imExtent[ 1]-imExtent[ 0]+1)/2);
	newOrigin.y = scale*(-(round(axViewOrigin[1]/axViewSpace[1]+(imExtent[ 3]-imExtent[ 2]+1)/2)));
	
	[crossAxiasView setOrigin: newOrigin];
	
	if([[axViewROIList objectAtIndex: 0] count])
	{
		
		ROI* roi=[[axViewROIList objectAtIndex: 0] objectAtIndex:0];
		
		float crossX,crossY;
		crossX=-axViewOrigin[0]/axViewSpace[0];
		crossY=-axViewOrigin[1]/axViewSpace[1];
		if(crossX<0)
			crossX=0;
		else if(crossX>imExtent[ 1]-imExtent[ 0])
			crossX=imExtent[ 1]-imExtent[ 0];
		if(crossY<0)
			crossY=0;
		else if(crossY>(imExtent[ 3]-imExtent[ 2] ))
			crossY=-(imExtent[ 3]-imExtent[ 2] );
		if([roi type]==tOval)
		{
			axCircleRect.origin.x = crossX;
			axCircleRect.origin.y = crossY;
			[roi setROIRect: axCircleRect];
		}
	}
	
	
	
	[crossAxiasView setIndex: 0 ];
	
}
- (void) resetSliders
{
	[oXRotateSlider setIntValue:0];
	[oViewRotateXText setFloatValue: 0];
	[oYRotateSlider setIntValue:0];
	[oViewRotateYText setFloatValue: 0];

	lastOViewXAngle=0;
	lastOViewYAngle=0;
	
	[cYRotateSlider setFloatValue: 0];	
	[cViewRotateYText setFloatValue: 0];

	[self updatePageSliders];		
}

- (void) roiChanged: (NSNotification*) note
{
	id sender = [note object];
	if(currentTool==4)
	{
		ROI* roi=(ROI*)sender;
		int roitype =[roi type];
		if(roitype!=tMesure)
		{
			[roi setROIMode:ROI_sleep];
		}
	}
	else if(currentTool==8)
	{
		if([[oViewROIList objectAtIndex: 0] containsObject: sender] )
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
							oViewUserTransform->TransformPoint(point,point);
							x=lround((point[0]-vtkOriginalX)/xSpacing);
							y=lround((point[1]-vtkOriginalY)/ySpacing);
							z=lround((point[2]-vtkOriginalZ)/zSpacing);
							if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
							{

								if(*(texture+j*[roi textureWidth]+i))
								{
									*(contrastVolumeData+z*imageSize+y*imageWidth+x)=marker;
									if((i+1)<[roi textureWidth]&&*(texture+j*[roi textureWidth]+i+1))
									{
										point[0] = curOriginX + i * curXSpacing+curXSpacing/2;
										point[1] = curOriginY + j * curYSpacing;
										point[2] = 0;
										oViewUserTransform->TransformPoint(point,point);
										x=lround((point[0]-vtkOriginalX)/xSpacing);
										y=lround((point[1]-vtkOriginalY)/ySpacing);
										z=lround((point[2]-vtkOriginalZ)/zSpacing);
										if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
											*(contrastVolumeData+z*imageSize+y*imageWidth+x) = marker;

									}
									if((j+1)<[roi textureHeight]&&*(texture+(j+1)*[roi textureWidth]+i))
									{
										point[0] = curOriginX + i * curXSpacing;
										point[1] = curOriginY + j * curYSpacing+curYSpacing/2;
										point[2] = 0;
										oViewUserTransform->TransformPoint(point,point);
										x=lround((point[0]-vtkOriginalX)/xSpacing);
										y=lround((point[1]-vtkOriginalY)/ySpacing);
										z=lround((point[2]-vtkOriginalZ)/zSpacing);
										if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
											*(contrastVolumeData+z*imageSize+y*imageWidth+x) = marker;
										
									}
									if((i+1)<[roi textureWidth] && (j+1)<[roi textureHeight] && *(texture+(j+1)*[roi textureWidth]+i))
									{
										point[0] = curOriginX + i * curXSpacing+curXSpacing/2;
										point[1] = curOriginY + j * curYSpacing+curYSpacing/2;
										point[2] = 0;
										oViewUserTransform->TransformPoint(point,point);
										x=lround((point[0]-vtkOriginalX)/xSpacing);
										y=lround((point[1]-vtkOriginalY)/ySpacing);
										z=lround((point[2]-vtkOriginalZ)/zSpacing);
										if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
											*(contrastVolumeData+z*imageSize+y*imageWidth+x) = marker;
										
									}
									if((i-1)>0&&(j+1)<[roi textureHeight]&&*(texture+(j+1)*[roi textureWidth]+i))
									{
										point[0] = curOriginX + i * curXSpacing-curXSpacing/2;
										point[1] = curOriginY + j * curYSpacing+curYSpacing/2;
										point[2] = 0;
										oViewUserTransform->TransformPoint(point,point);
										x=lround((point[0]-vtkOriginalX)/xSpacing);
										y=lround((point[1]-vtkOriginalY)/ySpacing);
										z=lround((point[2]-vtkOriginalZ)/zSpacing);
										if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
											*(contrastVolumeData+z*imageSize+y*imageWidth+x) = marker;
										
									}
								}
								else if(*(contrastVolumeData+z*imageSize+y*imageWidth+x)==marker)
									*(contrastVolumeData+z*imageSize+y*imageWidth+x)=0;
														

							}
						}
				}
			}
		}
	}
	else if(currentTool==6)
	{
		if([[oViewROIList objectAtIndex: 0] containsObject: sender] )
		{
			ROI* roi=(ROI*)sender;
			int roitype =[roi type];
			if(roitype==tMesure)
			{
				cPRViewCenter=[[[roi points] objectAtIndex: 0] point];
				NSPoint tempPt=[[[roi points] objectAtIndex: 1] point];
				float angle,length;
				
				tempPt.x-=cPRViewCenter.x;
				tempPt.y-=cPRViewCenter.y;
				tempPt.x*=oViewSpace[0];
				tempPt.y*=oViewSpace[1];
				
				if(tempPt.y == 0)
				{
					if(tempPt.x > 0)
						angle=90;
					else if(tempPt.x < 0)
						angle=-90;
					else 
						angle=0;
					length=tempPt.x;
				}
				else
				{
					if( tempPt.y < 0)
						angle = 180 + atan( (float) tempPt.x / (float) tempPt.y) / deg2rad;
					else 
						angle = atan( (float) tempPt.x / (float) tempPt.y) / deg2rad;
					length=tempPt.y/sin(atan( (float) tempPt.y/(float) tempPt.x  ));
				}
				length=fabs(length);
				
				cPRViewCenter.x = cPRViewCenter.x*oViewSpace[0]+oViewOrigin[0];
				cPRViewCenter.y = cPRViewCenter.y*oViewSpace[1]+oViewOrigin[1];				
				
				cViewTransform->Identity();
				cViewTransform->Translate(cPRViewCenter.x,cPRViewCenter.y,0 );
				cViewTransform->RotateZ(-angle);
				oViewToCViewZAngle=-angle;
				cViewTransform->RotateY(-90);
				[self updateCView];

				tempPt.x=-cViewOrigin[0]/cViewSpace[0]-cPRROIRect.size.width/2;
				tempPt.y=-cViewOrigin[1]/cViewSpace[1];

				
				cPRROIRect.origin=tempPt;
				cPRROIRect.size.height = length/cViewSpace[1];
				
				ROI* cViewROI=[[cViewROIList objectAtIndex: 0] objectAtIndex: 0];
				if(cViewROI)
				{
					[cViewROI setROIRect:cPRROIRect];
				}
				
			}
		}
		else if([[cViewROIList objectAtIndex:0] containsObject: sender])
		{
			ROI* roi=(ROI*)sender;
			int roitype =[roi type];
			if(roitype==tROI)
			{
				NSRect tempRect=[roi rect];
				cPRROIRect.origin.x = cPRROIRect.origin.x+cPRROIRect.size.width/2-tempRect.size.width/2;
				cPRROIRect.size.width = tempRect.size.width;
				[roi setROIRect: cPRROIRect];
			}
				
		}
	}
	else if(currentTool==7)
	{
		if([[oViewROIList objectAtIndex: 0] containsObject: sender] )
		{
			ROI* roi=(ROI*)sender;
			int roitype =[roi type];
			
			if(roitype==tArrow)
			{
				if([roi ROImode]== ROI_drawing)
				{
					if([[[note userInfo] objectForKey:@"action"] isEqualToString:@"mouseUp"] == YES)
					{
						if([[roi points] count]==3)
							[[roi points] removeLastObject];

					}
					else
					{
						MyPoint *oViewEndPoint=[[roi points] objectAtIndex:2];
						if(oViewEndPoint)
						{
							[[[roi points] objectAtIndex:0] setPoint: [oViewEndPoint point]];
						}
					}
				}

				cPRViewCenter=[[[roi points] objectAtIndex: 1] point];
				NSPoint tempPt=[[[roi points] objectAtIndex: 0] point];
				float angle,length;

				tempPt.x-=cPRViewCenter.x;
				tempPt.y-=cPRViewCenter.y;
				tempPt.x*=oViewSpace[0];
				tempPt.y*=oViewSpace[1];
				
				if(tempPt.y == 0)
				{
					if(tempPt.x > 0)
						angle=90;
					else if(tempPt.x < 0)
						angle=-90;
					else 
						angle=0;
					length=tempPt.x;
				}
				else
				{
					if( tempPt.y < 0)
						angle = 180 + atan( (float) tempPt.x / (float) tempPt.y) / deg2rad;
					else 
						angle = atan( (float) tempPt.x / (float) tempPt.y) / deg2rad;
					length=tempPt.y/sin(atan( (float) tempPt.y/(float) tempPt.x  ));
				}
				length=fabs(length);
				
				
				
				
				
				cPRViewCenter.x = cPRViewCenter.x*oViewSpace[0]+oViewOrigin[0];
				cPRViewCenter.y = cPRViewCenter.y*oViewSpace[1]+oViewOrigin[1];				
				oViewToCViewZAngle=-angle;	
				
				cViewTransform->Identity();
				cViewTransform->Translate(cPRViewCenter.x,cPRViewCenter.y,0 );
				cViewTransform->RotateZ(oViewToCViewZAngle);
				cViewTransform->RotateY(-90);
				
				axViewTransform->Identity();
				axViewTransform->Translate(cPRViewCenter.x,cPRViewCenter.y,0 );
				axViewTransform->RotateZ(oViewToCViewZAngle);
				axViewTransform->RotateX(90);
				
				[self updateCView];
				[self updateAxView];
				
				tempPt.x=-cViewOrigin[0]/cViewSpace[0]-cPRROIRect.size.width/2;
				tempPt.y=-cViewOrigin[1]/cViewSpace[1];
				
				

				
				ROI* cViewROI=[[cViewROIList objectAtIndex: 0] objectAtIndex: 0];
				if(cViewROI&&[cViewROI type]==tArrow)
				{
					NSMutableArray *points = [cViewROI points];
					NSPoint startPoint,endPoint;
					startPoint=tempPt;
					endPoint.x= tempPt.x;
					endPoint.y= tempPt.y+length/cViewSpace[1];
					
					[[points objectAtIndex:0] setPoint: endPoint];
					[[points objectAtIndex:1] setPoint: startPoint];
					
				}
				
			}
			[cPRView setIndex:0];
			
		}
		else if([[cViewROIList objectAtIndex:0] containsObject: sender])
		{
			ROI* roi=(ROI*)sender;
			int roitype =[roi type];
			if(roitype==tROI)
			{
				NSRect tempRect=[roi rect];
				cPRROIRect.origin.x = cPRROIRect.origin.x+cPRROIRect.size.width/2-tempRect.size.width/2;
				cPRROIRect.size.width = tempRect.size.width;
				[roi setROIRect: cPRROIRect];
			}
			else if(roitype==tArrow)
			{
				
				
				if([[cViewROIList objectAtIndex:0] count]>1)
				{
					isRemoveROIBySelf=1;
					[roi retain];
					[[cViewROIList objectAtIndex:0] removeAllObjects];
					[[cViewROIList objectAtIndex:0] addObject:roi];
					[roi release];
					isRemoveROIBySelf=0;
				}
				NSPoint start=[[[roi points] objectAtIndex: 1] point];
				if(start.x!= cViewArrowStartPoint.x||start.y!=cViewArrowStartPoint.y)
					[[[roi points] objectAtIndex: 1] setPoint:cViewArrowStartPoint];
				else
				{
					// caculate cViewToAxViewZAngle
					
					NSPoint tempPt=[[[roi points] objectAtIndex: 0] point];
					float angle;
					
					tempPt.x-=start.x;
					tempPt.y-=start.y;
					tempPt.x*=cViewSpace[0];
					tempPt.y*=cViewSpace[1];
					
					if(tempPt.y == 0)
					{
						if(tempPt.x > 0)
							angle=90;
						else if(tempPt.x < 0)
							angle=-90;
						else 
							angle=0;

					}
					else
					{
						if( tempPt.y < 0)
							angle = 180 + atan( (float) tempPt.x / (float) tempPt.y) / deg2rad;
						else 
							angle = atan( (float) tempPt.x / (float) tempPt.y) / deg2rad;

					}
					cViewToAxViewZAngle=angle;
					
					axViewTransform->Identity();
					axViewTransform->Translate(cPRViewCenter.x,cPRViewCenter.y,0 );
					axViewTransform->RotateZ(oViewToCViewZAngle);
					axViewTransform->RotateX(90+cViewToAxViewZAngle);
					
					[self updateAxView];
					
				}
				
				
			}
			
		}
	}
	else if((currentTool==5||isInCPROnlyMode) && curvedMPR2DPath &&[[oViewROIList objectAtIndex: 0] containsObject: sender])
	{
		if(currentPathMode==ROI_drawing)
		{
			if([[curvedMPR2DPath points] count]>[curvedMPR3DPath count])//add new end
			{
				float curXSpacing,curYSpacing;
				float curOriginX,curOriginY;
				double position[3];
				NSMutableArray  *path2DPoints=[curvedMPR2DPath points] ;
				curXSpacing = [[curvedMPR2DPath pix] pixelSpacingX];
				curYSpacing = [[curvedMPR2DPath pix] pixelSpacingY];
				curOriginX = [[curvedMPR2DPath pix] originX];
				curOriginY = [[curvedMPR2DPath pix] originY];
				
				position[0] = curOriginX + [[path2DPoints lastObject] point].x * curXSpacing;
				position[1] = curOriginY + [[path2DPoints lastObject] point].y * curYSpacing;
				position[2] = 0;
				oViewUserTransform->TransformPoint(position,position);

				CMIV3DPoint* new3DPoint=[[CMIV3DPoint alloc] init] ;
				[new3DPoint setX: position[0]];
				[new3DPoint setY: position[1]];
				[new3DPoint setZ: position[2]];
				[curvedMPR3DPath addObject: new3DPoint];
				[new3DPoint release];

			}
			else if([[curvedMPR2DPath points] count]<[curvedMPR3DPath count])//remove the end
			{
				[curvedMPR3DPath removeLastObject];
			}
			else 
			{
				if([curvedMPR2DPath ROImode]!=currentPathMode)
					[curvedMPR2DPath setROIMode:currentPathMode];
				return;
			}
			
		}
		else
		{
			if([[curvedMPR2DPath points] count]>[curvedMPR3DPath count])//user add new end
			{
				[[curvedMPR2DPath points] removeLastObject];
			}
			if([curvedMPR2DPath ROImode] == ROI_drawing)
				[curvedMPR2DPath setROIMode:currentPathMode];
		}

		[self updateCView];
	}
}
- (void) roiAdded: (NSNotification*) note
{
	id sender =[note object];

	
	if( sender&&(currentTool!=4))
	{
		if ([sender isEqual:originalView])
		{

			ROI * roi = [[note userInfo] objectForKey:@"ROI"];
			if(roi)
			{

				[roi setName: currentSeedName];

				float r, g, b;
				
				[currentSeedColor getRed:&r green:&g blue:&b alpha:0L];
				
				RGBColor c;
				
				c.red =(short unsigned int) (r * 65535.);
				c.green =(short unsigned int)( g * 65535.);
				c.blue = (short unsigned int)(b * 65535.);
				
				[roi setColor:c];
				if(currentTool==5||isInCPROnlyMode)
				{
					if(curvedMPR2DPath)
					{
						MyPoint* endPoint = 0L;
						endPoint = [[roi points] objectAtIndex:0];
						[endPoint retain];
						[[roi points] removeAllObjects];
						[roi setPoints: [curvedMPR2DPath points]];
						if(endPoint && currentPathMode==ROI_drawing)
							[[roi points] addObject: endPoint];
						[curvedMPR2DPath release];
					}
					curvedMPR2DPath=roi;
					
					[curvedMPR2DPath setThickness:1.0];
					
					[[NSUserDefaults standardUserDefaults] setFloat:defaultROIThickness forKey:@"ROIThickness"];
					[curvedMPR2DPath retain];
					isRemoveROIBySelf=1;
					unsigned int i;
					for ( i=0;i<[[oViewROIList objectAtIndex: 0] count];i++)
					{
						ROI* temproi=[[oViewROIList objectAtIndex: 0] objectAtIndex: i] ;
						if([temproi type] == tOPolygon)
						{
							if([temproi isEqual:roi]==NO)
							{
								[[oViewROIList objectAtIndex: 0] removeObjectAtIndex:i];
								i--;
							}
						}
					}
					
					isRemoveROIBySelf=0;						

				}
				else if(currentTool == 8)
				{
					uniIndex++;
					NSString *indexstr=[NSString stringWithFormat:@"%d",uniIndex];
					[roi setComments:indexstr];	
					[totalROIList addObject:roi];
				}
				else if(currentTool == 6)
				{
					//delete other
					unsigned int i;
					isRemoveROIBySelf=1;
					for ( i=0;i<[[oViewROIList objectAtIndex: 0] count];i++)
					{
						ROI* temproi=[[oViewROIList objectAtIndex: 0] objectAtIndex: i] ;
						if([temproi type] == tMesure)
						{
							if([temproi isEqual:roi]==NO)
							{
								[[oViewROIList objectAtIndex: 0] removeObjectAtIndex:i];
								i--;
							}
						}
					}

					[[cViewROIList objectAtIndex: 0] removeAllObjects];
					isRemoveROIBySelf=0;	
					
					DCMPix * curImage= [cViewPixList objectAtIndex:0];
					ROI* newROI=[[ROI alloc] initWithType: tROI :[curImage pixelSpacingX] :[curImage pixelSpacingY] : NSMakePoint( [curImage originX], [curImage originY])];
					[newROI setName:currentSeedName];
					cPRROIRect.size.width = 20;
	
					[[cViewROIList objectAtIndex: 0] addObject: newROI];
					[newROI release];
					//[newROI setROIRect:roiRect];
				}
				else if(currentTool == 7)
				{
					//delete other
					unsigned int i;
					isRemoveROIBySelf=1;
					for ( i=0;i<[[oViewROIList objectAtIndex: 0] count];i++)
					{
						ROI* temproi=[[oViewROIList objectAtIndex: 0] objectAtIndex: i] ;
						if([temproi type] == tArrow)
						{
							if([temproi isEqual:roi]==NO)
							{
								[[oViewROIList objectAtIndex: 0] removeObjectAtIndex:i];
								i--;
							}
						}
					}
					[[cViewROIList objectAtIndex: 0] removeAllObjects];
					[[axViewROIList objectAtIndex: 0] removeAllObjects];
					
					isRemoveROIBySelf=0;
					//change start and end
					MyPoint *lastPoint=[[MyPoint alloc] initWithPoint:[[[roi points] objectAtIndex:0] point] ];
					[[roi points] addObject:lastPoint];
					[lastPoint release];

					
					
					//create roi in cview and axview
					DCMPix * curImage= [cViewPixList objectAtIndex:0];
					ROI* newROI=[[ROI alloc] initWithType: tArrow :[curImage pixelSpacingX] :[curImage pixelSpacingY] : NSMakePoint( [curImage originX], [curImage originY])];
					[newROI setName:currentSeedName];
					lastPoint=[[MyPoint alloc] initWithPoint:NSMakePoint(0,0)];
					[[newROI points] addObject: lastPoint];
					[lastPoint release];
					lastPoint=[[MyPoint alloc] initWithPoint:NSMakePoint(0,0)];
					[[newROI points] addObject: lastPoint];
					[lastPoint release];
					
					[[cViewROIList objectAtIndex: 0] addObject: newROI];
					[newROI release];
					
					curImage= [axViewPixList objectAtIndex:0];
					newROI=[[ROI alloc] initWithType: tOval :[curImage pixelSpacingX] :[curImage pixelSpacingY] : NSMakePoint( [curImage originX], [curImage originY])];
					[newROI setName:currentSeedName];
					[[axViewROIList objectAtIndex: 0] addObject: newROI];
					[newROI release];
					
					axCircleRect.size.width=10;
					axCircleRect.size.height=10;
					

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
			if([totalROIList containsObject: roi]|| [totalROIList containsObject:[roi parentROI] ])
			{
				if(!isRemoveROIBySelf)
				{

					NSString * commentstr=[sender comments];
					if([commentstr length]==0)
						return;
					short unsigned int marker=(short unsigned int)[commentstr intValue];
					if(marker&&marker<=[totalROIList count])
					{
						[totalROIList removeObjectAtIndex: marker-1 ];
						unsigned int i;
						for(i = 0;i<[[oViewROIList objectAtIndex: 0] count];i++)
							{ 
							commentstr=[[[oViewROIList objectAtIndex: 0] objectAtIndex: i] comments];
							short unsigned int tempmarker=(short unsigned int)[commentstr intValue];
							if(tempmarker>marker)
								[[[oViewROIList objectAtIndex: 0] objectAtIndex: i] setComments: [NSString stringWithFormat:@"%d",tempmarker-1]];
							if(tempmarker==marker)
								[[[oViewROIList objectAtIndex: 0] objectAtIndex: i] setComments: [NSString stringWithFormat:@"%d",0]];
							}
							
						for(i = marker-1;i<[totalROIList count];i++)
							[[totalROIList objectAtIndex: i] setComments: [NSString stringWithFormat:@"%d",i+1]];
						long j,size;
						size =imageWidth * imageHeight * imageAmount;
						for(j=0;j<size;j++)
						{
							if(*(contrastVolumeData + j)==marker)
								*(contrastVolumeData + j)=0;
							else if (*(contrastVolumeData + j)>marker)
								*(contrastVolumeData + j)=*(contrastVolumeData + j)-1;
						}
						uniIndex--;
					}

				}
			}
			else if ([roi type]==tMesure)
			{
				if([originalView isEqual:[roi curView]])
				{
					isRemoveROIBySelf=1;
					[[cViewROIList objectAtIndex:0] removeAllObjects];
					[cPRView setIndex: 0];
					[[axViewROIList objectAtIndex: 0] removeAllObjects];
					[crossAxiasView setIndex: 0];
					isRemoveROIBySelf=0;
				}
				
					
			}
			else if ([roi type]==tArrow)
			{
				if([originalView isEqual:[roi curView]])
				{
					isRemoveROIBySelf=1;
					[[cViewROIList objectAtIndex:0] removeAllObjects];
					[cPRView setIndex: 0];
					[[axViewROIList objectAtIndex: 0] removeAllObjects];
					[crossAxiasView setIndex: 0];
					isRemoveROIBySelf=0;
				}
				else if(!isRemoveROIBySelf&&[cPRView isEqual:[roi curView]])
				{
					
					unsigned int i;
					isRemoveROIBySelf=1;
					for ( i=0;i<[[oViewROIList objectAtIndex: 0] count];i++)
					{
						ROI* temproi=[[oViewROIList objectAtIndex: 0] objectAtIndex: i] ;
						if([temproi type] == tArrow)
						{
							[[oViewROIList objectAtIndex: 0] removeObjectAtIndex:i];
							i--;
						}
					}		
					[originalView setIndex: 0];
					[[axViewROIList objectAtIndex: 0] removeAllObjects];
					[crossAxiasView setIndex: 0];
					isRemoveROIBySelf=0;
					
				}
				
				
				
			}
			
			else if (!isRemoveROIBySelf&&[roi type]==tROI)
			{
				
				if([cPRView isEqual:[roi curView]])
				{

					isRemoveROIBySelf=1;

				unsigned int i;
					for ( i=0;i<[[oViewROIList objectAtIndex: 0] count];i++)
					{
						ROI* temproi=[[oViewROIList objectAtIndex: 0] objectAtIndex: i] ;
						if([temproi type] == tMesure)
						{
							[[oViewROIList objectAtIndex: 0] removeObjectAtIndex:i];
							i--;
						}
					}
					isRemoveROIBySelf=0;
					[originalView setIndex: 0];
				}
			
			}		
			else if (!isRemoveROIBySelf&&[roi type]==tOPolygon)
			{
				
				if([originalView isEqual:[roi curView]])
				{
					
					[curvedMPR2DPath release];
					curvedMPR2DPath=0L;
					[curvedMPR3DPath removeAllObjects];
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
	for(i=0;i<[totalROIList count];i++)
		[[totalROIList objectAtIndex:i] setROIRect:rect];
	
	for(y=0;y<height;y++)
		for(x=0;x<width;x++)
		{
			marker=*(im+y*width+x);
			if(marker>0&&marker<=[totalROIList count])
			{
				roi=[totalROIList objectAtIndex:marker-1];
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
			
	for(i=0;i<[totalROIList count];i++)
	{
		roi=[totalROIList objectAtIndex:i];
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
			[newROI setParentROI:roi];
			[roiList addObject:newROI];
			[newROI release];
			free(textureBuffer);
		}
	}
	
}


- (void) defaultToolModified: (NSNotification*) note
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
		if( tag > 5)
			tag = 20;
		[originalView setCurrentTool: tag];
		[cPRView setCurrentTool: tag];
		[crossAxiasView setCurrentTool:tag];
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
		
		
		if( [oViewPixList containsObject: otherPix])
		{
			//if( iww != [originalView curWW] || iwl != [originalView curWL])
				[originalView setIndex: 0 ];
			if( iww != [cPRView curWW] || iwl != [cPRView curWL])
				[cPRView setWLWW:iwl :iww];					
			if( iww != [crossAxiasView curWW] || iwl != [crossAxiasView curWL])
				[crossAxiasView setWLWW:iwl :iww];
	
		}
		else if( [cViewPixList containsObject: otherPix])
		{
			if( iww != [originalView curWW] || iwl != [originalView curWL])
				[originalView setWLWW:iwl :iww];				
			if( iww != [crossAxiasView curWW] || iwl != [crossAxiasView curWL])
				[crossAxiasView setWLWW:iwl :iww];	
		}
		else if( [axViewPixList containsObject: otherPix])
		{
			if( iww != [originalView curWW] || iwl != [originalView curWL])
				[originalView setWLWW:iwl :iww];				
			if( iww != [cPRView curWW] || iwl != [cPRView curWL])
				[cPRView setWLWW:iwl :iww];		
		}
		
	}
	
	
}
- (void) crossMove:(NSNotification*) note
{

   if([[[note userInfo] objectForKey:@"action"] isEqualToString:@"dragged"] == YES)
	{


		float oX,oY;
		vtkImageData	*tempIm;
		int				imExtent[ 6];
		double		space[ 3], origin[ 3];
		tempIm = oViewSlice->GetOutput();
		tempIm->Update();
		tempIm->GetWholeExtent( imExtent);
		tempIm->GetSpacing( space);
		tempIm->GetOrigin( origin);	
		
		[originalView getCrossCoordinates: &oX  :&oY];
		oY=-oY;
		oX=oX*space[0]+origin[0];
		oY=oY*space[1]+origin[1];
		if(!(oX==0&&oY==0))
		{
			oViewUserTransform->Translate(oX,oY,0);
		   if(currentTool!=5&&!isInCPROnlyMode)
			   [self cAndAxViewReset];
			[axImageSlider setMaxValue: ([axImageSlider maxValue]-oY)];
			[axImageSlider setMinValue: ([axImageSlider minValue]-oY)];

			[cImageSlider setMaxValue: ([cImageSlider maxValue]-oX)];
			[cImageSlider setMinValue: ([cImageSlider minValue]-oX)];
			[cYRotateSlider setFloatValue: 0];
		}
	}
	if([[[note userInfo] objectForKey:@"action"] isEqualToString:@"mouseUp"] == YES)
	{	
		float angle= [originalView angle];
		
		if(angle!=0)
			[self rotateZOView:angle];
		else
			[self updateOView];//update oViewSpace and oViewOrigin for other operation , such as root seeds planting
		[originalView setMPRAngle: 0.0];
	}
}
- (void) cAndAxViewReset
{

	axViewTransform->Identity();
	axViewTransform->RotateX(90);
	if(currentTool!=5&&!isInCPROnlyMode)
		[axImageSlider setFloatValue: 0];
	cViewTransform->Identity();
	cViewTransform->RotateY(-90);
	[cImageSlider setFloatValue: 0];
	[cYRotateSlider setFloatValue:0];
	cPRViewCenter.x=0;
	cPRViewCenter.y=0;
	oViewToCViewZAngle=0;
	cViewToAxViewZAngle=0;	
	[self updateCView];
	[self updateAxView];
}
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	if(!isInCPROnlyMode && [seedsList isEqual:tableView])
	{
		return [contrastList count];
	}
	else if(isInCPROnlyMode && [centerlinesList isEqual: tableView ])
	{
		return [cpr3DPaths count];
	}
	return 0;
	
}

- (id)tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(int)row
{
	if( originalViewController == 0L) return 0L;
	if(!isInCPROnlyMode && [seedsList isEqual:tableView])
	{
		
		if( [[tableColumn identifier] isEqualToString:@"Index"])
		{
			return [NSString stringWithFormat:@"%d", row+1];
		} 
		if( [[tableColumn identifier] isEqualToString:@"Name"])
		{
			return [[contrastList objectAtIndex:row] objectForKey:@"Name"];
		}
	}
	else if(isInCPROnlyMode && [centerlinesList isEqual:tableView])
	{
		
		if( [[tableColumn identifier] isEqualToString:@"Length"])
		{
			return [NSString stringWithFormat:@"%d", [[cpr3DPaths objectAtIndex: row] count]];
		} 
		if( [[tableColumn identifier] isEqualToString:@"Name"])
		{
			return [centerlinesNameArrays objectAtIndex:row];
		}
	}
	
	
	return 0L;
}
- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
	if( originalViewController == 0L) return;
	if(!isInCPROnlyMode && [seedsList isEqual:aTableView])
	{
		
		if( [[aTableColumn identifier] isEqualToString:@"Name"])
		{
			if([anObject length]>0)
			{
				NSString* newname, *oldname;
				newname=anObject;
				oldname=[[contrastList objectAtIndex:rowIndex] objectForKey:@"Name"];
				unsigned i;
				ROI* temproi;
				for(i=0;i<[totalROIList count];i++)
				{
					temproi=[totalROIList objectAtIndex: i];
					if([[temproi name]isEqualToString:oldname])
						[temproi setName: newname];
				}
				[[contrastList objectAtIndex:rowIndex] setValue:newname forKey:@"Name"];
			}
		}		
		
	}
	else if(isInCPROnlyMode && [centerlinesList isEqual:aTableView])
	{
		if( [[aTableColumn identifier] isEqualToString:@"Name"])
		{
			if([anObject length]>0)
			{
				
				[centerlinesNameArrays removeObjectAtIndex:rowIndex];
				[centerlinesNameArrays insertObject:anObject atIndex:rowIndex];
			}
		}		
	}
}

- (IBAction)selectAContrast:(id)sender
{
	unsigned int row = [seedsList selectedRow];
	NSString *name;
	NSColor *color;
	NSNumber *number;

	if(row>=0&&row<[contrastList count])
	{
		currentStep = row;
		name = [[contrastList objectAtIndex: row] objectForKey:@"Name"] ;
		currentSeedName=name;
		[seedName setStringValue:name];
		color =[[contrastList objectAtIndex: row] objectForKey:@"Color"] ;
		currentSeedColor=color;
		[seedColor setColor:color];
		//load brush
		number=[[contrastList objectAtIndex: row] objectForKey:@"BrushWidth"] ;
		[brushWidthText setIntValue:[number intValue]];
		[brushWidthSlider setFloatValue: [number floatValue]];
		[[NSUserDefaults standardUserDefaults] setFloat:[number floatValue] forKey:@"ROIRegionThickness"];
		[brushStatSegment setSelectedSegment:0];
		[originalView setEraserFlag:0];
		//chang current tool
		number=[[contrastList objectAtIndex: row] objectForKey:@"CurrentTool"] ;
		[self changeCurrentTool:[number intValue]];
	
	}	
}
- (IBAction)setBrushWidth:(id)sender
{
	[brushWidthText setIntValue: [sender intValue]];
		
	[[NSUserDefaults standardUserDefaults] setFloat:[sender floatValue] forKey:@"ROIRegionThickness"];
	unsigned int row = [seedsList selectedRow];

	if(row>=0&&row<[contrastList count])
	{
		[[contrastList objectAtIndex: row] setObject: [NSNumber numberWithFloat:[sender floatValue]] forKey:@"BrushWidth"];
	}
	[self changeCurrentTool:8];
		
}
- (IBAction)setBrushMode:(id)sender
{
	[originalView setEraserFlag: [sender selectedSegment]];
}
- (IBAction)crossShow:(id)sender
{
	if([crossShowButton state]== NSOnState)
	{
		oViewUserTransform->Translate(0,0,0.5);
		oViewUserTransform->Translate(0,0,-0.5);
		[self updateOView];
	}
	else
	{
		[originalView setCrossCoordinates:-9999 :-9999 :YES];
	}

}

- (IBAction)covertRegoinToSeeds:(id)sender
{
	if(currentTool==6)
	{
		ROI* roi=[[cViewROIList objectAtIndex: 0] objectAtIndex: 0];
		if(roi&&[roi type]== tROI)
		{
			NSRect tempRect=[roi rect];
			uniIndex++;
			NSString *indexstr=[NSString stringWithFormat:@"%d",uniIndex];
			[roi setComments:indexstr];	
			[totalROIList addObject:roi];
			
			int x,y,z;
			float curXSpacing,curYSpacing;
			float curOriginX,curOriginY;
			short unsigned int marker=uniIndex;
			curXSpacing=cViewSpace[0];
			curYSpacing=cViewSpace[1];
			curOriginX= cViewOrigin[0];
			curOriginY= cViewOrigin[1];
			if(tempRect.size.width<0)
				curOriginX = (tempRect.origin.x+tempRect.size.width)*curXSpacing+curOriginX;		

			else
				curOriginX = tempRect.origin.x*curXSpacing+curOriginX;
				
			if(tempRect.size.height<0)
				curOriginY = (tempRect.origin.y+tempRect.size.height)*curYSpacing+curOriginY;				
			else
				curOriginY = tempRect.origin.y*curYSpacing+curOriginY;	
			int i,j,height,width;
			float point[3];
			int minx,maxx,miny,maxy,minz,maxz;
			minx=imageWidth;
			maxx=0;
			miny=imageHeight;
			maxy=0;
			minz=imageAmount;
			maxz=0;
			height=3*abs((int)tempRect.size.height);
			width=3*abs((int)tempRect.size.width );
			//step=0.3 pixel!	
			for(j=0;j<height;j++)
				for(i=0;i<width;i++)
				{
					point[0] = curOriginX + i * curXSpacing/3;
					point[1] = curOriginY + j * curYSpacing/3;
					point[2] = 0;
					cViewTransform->TransformPoint(point,point);
					x=lround((point[0]-vtkOriginalX)/xSpacing);
					y=lround((point[1]-vtkOriginalY)/ySpacing);
					z=lround((point[2]-vtkOriginalZ)/zSpacing);
					if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
					{
						*(contrastVolumeData+z*imageSize+y*imageWidth+x) = marker;
						if(minx>x)
							minx=x;
						if(maxx<x)
							maxx=x;
						if(miny>y)
							miny=y;
						if(maxy<y)
							maxy=y;
						if(minz>z)
							minz=z;
						if(maxz<z)
							maxz=z;
						
							
					}
					
				}
			
			[self fixHolesInBarrier: minx :maxx :miny :maxy :minz :maxz :marker];
			
			oViewUserTransform->Translate(0,0,0.5);
			oViewUserTransform->Translate(0,0,-0.5);
			[self updateOView];
				
		}
	}
	else if(currentTool==7&&[[axViewROIList objectAtIndex: 0] count])
	{
		
		ROI* roi=[[axViewROIList objectAtIndex: 0] objectAtIndex: 0];
		if(roi&&[roi type]== tOval)
		{
			//creat normal seeds with current kind
			NSRect tempRect=[roi rect];
			tempRect.origin.x-=tempRect.size.width/2;
			tempRect.origin.y-=tempRect.size.height/2;
			
			float rv, gv, bv;
			[currentSeedColor getRed:&rv green:&gv blue:&bv alpha:0L];
			RGBColor c;
			c.red =(short unsigned int) (rv * 65535.);
			c.green =(short unsigned int)( gv * 65535.);
			c.blue = (short unsigned int)(bv * 65535.);
	

			uniIndex++;
			NSString *indexstr=[NSString stringWithFormat:@"%d",uniIndex];
			DCMPix* curImage= [axViewPixList objectAtIndex:0];
			ROI* kernelSeedROI=[[ROI alloc] initWithType: tOval :[curImage pixelSpacingX] :[curImage pixelSpacingY] : NSMakePoint( [curImage originX], [curImage originY])];
			[kernelSeedROI setName:currentSeedName];
			[kernelSeedROI setComments:indexstr];	
			[kernelSeedROI setColor:c];
			[totalROIList addObject:kernelSeedROI];
			float curXSpacing,curYSpacing;
			float curOriginX,curOriginY;
			short unsigned int marker;
			marker=uniIndex;
			curXSpacing=axViewSpace[0];
			curYSpacing=axViewSpace[1];
			curOriginX= axViewOrigin[0];
			curOriginY= axViewOrigin[1];
	
			if(tempRect.size.width<0)
				curOriginX = (tempRect.origin.x+tempRect.size.width)*curXSpacing+curOriginX;		
			
			else
				curOriginX = tempRect.origin.x*curXSpacing+curOriginX;
			
			if(tempRect.size.height<0)
				curOriginY = (tempRect.origin.y+tempRect.size.height)*curYSpacing+curOriginY;				
			else
				curOriginY = tempRect.origin.y*curYSpacing+curOriginY;	
			
			int i,j,height,width;
			int x,y,z;
			float point[3];

			height=3*abs((int)tempRect.size.height);
			width=3*abs((int)tempRect.size.width );
			float x0,y0,a,b;
			a=curXSpacing*fabs(tempRect.size.width)/2;
			b=curYSpacing*fabs(tempRect.size.height)/2;	
			x0= curOriginX+a;
			y0= curOriginY+b;
			a=a*a;
			b=b*b;
			float maxSpacing=sqrt(xSpacing*xSpacing+ySpacing*ySpacing+zSpacing*zSpacing);
			//step=0.3 pixel!	
			for(j=0;j<height;j++)
				for(i=0;i<width;i++)
				{
					point[0] = curOriginX + i * curXSpacing/3;
					point[1] = curOriginY + j * curYSpacing/3;
					point[2] = -maxSpacing;
					if((point[0]-x0)*(point[0]-x0)*b+(point[1]-y0)*(point[1]-y0)*a<=a*b)
					{
						axViewTransform->TransformPoint(point,point);
						x=lround((point[0]-vtkOriginalX)/xSpacing);
						y=lround((point[1]-vtkOriginalY)/ySpacing);
						z=lround((point[2]-vtkOriginalZ)/zSpacing);
						if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
						{
							*(contrastVolumeData+z*imageSize+y*imageWidth+x) = marker;
			
							
						}
					}
					
				}				
					
					
					
			//create barrier seeds
			tempRect=[roi rect];
			tempRect.origin.x-=tempRect.size.width;
			tempRect.origin.y-=tempRect.size.height;
			tempRect.size.width+=tempRect.size.width;
			tempRect.size.height+=tempRect.size.height;
			unsigned int ii;
			NSColor *color=0L;
			for(ii=0;ii<[contrastList count];ii++)
			{
				if([[[contrastList objectAtIndex: ii] objectForKey:@"Name"] isEqualToString:@"barrier"])
					color=[[contrastList objectAtIndex: ii] objectForKey:@"Color"] ;	
			}
			if(color)
				[color getRed:&rv green:&gv blue:&bv alpha:0L];
			else
			{
				rv=0.5;
				gv=0.0;
				bv=0.5;
			}

			c.red =(short unsigned int) (rv * 65535.);
			c.green =(short unsigned int)( gv * 65535.);
			c.blue = (short unsigned int)(bv * 65535.);
			
			uniIndex++;
			indexstr=[NSString stringWithFormat:@"%d",uniIndex];
			NSString *roiName = [NSString stringWithString:@"barrier"];

			[roi setName: roiName];
			[roi setComments:indexstr];	
			[roi setColor:c];
			[totalROIList addObject:roi];

			marker=uniIndex;
			curXSpacing=axViewSpace[0];
			curYSpacing=axViewSpace[1];
			curOriginX= axViewOrigin[0];
			curOriginY= axViewOrigin[1];
			if(tempRect.size.width<0)
				curOriginX = (tempRect.origin.x+tempRect.size.width)*curXSpacing+curOriginX;		
			
			else
				curOriginX = tempRect.origin.x*curXSpacing+curOriginX;
			
			if(tempRect.size.height<0)
				curOriginY = (tempRect.origin.y+tempRect.size.height)*curYSpacing+curOriginY;				
			else
				curOriginY = tempRect.origin.y*curYSpacing+curOriginY;	

			int minx,maxx,miny,maxy,minz,maxz;
			minx=imageWidth;
			maxx=0;
			miny=imageHeight;
			maxy=0;
			minz=imageAmount;
			maxz=0;
			
			height=3*abs((int)tempRect.size.height);
			width=3*abs((int)tempRect.size.width );
			
			a=curXSpacing*fabs(tempRect.size.width)/2;
			b=curYSpacing*fabs(tempRect.size.height)/2;	
			x0= curOriginX+a;
			y0= curOriginY+b;
			a=a*a;
			b=b*b;
			
			//step=0.3 pixel!	
			for(j=0;j<height;j++)
				for(i=0;i<width;i++)
				{
					point[0] = curOriginX + i * curXSpacing/3;
					point[1] = curOriginY + j * curYSpacing/3;
					point[2] = 0;
					if((point[0]-x0)*(point[0]-x0)*b+(point[1]-y0)*(point[1]-y0)*a<=a*b)
					{
						axViewTransform->TransformPoint(point,point);
						x=lround((point[0]-vtkOriginalX)/xSpacing);
						y=lround((point[1]-vtkOriginalY)/ySpacing);
						z=lround((point[2]-vtkOriginalZ)/zSpacing);
						if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)
						{
							*(contrastVolumeData+z*imageSize+y*imageWidth+x) = marker;
							if(minx>x)
								minx=x;
							if(maxx<x)
								maxx=x;
							if(miny>y)
								miny=y;
							if(maxy<y)
								maxy=y;
							if(minz>z)
								minz=z;
							if(maxz<z)
								maxz=z;
							
							
						}
					}
					
				}
					
				[self fixHolesInBarrier: minx :maxx :miny :maxy :minz :maxz :marker];
				
				oViewUserTransform->Translate(0,0,0.5);
				oViewUserTransform->Translate(0,0,-0.5);
				[self updateOView];
						
		}
	}

	
}

- (void) fixHolesInBarrier:(int)minx :(int)maxx :(int)miny :(int)maxy :(int)minz :(int)maxz :(short unsigned int) marker
{
	int x,y,z;
	if(minx<maxx&&miny<maxy&&minz<maxz)
	{
		for(z=minz;z<=maxz;z++)
			for(y=miny;y<=maxy;y++)
				for(x=minx;x<=maxx;x++)
					if(*(contrastVolumeData+z*imageSize+y*imageWidth+x) == marker)
					{
						//x,y direction
						if((y+1)<=maxy&& (*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x) != marker))
						{
							if((x-1)>=minx && (*(contrastVolumeData+z*imageSize+y*imageWidth+x-1) != marker)  && (*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x-1) == marker))
								*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x) = marker;
							
							
							else if( (x+1)<=maxx && (*(contrastVolumeData+z*imageSize+y*imageWidth+x+1) != marker)  && (*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x+1) == marker))
								*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x) = marker;
						}
						
						//x,z direction
						if((z+1)<=maxz&& (*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x) != marker))
						{
							if((x-1)>=minx && (*(contrastVolumeData+z*imageSize+y*imageWidth+x-1) != marker)  && (*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x-1) == marker))
								*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x) = marker;
							
							
							else if( (x+1)<=maxx && (*(contrastVolumeData+z*imageSize+y*imageWidth+x+1) != marker)  && (*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x+1) == marker))
								*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x) = marker;
						}		
						
						//y,z direction
						if((z+1)<=maxz&& (*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x) != marker))
						{
							if((y-1)>=miny && (*(contrastVolumeData+z*imageSize+(y-1)*imageWidth+x) != marker)  && (*(contrastVolumeData+(z+1)*imageSize+(y-1)*imageWidth+x) == marker))
								*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x) = marker;
							
							
							else if( (y+1)<=maxy && (*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x) != marker)  && (*(contrastVolumeData+(z+1)*imageSize+(y+1)*imageWidth+x) == marker))
								*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x) = marker;
						}	
						//x,y,z direction
						if((z+1)<=maxz&& (*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x) != marker))
						{
							if((y-1)>=miny && (x-1)>minx && (*(contrastVolumeData+z*imageSize+(y-1)*imageWidth+x) != marker) && (*(contrastVolumeData+z*imageSize+y*imageWidth+x-1) != marker)  && (*(contrastVolumeData+(z+1)*imageSize+(y-1)*imageWidth+x-1) == marker))
								*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x) = marker;
							
							
							else if( (y+1)<=maxy && (x-1)>minx && (*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x) != marker) && (*(contrastVolumeData+z*imageSize+y*imageWidth+x-1) != marker) && (*(contrastVolumeData+(z+1)*imageSize+(y+1)*imageWidth+x-1) == marker))
								*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x) = marker;
							else if((y-1)>=miny && (x+1)<maxx && (*(contrastVolumeData+z*imageSize+(y-1)*imageWidth+x) != marker) && (*(contrastVolumeData+z*imageSize+y*imageWidth+x+1) != marker)  && (*(contrastVolumeData+(z+1)*imageSize+(y-1)*imageWidth+x+1) == marker))
								*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x) = marker;
							
							
							else if( (y+1)<=maxy && (x+1)<maxx && (*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x) != marker) && (*(contrastVolumeData+z*imageSize+y*imageWidth+x+1) != marker) && (*(contrastVolumeData+(z+1)*imageSize+(y+1)*imageWidth+x+1) == marker))
								*(contrastVolumeData+(z+1)*imageSize+y*imageWidth+x) = marker;
							
						}	
						//leak from vertex connection
						if((z-1)>=minz&& (*(contrastVolumeData+(z-1)*imageSize+y*imageWidth+x) != marker))
						{
							if((x-1)>=minx && (y-1)>=miny &&  (*(contrastVolumeData+z*imageSize+y*imageWidth+x-1) == marker) && (*(contrastVolumeData+z*imageSize+(y-1)*imageWidth+x) == marker) && (*(contrastVolumeData+z*imageSize+(y-1)*imageWidth+x-1) != marker) && (*(contrastVolumeData+(z-1)*imageSize+(y-1)*imageWidth+x-1) == marker) && (*(contrastVolumeData+(z-1)*imageSize+y*imageWidth+x-1) == marker) && (*(contrastVolumeData+(z-1)*imageSize+(y-1)*imageWidth+x) == marker))
								*(contrastVolumeData+(z-1)*imageSize+y*imageWidth+x) = marker;
							else if((x+1)<=maxx && (y-1)>=miny &&  (*(contrastVolumeData+z*imageSize+y*imageWidth+x+1) == marker) && (*(contrastVolumeData+z*imageSize+(y-1)*imageWidth+x) == marker) && (*(contrastVolumeData+z*imageSize+(y-1)*imageWidth+x+1) != marker) && (*(contrastVolumeData+(z-1)*imageSize+(y-1)*imageWidth+x+1) == marker) && (*(contrastVolumeData+(z-1)*imageSize+y*imageWidth+x+1) == marker) && (*(contrastVolumeData+(z-1)*imageSize+(y-1)*imageWidth+x) == marker))
								*(contrastVolumeData+(z-1)*imageSize+y*imageWidth+x) = marker;
							else if((x-1)>=minx && (y+1)<=maxy &&  (*(contrastVolumeData+z*imageSize+y*imageWidth+x-1) == marker) && (*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x) == marker) && (*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x-1) != marker) && (*(contrastVolumeData+(z-1)*imageSize+(y+1)*imageWidth+x-1) == marker) && (*(contrastVolumeData+(z-1)*imageSize+y*imageWidth+x-1) == marker) && (*(contrastVolumeData+(z-1)*imageSize+(y+1)*imageWidth+x) == marker))
								*(contrastVolumeData+(z-1)*imageSize+y*imageWidth+x) = marker;
							else if((x+1)<=maxx && (y+1)<=maxy &&  (*(contrastVolumeData+z*imageSize+y*imageWidth+x+1) == marker) && (*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x) == marker) && (*(contrastVolumeData+z*imageSize+(y+1)*imageWidth+x+1) != marker) && (*(contrastVolumeData+(z-1)*imageSize+(y+1)*imageWidth+x+1) == marker) && (*(contrastVolumeData+(z-1)*imageSize+y*imageWidth+x+1) == marker) && (*(contrastVolumeData+(z-1)*imageSize+(y+1)*imageWidth+x) == marker))
								*(contrastVolumeData+(z-1)*imageSize+y*imageWidth+x) = marker;
							
							
						}	
						
						
					}
	}
}
- (float*) caculateStraightCPRImage :(int*)pwidth :(int*)pheight 
{
	float *im=0L;
	int width;
	double position[3],position1[3],position2[3];;
	
	cViewSpace[0]=cViewSpace[1]=xSpacing;
	*pwidth=width=40/cViewSpace[0];//here we use fixed width( 40mm )
		
// create a narrow 3d ribbon from the centerline and use this ribbon to get cross-section line from each pair of point along this ribbon 
	pathKeyPoints = vtkPoints::New();
	int pointNumber=[curvedMPR3DPath count];
	CMIV3DPoint* a3DPoint;
	int i,j;
	for(i=0;i<pointNumber;i++)
	{
		a3DPoint=[curvedMPR3DPath objectAtIndex: i];
		position[0]=[a3DPoint x];
		position[1]=[a3DPoint y];
		position[2]=[a3DPoint z];
		
		pathKeyPoints->InsertPoint(i,position);
		
	}
	
	
	centerLinePath = vtkCellArray::New();
	centerLinePath->InsertNextCell(pointNumber);
	for(i=0;i<pointNumber;i++)
		centerLinePath->InsertCellPoint(i);
	
	
	centerLinePolyData = vtkPolyData::New() ;
	centerLinePolyData->SetPoints(pathKeyPoints);
	centerLinePolyData->SetLines(centerLinePath);
	/* failed when compile, vtkKochanekSpline is not included in the Osirix static library.
	kSpline=vtkKochanekSpline::New();
	kSpline->SetDefaultTension(0.5);
	kSpline->SetDefaultBias(0);
	kSpline->SetDefaultContinuity(0);
	*/
	splineFilter= vtkSplineFilter::New();
	splineFilter->SetInput(centerLinePolyData);
	splineFilter->SetSubdivideToLength();
	splineFilter->SetLength(cViewSpace[1]/6);
	//splineFilter->SetSpline(kSpline);

	//vtkSplineFilter didn't give equal length centerline, have to resample the curve to create equal subdivision
	vtkPolyData         *tempPolydata;
	//tempPolydata=splineFilter->GetOutput();
	//tempPolydata->Update();	
	tempPolydata=centerLinePolyData;
	pointNumber=tempPolydata->GetPoints()->GetNumberOfPoints();
	smoothedCenterlinePoints = vtkPoints::New();
	tempPolydata->GetPoint(0,position1);
	float steplen,len=0,prelen=0;
	int index=0;
	for(i=1;i<pointNumber;i++)
	{
		tempPolydata->GetPoint(i,position2);
		steplen = sqrt( (position2[0]-position1[0])*(position2[0]-position1[0]) + (position2[1]-position1[1])*(position2[1]-position1[1]) + (position2[2]-position1[2])*(position2[2]-position1[2]) );
	
		while((len+steplen-prelen)>=cViewSpace[1])
		{
			prelen+=cViewSpace[1];
			for(j=0;j<3;j++)
			{
				position[j]=position1[j]+(position2[j]-position1[j])*(prelen-len)/steplen;
			}
			smoothedCenterlinePoints->InsertPoint(index,position);
			index++;
			
		}
		len+=steplen;
		position1[0]=position2[0];
		position1[1]=position2[1];
		position1[2]=position2[2];
	}
	smoothedCenterlineCells = vtkCellArray::New();
	smoothedCenterlineCells->InsertNextCell(index);
	for(i=0;i<index;i++)
		smoothedCenterlineCells->InsertCellPoint(i);
	smoothedCenterlinePD = vtkPolyData::New() ;
	smoothedCenterlinePD->SetPoints(smoothedCenterlinePoints);
	smoothedCenterlinePD->SetLines(smoothedCenterlineCells);	
	
	//create a narrow ribbon along the smoothed centerline
	if(narrowRibbonofCenterline)
		narrowRibbonofCenterline->Delete();
	narrowRibbonofCenterline= vtkRibbonFilter::New();
	narrowRibbonofCenterline->SetInput(smoothedCenterlinePD);
	narrowRibbonofCenterline->SetWidth(cViewSpace[0]/2);
	narrowRibbonofCenterline->SetWidthFactor(1.0);
	float rotateangle=[cYRotateSlider floatValue];
	if(rotateangle<0)
		rotateangle+=360;
	narrowRibbonofCenterline->SetAngle(rotateangle);
	
	ribbonPolydata=narrowRibbonofCenterline->GetOutput();
	ribbonPolydata->Update();
	*pheight = pointNumber = (ribbonPolydata->GetPoints()->GetNumberOfPoints())/2;

	// update axview's slider
	float path3DLength=(pointNumber-1)*cViewSpace[1];
	[axImageSlider setMinValue: 0];
	[axImageSlider setMaxValue: path3DLength];
	if([axImageSlider floatValue]>path3DLength)
		[axImageSlider setFloatValue: path3DLength];
	else if([axImageSlider floatValue]<0)
		[axImageSlider setFloatValue: 0];
	
	
	im=(float*)malloc(sizeof(float)*width*pointNumber);
	if(!im)
		return 0L;
	
	

	int x,y,z;
	vtkIdType ptId;
	int pixelindex=0;
	float fposition[3];
	
	for(ptId=0;ptId<pointNumber;ptId++)
	{
		
		ribbonPolydata->GetPoint(ptId*2,position1);
		ribbonPolydata->GetPoint(ptId*2+1,position2);
		
		
		for(i=0;i<width;i++)
		{
			int ii;
			for(ii=0;ii<3;ii++)
				position[ii]=position1[ii]+(position2[ii]-position1[ii])*(0.5+(float)(i-(int)(width/2)));
			if(interpolationMode)
			{
				fposition[0]=(position[0]-vtkOriginalX)/xSpacing;
				fposition[1]=(position[1]-vtkOriginalY)/ySpacing;
				fposition[2]=(position[2]-vtkOriginalZ)/zSpacing;
				*(im+pixelindex)=[self TriCubic:fposition: volumeData: imageWidth: imageHeight: imageAmount];
			}
			else
			{
				x = lround((position[0]-vtkOriginalX)/xSpacing);
				y = lround((position[1]-vtkOriginalY)/ySpacing);
				z = lround((position[2]-vtkOriginalZ)/zSpacing);
				if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)		  
					*(im+pixelindex)=*(volumeData + imageSize*z + imageWidth*y+x);
				else
					*(im+pixelindex)=minValueInSeries;
			}
			 
			pixelindex++;
		}
		
	}


	pathKeyPoints->Delete();
	centerLinePath->Delete();
	centerLinePolyData->Delete();
	splineFilter->Delete();
	smoothedCenterlinePoints->Delete();
	smoothedCenterlineCells->Delete();
	smoothedCenterlinePD->Delete();


	
	return im;	

}
- (float*) caculateCurvedMPRImage :(int*)pwidth :(int*)pheight
{
	
	float* im=0L;
	int i;
	int pointNumber;
	double position[3];
	//cacluate parameters for CPR image (width, height, translateLeftX-Z,translateRightX-Z)
	int width, height;
	float translateLeftX,translateLeftY,translateLeftZ,translateRightX,translateRightY,translateRightZ;
	
	float path2DLength;	
	NSMutableArray  *path2DPoints=[curvedMPR2DPath points] ;
	pointNumber=[path2DPoints count];
	
	float curXSpacing,curYSpacing;
	float curOriginX,curOriginY;
	
	curXSpacing=[[curvedMPR2DPath pix] pixelSpacingX];
	curYSpacing=[[curvedMPR2DPath pix] pixelSpacingY];
	curOriginX = [[curvedMPR2DPath pix] originX];
	curOriginY = [[curvedMPR2DPath pix] originY];
	
	cViewSpace[0]=cViewSpace[1]=xSpacing;
	
	//get projected centerline's length
	path2DLength=0;
	for( i = 0; i < pointNumber-1; i++ ) {
		path2DLength += [curvedMPR2DPath Length:[[path2DPoints objectAtIndex:i] point] :[[path2DPoints objectAtIndex:i+1] point]];
	}
	path2DLength*=10;//vtk use length in mm(not cm).
		
		//width and height
		*pwidth=width=(int)(([oImageSlider maxValue]-[oImageSlider minValue])/cViewSpace[0]);
		*pheight=height=(int)(path2DLength/cViewSpace[1]);
		
		// update axview's slider
		[axImageSlider setMinValue: 0];
		[axImageSlider setMaxValue: path2DLength];
		if([axImageSlider floatValue]>path2DLength)
			[axImageSlider setFloatValue: path2DLength-cViewSpace[1]];
	else if([axImageSlider floatValue]<0)
		[axImageSlider setFloatValue: 0];
				
	double startpoint[3];
	
	startpoint[0] = position[0] = curOriginX + [[path2DPoints objectAtIndex: 0] point].x * curXSpacing;
	startpoint[1] = position[1] = curOriginY +[[path2DPoints objectAtIndex: 0] point].y * curYSpacing;
	position[2] = [oImageSlider minValue]-[oImageSlider floatValue];	
	startpoint[2] = 0;
	oViewUserTransform->TransformPoint(position,position);
	oViewUserTransform->TransformPoint(startpoint,startpoint);
	
	translateLeftX=position[0]-startpoint[0];
	translateLeftY=position[1]-startpoint[1];
	translateLeftZ=position[2]-startpoint[2];
	
	startpoint[0] = position[0] = curOriginX +[[path2DPoints objectAtIndex: 0] point].x * curXSpacing;
	startpoint[1] = position[1] = curOriginY +[[path2DPoints objectAtIndex: 0] point].y * curYSpacing;
	position[2] = [oImageSlider maxValue]-[oImageSlider floatValue];	
	startpoint[2] = 0;
	oViewUserTransform->TransformPoint(position,position);
	oViewUserTransform->TransformPoint(startpoint,startpoint);
	
	translateRightX=position[0]-startpoint[0];
	translateRightY=position[1]-startpoint[1];
	translateRightZ=position[2]-startpoint[2];	
	
	
	//create a curved surface from projected centerline
	im=(float*)malloc(sizeof(float)*width*height);
	if(!im)
		return 0L;
	
	//create the projected centerline
	pathKeyPoints = vtkPoints::New();
	for(i=0;i<pointNumber;i++)
	{
		position[0] = curOriginX + [[path2DPoints objectAtIndex: i] point].x * curXSpacing;
		position[1] = curOriginY + [[path2DPoints objectAtIndex: i] point].y * curYSpacing;
		position[2] = 0;
		oViewUserTransform->TransformPoint(position,position);
		pathKeyPoints->InsertPoint(i,position);
		
	}
	
	
	centerLinePath = vtkCellArray::New();
	centerLinePath->InsertNextCell(pointNumber);
	for(i=0;i<pointNumber;i++)
		centerLinePath->InsertCellPoint(i);
	
	
	centerLinePolyData = vtkPolyData::New() ;
	centerLinePolyData->SetPoints(pathKeyPoints);
	centerLinePolyData->SetLines(centerLinePath);
	
	//translate the line to left&right borders and build a ruller surface from this two borders
	surfaceLeftTransform = vtkTransform::New();	
	surfaceLeftTransform->Translate( translateLeftX,translateLeftY,translateLeftZ);
	
	surfaceRightTransform = vtkTransform::New();	
	surfaceRightTransform->Translate( translateRightX, translateRightY, translateRightZ);
	
	leftTransformFilter = vtkTransformPolyDataFilter::New();
	leftTransformFilter->SetInput(centerLinePolyData);
	leftTransformFilter->SetTransform(surfaceLeftTransform);
	
	rightTransformFilter = vtkTransformPolyDataFilter::New();
	rightTransformFilter->SetInput(centerLinePolyData);
	rightTransformFilter->SetTransform(surfaceRightTransform);
	
	appenedPolyData = vtkAppendPolyData::New() ;
	appenedPolyData->AddInput(leftTransformFilter->GetOutput());
	appenedPolyData->AddInput(rightTransformFilter->GetOutput());
	
	
	
	
	curvedSurface = vtkRuledSurfaceFilter::New();	
	curvedSurface->SetInputConnection(appenedPolyData->GetOutputPort());
	curvedSurface->SetResolution(height-1,width-1);
	curvedSurface->SetRuledModeToResample();
	
	//	I planed to use vtkProbeFilter to get the cpr image, but it failed after compile. maybe it can be fixed in the furture. Here I use nearest interpolation.
	
	vtkPolyData *probeResult= curvedSurface->GetOutput();
	probeResult->Update();
	int x,y,z;
	float fposition[3];
	vtkIdType ptId, numPts;
	numPts = probeResult->GetNumberOfPoints();
	for(ptId=0;ptId<numPts;ptId++)
	{
		
		probeResult->GetPoint(ptId,position);
		
		fposition[0]=(position[0]-vtkOriginalX)/xSpacing;
	    fposition[1]=(position[1]-vtkOriginalY)/ySpacing;
		fposition[2]=(position[2]-vtkOriginalZ)/zSpacing;
		if(interpolationMode)
			*(im+ptId)=[self TriCubic:fposition: volumeData: imageWidth: imageHeight: imageAmount];
		else
		{
		 x = lround((position[0]-vtkOriginalX)/xSpacing);
		 y = lround((position[1]-vtkOriginalY)/ySpacing);
		 z = lround((position[2]-vtkOriginalZ)/zSpacing);
		 if(x>=0 && x<imageWidth && y>=0 && y<imageHeight && z>=0 && z<imageAmount)		  
		 *(im+ptId)=*(volumeData + imageSize*z + imageWidth*y+x);
		 else
		 *(im+ptId)=minValueInSeries;
		}
		
	}
	
	
	//release memory
	curvedSurface->Delete() ;
	surfaceLeftTransform->Delete() ;
	surfaceRightTransform->Delete() ;
	pathKeyPoints->Delete();
	centerLinePath->Delete();
	centerLinePolyData->Delete();
	leftTransformFilter->Delete();
	rightTransformFilter->Delete();
	appenedPolyData->Delete();	
	
	
	
	return im;
	
}

- (void) updateCViewAsCurvedMPR
{

	if(!curvedMPR2DPath)
	{
		[self updateCViewAsMPR]; 
		return;
	}

	float *im=0L;
	int width, height;

	if([curvedMPR3DPath count]<2)
	{
		[self updateCViewAsMPR]; 
		return;
	}
	if(!isStraightenedCPR)
	{
		im = [self caculateCurvedMPRImage :&width :&height];
	}
	else
	{
		im = [self caculateStraightCPRImage :&width :&height];
	}
	
	if(!im)
		return;
	DCMPix*		mypix = [[DCMPix alloc] initwithdata:(float*) im :32 :width :height :cViewSpace[0] :cViewSpace[1] :cViewOrigin[0] :cViewOrigin[1] :cViewOrigin[2]];
	[mypix copySUVfrom: curPix];	
	
	[cViewPixList removeAllObjects];
	[cViewPixList addObject: mypix];
	[mypix release];
	
	if(cprImageBuffer) free(cprImageBuffer);//maybe not necessary (the memory should be release when cViewPixList removeAllObjects, but I am confused here)
	cprImageBuffer=im;
	
	if(curvedMPRReferenceLineOfAxis)
	{
		
		NSArray* points=[curvedMPRReferenceLineOfAxis points];
		NSPoint start,end;
		start=[[points objectAtIndex: 1] point];
		end= [[points objectAtIndex: 0] point];
		start.x=0;
		end.x=width-1;
		start.y= end.y = [axImageSlider floatValue]/cViewSpace[1];
		[[points objectAtIndex:1] setPoint: start];
		[[points objectAtIndex:0] setPoint: end];
		if(![[cViewROIList objectAtIndex: 0] containsObject:curvedMPRReferenceLineOfAxis])
		{
			[[cViewROIList objectAtIndex: 0] addObject: curvedMPRReferenceLineOfAxis];
		}

		
	}
	
	[cPRView setIndex: 0 ];
	
}
- (void) updateCViewAsMPR
{
	vtkImageData	*tempIm;
	int				imExtent[ 6];
	if(interpolationMode)
		cViewSlice->SetInterpolationModeToCubic();
	else
		cViewSlice->SetInterpolationModeToNearestNeighbor();
	tempIm = cViewSlice->GetOutput();
	tempIm->Update();
	tempIm->GetWholeExtent( imExtent);
	tempIm->GetSpacing( cViewSpace);
	tempIm->GetOrigin( cViewOrigin);	
	
	float *im = (float*) tempIm->GetScalarPointer();
	DCMPix*		mypix = [[DCMPix alloc] initwithdata:(float*) im :32 :imExtent[ 1]-imExtent[ 0]+1 :imExtent[ 3]-imExtent[ 2]+1 :cViewSpace[0] :cViewSpace[1] :cViewOrigin[0] :cViewOrigin[1] :cViewOrigin[2]];
	[mypix copySUVfrom: curPix];	
	
	[cViewPixList removeAllObjects];
	[cViewPixList addObject: mypix];
	[mypix release];
	
	if([[cViewROIList objectAtIndex: 0] count])
	{
		
		ROI* roi=[[cViewROIList objectAtIndex: 0] objectAtIndex:0];
		
		float crossX,crossY;
		crossX=-cViewOrigin[0]/cViewSpace[0];
		crossY=-cViewOrigin[1]/cViewSpace[1];
		if(crossX<0)
			crossX=0;
		else if(crossX<-(imExtent[ 1]-imExtent[ 0]))
			crossX=-(imExtent[ 1]-imExtent[ 0]);
		if(crossY<0)
			crossY=0;
		else if(crossY<-(imExtent[ 3]-imExtent[ 2] ))
			crossY=-(imExtent[ 3]-imExtent[ 2] );
		if([roi type]==tROI)
		{
			cPRROIRect.origin.x = crossX-cPRROIRect.size.width/2;
			cPRROIRect.origin.y = crossY;
			[roi setROIRect: cPRROIRect];
		}
		else if([roi type]==tArrow)
		{
			NSArray* points=[roi points];
			NSPoint start,end;
			start=[[points objectAtIndex: 1] point];
			end= [[points objectAtIndex: 0] point];
			float height=end.y-start.y;
			start.x=end.x=crossX;
			start.y=crossY;
			end.y = start.y+height;
			[[points objectAtIndex:1] setPoint: start];
			[[points objectAtIndex:0] setPoint: end];
			cViewArrowStartPoint=start;
			
		}
		else if([roi type]==tMesure)
		{
			isRemoveROIBySelf=1;
			[[cViewROIList objectAtIndex: 0] removeAllObjects];
			isRemoveROIBySelf=0;
		}
		
	}
	
	[cPRView setIndex: 0 ];
}
- (void) reCaculateCPRPath:(NSMutableArray*) roiList :(int) width :(int)height :(float)spaceX: (float)spaceY : (float)spaceZ :(float)originX :(float)originY:(float)originZ
{
	
	NSArray* points2D=[curvedMPR2DPath points];
	[roiList addObject: curvedMPR2DPath];
	unsigned int i;
	CMIV3DPoint* a3DPoint;
	float position[3];
	
	if([curvedMPR3DPath count]!=[curvedMPRProjectedPaths count])
	{
		[curvedMPRProjectedPaths removeAllObjects];
		for(i=0;i<[curvedMPR3DPath count];i++)
		{
			a3DPoint=[[CMIV3DPoint alloc] init];
			[curvedMPRProjectedPaths addObject: a3DPoint];
			[a3DPoint release];
		}
	}
	

	float x,y,z;
	NSPoint tempPoint;
	
	for(i=0;i<[curvedMPR3DPath count];i++)
	{
		a3DPoint=[curvedMPR3DPath objectAtIndex: i];
		position[0]=[a3DPoint x];
		position[1]=[a3DPoint y];
		position[2]=[a3DPoint z];
		inverseTransform->TransformPoint(position,position);
		x = (position[0]-originX)/spaceX;
		y = (position[1]-originY)/spaceY;
		z = position[2];
		tempPoint.x=x;
		tempPoint.y=y;
		[[points2D objectAtIndex:i] setPoint: tempPoint];
		a3DPoint=[curvedMPRProjectedPaths objectAtIndex: i];
		[a3DPoint setX: x];
		[a3DPoint setY: y];
		[a3DPoint setZ: z];
		
	}
	

	
}
- (void) recaculateAxViewForStraightenedCPR
{
	double position[3],direction[3],position1[3],position2[3],positionL1[3],positionL2[3],positionR1[3],positionR2[3];
	int ptId,totalpoint;
	ptId=[axImageSlider floatValue]/cViewSpace[1];
	totalpoint=(ribbonPolydata->GetPoints()->GetNumberOfPoints())/2;
	if(ptId>=totalpoint-1)
		ptId=totalpoint-2;
	ribbonPolydata->GetPoint(ptId*2,positionL1);
	ribbonPolydata->GetPoint(ptId*2+1,positionR1);
	ribbonPolydata->GetPoint(ptId*2+2,positionL2);
	ribbonPolydata->GetPoint(ptId*2+3,positionR2);
	
	int i;
	float localoffset=([axImageSlider floatValue] - ptId*cViewSpace[1])/cViewSpace[1];
	for(i=0;i<3;i++)
	{
		position1[i]=(positionR1[i]+positionL1[i])/2;
		position2[i]=(positionR2[i]+positionL2[i])/2;
		position[i] = position1[i]+(position2[i]-position1[i])*localoffset;
		direction[i]=position2[i]-position1[i];
		
	}
	axViewTransformForStraightenCPR->Identity();
	axViewTransformForStraightenCPR->Translate(position);
	float anglex,angley,anglez;
	if(direction[2]==0)
	{
		if(direction[1]>0)
			anglex=90;
		if(direction[1]<0)
			anglex=-90;
		if(direction[1]==0)
			anglex=0;
	}
	else
	{
		anglex = atan(direction[1]/direction[2]) / deg2rad;
		if(direction[2]<0)
			anglex+=180;
	}
	 
	
	angley = asin(direction[0]/cViewSpace[1]) / deg2rad;
	axViewTransformForStraightenCPR->RotateX(-anglex);	
	axViewTransformForStraightenCPR->RotateY(angley);
	
	inverseTransform->TransformPoint(position,position);
	oViewUserTransform->Translate(position);
	[self updateOView];
	if(isNeedShowReferenceLine)
	{
		//draw reference line

		if(curvedMPRReferenceLineOfAxis)
		{
			
			NSArray* points=[curvedMPRReferenceLineOfAxis points];
			NSPoint start,end;
			start=[[points objectAtIndex: 1] point];
			end= [[points objectAtIndex: 0] point];
			start.y= end.y = [axImageSlider floatValue]/cViewSpace[1];
			[[points objectAtIndex:1] setPoint: start];
			[[points objectAtIndex:0] setPoint: end];
			if(![[cViewROIList objectAtIndex: 0] containsObject:curvedMPRReferenceLineOfAxis])
			{
				[[cViewROIList objectAtIndex: 0] addObject: curvedMPRReferenceLineOfAxis];
			}
			
			
		}
		
		[cPRView setIndex: 0 ];
		
	}	

}

- (void) recaculateAxViewForCPR
{
	NSArray* points2D=[curvedMPR2DPath points];
	int pointNum=[points2D count];
	if(pointNum<2)
		return;
	if([curvedMPR3DPath count]!=[curvedMPRProjectedPaths count])
		[self updateOView];
	float path2DLength=0;
	float steplength=0;
	float curLocation = [axImageSlider floatValue]/10;
	int i;
	for( i = 0; i < pointNum-1; i++ )
	{
		steplength = [curvedMPR2DPath Length:[[points2D objectAtIndex:i] point] :[[points2D objectAtIndex:i+1] point]];

		if(path2DLength+steplength >= curLocation)
		{
			NSPoint startPoint=[[points2D objectAtIndex: i] point];
			NSPoint tempPt=[[points2D objectAtIndex: i+1] point];
			float z1,z2;
			z1=[[curvedMPRProjectedPaths objectAtIndex: i] z];
			z2=[[curvedMPRProjectedPaths objectAtIndex: i+1] z];
			NSPoint curPoint;
			if(steplength!=0)
			{
				curPoint.x = (tempPt.x-startPoint.x)*(curLocation-path2DLength)/steplength+startPoint.x;
				curPoint.y = (tempPt.y-startPoint.y)*(curLocation-path2DLength)/steplength+startPoint.y;
				z1=(z2-z1)*(curLocation-path2DLength)/steplength+z1;
			}
			else
			{
				curPoint.x = startPoint.x;
				curPoint.y = startPoint.y;

			}
			float angle;
			
			tempPt.x-=startPoint.x;
			tempPt.y-=startPoint.y;
			tempPt.x*=oViewSpace[0];
			tempPt.y*=oViewSpace[1];
			
			if(tempPt.y == 0)
			{
				if(tempPt.x > 0)
					angle=90;
				else if(tempPt.x < 0)
					angle=-90;
				else 
					angle=0;
				
			}
			else
			{
				if( tempPt.y < 0)
					angle = 180 + atan( (float) tempPt.x / (float) tempPt.y) / deg2rad;
				else 
					angle = atan( (float) tempPt.x / (float) tempPt.y) / deg2rad;
			}
			
			
			curPoint.x = curPoint.x*oViewSpace[0]+oViewOrigin[0];
			curPoint.y = curPoint.y*oViewSpace[1]+oViewOrigin[1];				

			axViewTransform->Identity();	
	//		axViewTransform->Translate(curPoint.x,curPoint.y,0 );
			
			if(isNeedShowReferenceLine)
			{
				//draw reference line

				oViewUserTransform->Translate(curPoint.x,curPoint.y,z1);
				[self updateOView];
	
				if(curvedMPRReferenceLineOfAxis)
				{
					
					NSArray* points=[curvedMPRReferenceLineOfAxis points];
					NSPoint start,end;
					start=[[points objectAtIndex: 1] point];
					end= [[points objectAtIndex: 0] point];
					start.y= end.y = [axImageSlider floatValue]/cViewSpace[1];
					[[points objectAtIndex:1] setPoint: start];
					[[points objectAtIndex:0] setPoint: end];
					if(![[cViewROIList objectAtIndex: 0] containsObject:curvedMPRReferenceLineOfAxis])
					{
						[[cViewROIList objectAtIndex: 0] addObject: curvedMPRReferenceLineOfAxis];
					}
					
					
				}
				
				[cPRView setIndex: 0 ];
				
			}
			else
			{
				axViewTransform->Translate(curPoint.x,curPoint.y,z1 );
			}

			if(angle!=0)
				axViewTransform->RotateZ(-angle);
			axViewTransform->RotateX(90);	
			i=pointNum;
		}
		path2DLength += steplength;		
	}


	
}

- (IBAction)showLoadPathDialog:(id)sender
{
	unsigned int i,j,k;
	int thereIsSameName ;
	NSMutableArray *curRoiList = [originalViewController roiList];
	ROI * tempROI;
	NSMutableArray *existedMaskList = [[NSMutableArray alloc] initWithCapacity: 0];
	[pathListButton removeAllItems];
	
	for(i=0;i<[curRoiList count];i++)
		for(j=0;j<[[curRoiList objectAtIndex:i] count];j++)
		{
			tempROI = [[curRoiList objectAtIndex: i] objectAtIndex:j];
			if([tempROI type]==tPlain)
			{
				thereIsSameName=0;
				for(k=0;k<[existedMaskList count];k++)
				{ 
					if ([[tempROI name] isEqualToString:[existedMaskList objectAtIndex: k] ]==YES)
						thereIsSameName=1;
				}
				if(!thereIsSameName)
				{
					[existedMaskList addObject:[tempROI name]];
					[pathListButton addItemWithTitle: [tempROI name]];
				}	
			}
			
		}
			if([existedMaskList count]>0)
				[pathListButton selectItemAtIndex:0];
	[existedMaskList removeAllObjects];
	[existedMaskList release];
	[NSApp beginSheet: loadPathWindow modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
}
- (IBAction)endLoadPathDialog:(id)sender
{
	int tag=[sender tag];
	if(tag)
	{
		NSString* roiName=[pathListButton titleOfSelectedItem];
		[self create3DPathFromROIs:roiName];
		currentPathMode=ROI_selectedModify;
		[self changeCurrentTool:5];
		
	}
	[loadPathWindow orderOut:sender];
    
    [NSApp endSheet:loadPathWindow returnCode:tag];
}
-(void) create3DPathFromROIs:(NSString*) roiName
{
	
	NSMutableArray *tempRoiList=[NSMutableArray arrayWithCapacity:0];
	NSMutableArray *temp3DPath=[NSMutableArray arrayWithCapacity:0];

	NSMutableArray *curRoiList = [originalViewController roiList];
	unsigned int i,j,k;
	ROI * tempROI;
	int pointNum;
	int err=0;
	float x,y,z;
	for(i=0;i<[curRoiList count];i++)
		for(j=0;j<[[curRoiList objectAtIndex:i] count];j++)
		{
			tempROI = [[curRoiList objectAtIndex: i] objectAtIndex:j];
			if([tempROI type]==tPlain && [[tempROI name] isEqualToString: roiName])
			{
				[tempRoiList addObject: tempROI];
				
			}
		}
	
	pointNum=[tempRoiList count];
	

	for(i=0;i<pointNum;i++)
	{
		for(j=0;j<[tempRoiList count];j++)
		{
			tempROI=[tempRoiList objectAtIndex: j];
			if([[tempROI comments] intValue]==i)
			{
				x = [tempROI textureUpLeftCornerX];
				y = [tempROI textureUpLeftCornerY];
				for(k=0;k<[curRoiList count];k++)
					if([[curRoiList objectAtIndex:k] containsObject:tempROI])
					{
						z=k;
						k=[curRoiList count];
					}
				x = vtkOriginalX + x*xSpacing;
				y = vtkOriginalY + y*ySpacing;
				z = vtkOriginalZ + z*zSpacing;
				
				CMIV3DPoint* new3DPoint=[[CMIV3DPoint alloc] init] ;
				[new3DPoint setX: x];
				[new3DPoint setY: y];
				[new3DPoint setZ: z];
				[temp3DPath addObject: new3DPoint];
				[new3DPoint release];
				[tempRoiList removeObjectAtIndex:j];
				j=[tempRoiList count];

				
			}
		}
		if([temp3DPath count]<=i)
		{
			err=1;
			i=pointNum;
		}
				
		
	}

	if(!err)
	{

		[self setCurrentCPRPathWithPath:temp3DPath:[resampleText floatValue]];
			
		[temp3DPath removeAllObjects];
		[tempRoiList removeAllObjects];
		
	}
	else
	{
		NSRunAlertPanel(NSLocalizedString(@"Not a path", nil), NSLocalizedString(@"The ROI you chosed is not a path, try other name.", nil), NSLocalizedString(@"OK", nil), nil, nil);

		
	}
	
}
- (void) setCurrentCPRPathWithPath:(NSArray*)path:(float)resampelrate
{
	[curvedMPR3DPath removeAllObjects];
	int pointNum=[path count]-1;
	unsigned int i;
	for(i=0;i<[path count];i++)
		[curvedMPR3DPath addObject: [path objectAtIndex: pointNum - i]];

	[self resample3DPath:resampelrate];
	if(!curvedMPR2DPath)
	{
		DCMPix * curImage= [oViewPixList objectAtIndex:0];
		curvedMPR2DPath=[[ROI alloc] initWithType: tOPolygon :[curImage pixelSpacingX] :[curImage pixelSpacingY] : NSMakePoint( [curImage originX], [curImage originY])];
		NSString *roiName = [NSString stringWithString:@"Centerline"];
		RGBColor color;
		color.red = 65535;
		color.blue = 65535;
		color.green =0;
		[curvedMPR2DPath setName:roiName];
		[curvedMPR2DPath setColor: color];
		
		[curvedMPR2DPath setThickness:1.0];
		
		[[NSUserDefaults standardUserDefaults] setFloat:defaultROIThickness forKey:@"ROIThickness"];
	}
	NSMutableArray* points2D=[curvedMPR2DPath points];
	[points2D removeAllObjects];
	for(i=0;i<[curvedMPR3DPath count];i++)
	{
		MyPoint *mypt = [[MyPoint alloc] initWithPoint: NSMakePoint(0,0)];
		
		[points2D addObject: mypt];
		
		[mypt release];
		
		
	}
	[[oViewROIList objectAtIndex: 0] addObject: curvedMPR2DPath];
	
	//currentPathMode=ROI_selectedModify;
	//[self changeCurrentTool:5];
	[self updateOView];
	[self cAndAxViewReset];
	[self updatePageSliders];
}
- (void) resample3DPath:(float)step
{

	if(step<0)
		return;
	int i,origincount;
	origincount=(int)[curvedMPR3DPath count];
	float resamplestep=(step*step);//*4*(xSpacing*xSpacing+ySpacing*ySpacing+zSpacing*xSpacing);
		CMIV3DPoint* a3DPoint;
	float prex,prey,prez,distance3d,nextx,nexty,nextz;

	a3DPoint=[curvedMPR3DPath objectAtIndex: origincount-1];
	prex=[a3DPoint x];
	prey=[a3DPoint y];
	prez=[a3DPoint z];
	
	for(i=origincount-2;i>=0;i--)
	{
		a3DPoint=[curvedMPR3DPath objectAtIndex: i];
		nextx=[a3DPoint x];
		nexty=[a3DPoint y];
		nextz=[a3DPoint z];
		distance3d=(nextx-prex)*(nextx-prex)+(nexty-prey)*(nexty-prey)+(nextz-prez)*(nextz-prez);
		if(distance3d<resamplestep)
		{
			[curvedMPR3DPath removeObjectAtIndex:i ];

		}
		else
		{
			prex=nextx;	prey=nexty;	prez=nextz;
		}
			
	}
	
	
	int controlnodenum=(int)[curvedMPR3DPath count];

	double* tdata, *originpath, *originpathx, *originpathy, *originpathz;
	originpath=(double*)malloc(controlnodenum*sizeof(double)*3);
	tdata=(double*)malloc(controlnodenum*sizeof(double));
	originpathx=originpath;
	originpathy=originpath+controlnodenum;
	originpathz=originpath+2*controlnodenum;
	soomthedpathlen=origincount*4;
	if(soomthedpath)
		free(soomthedpath);
	soomthedpath=(double*)malloc(soomthedpathlen*sizeof(double)*3);
	for(i=0;i<controlnodenum;i++)
	{
		a3DPoint=[curvedMPR3DPath objectAtIndex: i];
		*(originpathx+i)=[a3DPoint x];
		*(originpathy+i)=[a3DPoint y];
		*(originpathz+i)=[a3DPoint z];
		*(tdata+i)=i;
	}
	double tval=0,tstep=(double)controlnodenum/(double)soomthedpathlen;
	
	[curvedMPR3DPath removeAllObjects];
	
	for(i=0;i<soomthedpathlen;i++)
	{
		*(soomthedpath+i*3)=spline_b_val ( controlnodenum, tdata, originpathx, tval );
		*(soomthedpath+i*3+1)=spline_b_val ( controlnodenum, tdata, originpathy, tval );
		*(soomthedpath+i*3+2)=spline_b_val ( controlnodenum, tdata, originpathz, tval );
		tval+=tstep;
		CMIV3DPoint* new3DPoint=[[CMIV3DPoint alloc] init] ;
		[new3DPoint setX: *(soomthedpath+i*3)];
		[new3DPoint setY: *(soomthedpath+i*3+1)];
		[new3DPoint setZ: *(soomthedpath+i*3+2)];
		[curvedMPR3DPath addObject: new3DPoint];
		[new3DPoint release];
	}
	free(originpath);
	free(tdata);
	
}
- (void) runSegmentation
{
	long size = sizeof(float) * imageWidth * imageHeight * imageAmount;
	float               *inputData=0L, *outputData=0L;
	unsigned char       *colorData=0L, *directionData=0L;
	inputData = volumeData;
	NSLog( @"start step 3");
	outputData = (float*) malloc( size);
	if( !outputData)
	{
		NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);

		return ;	
	}
	size = sizeof(char) * imageWidth * imageHeight * imageAmount;
	colorData = (unsigned char*) malloc( size);
	if( !colorData)
	{
		NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);
		free(outputData);
		return ;	
	}	
	directionData= (unsigned char*) malloc( size);
	if( !directionData)
	{
		NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);
		free(outputData);
		free(colorData);

		return ;	
	}		
	
	id waitWindow = [originalViewController startWaitWindow:@"processing"];	

	memset(directionData,0,size);
	int i;
	size=imageWidth * imageHeight * imageAmount;
	float minValueInCurSeries = [curPix minValueOfSeries]-1;
	for(i=0;i<size;i++)
		*(outputData+i)=minValueInCurSeries;
	
	int seednumber = [self plantSeeds:inputData:outputData:directionData];
	if(seednumber < 1)
	{
		
		NSRunAlertPanel(NSLocalizedString(@"no seed", nil), NSLocalizedString(@"no seeds are found, draw ROI first.", nil), NSLocalizedString(@"OK", nil), nil, nil);
		free( outputData );	
		free( colorData );
		free(directionData);
		[originalViewController endWaitWindow: waitWindow];
		return;
		
	}			
	//start seed growing	
	CMIVSegmentCore *segmentCoreFunc = [[CMIVSegmentCore alloc] init];
	[segmentCoreFunc setImageWidth:imageWidth Height: imageHeight Amount: imageAmount];
	[segmentCoreFunc startShortestPathSearchAsFloat:inputData Out:outputData :colorData Direction: directionData];
	//initilize the out and color buffer
	memset(colorData,0,size);
	[segmentCoreFunc caculateColorMapFromPointerMap:colorData:directionData]; 
	[segmentCoreFunc release];
	[originalViewController endWaitWindow: waitWindow];
	[self showPreviewResult:inputData:outputData:directionData:colorData];
}
- (int) plantSeeds:(float*)inData:(float*)outData:(unsigned char *)directData
{
	int seedNumber=0;
	unsigned char * colorLookup;
	int marker;
	unsigned char colorindex;
	int size;
	NSString* roiname;
	ROI* temproi;
	colorLookup=(unsigned char *)malloc(uniIndex);
	if(!colorLookup)
	{
		NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);
		return seedNumber;
	}
	int i=0;
	unsigned j;
	for(i=0;i<uniIndex;i++)
	{
		temproi=[totalROIList objectAtIndex: i];
		marker=[[temproi comments] intValue];
		roiname=[temproi name];
		colorindex=0;
		if([roiname isEqualToString:@"barrier"])
			colorindex=0;
		else
		{
			for(j=0;j<[contrastList count];j++)
				if([roiname isEqualToString: [[contrastList objectAtIndex: j] objectForKey:@"Name"]])
					colorindex=j+1;
		}
			
		colorLookup[i]=colorindex;
	}
	size=imageWidth*imageHeight*imageAmount;
	for(i=0;i<size;i++)
	{
		marker=(int)(*(contrastVolumeData+i));
		if(marker)
		{
			colorindex=*(colorLookup+marker-1);
			if(colorindex)
			{
				*(outData+i)=*(inData+i);
				*(directData + i) = colorindex | 0x80;
					
				seedNumber++;
				
			}
			else
			{
				*(directData + i) = 0x80;
			}
		}
	}
	free(colorLookup);
	
	return seedNumber;
	
}
- (void) showPreviewResult:(float*)inData:(float*)outData:(unsigned char *)directData :(unsigned char *)colorData
{
	[parent cleanDataOfWizard];
	int size= sizeof(float)*imageWidth*imageHeight*imageAmount;
	NSData	*newData = [[NSData alloc] initWithBytesNoCopy:inData length: size freeWhenDone:NO];
	NSMutableDictionary* dic=[parent dataOfWizard];
	[dic setObject:newData forKey:@"InputData"];
	[newData release];
	newData = [[NSData alloc] initWithBytesNoCopy:outData length: size freeWhenDone:YES];
	[dic setObject:newData  forKey:@"OutputData"];
	[newData release];
	size= sizeof(unsigned char)*imageWidth*imageHeight*imageAmount;
	newData = [[NSData alloc] initWithBytesNoCopy:directData length: size freeWhenDone:YES];
	[dic setObject:newData  forKey:@"DirectionData"];
	[newData release];
	newData = [[NSData alloc] initWithBytesNoCopy:colorData length: size freeWhenDone:YES];
	[dic setObject:newData  forKey:@"ColorData"];
	[newData release];
	size= sizeof(unsigned short int)*imageWidth*imageHeight*imageAmount;	
	newData = [[NSData alloc] initWithBytesNoCopy:contrastVolumeData length: size freeWhenDone:YES];
	[dic setObject:newData  forKey:@"SeedData"];
	[newData release];
	NSMutableArray  *shownColorList=[[NSMutableArray alloc] initWithCapacity: 0] ;	
	NSMutableArray  *seedListInResult=[[NSMutableArray alloc] initWithCapacity: 0];
	unsigned int i;
	NSRect temprect;
	temprect.origin.x=0;
	temprect.origin.y=0;
	temprect.size.width = 10;
	temprect.size.height = 10;
	for(i=0;i<[contrastList count];i++)
	{
		ROI* temproi= [[ROI alloc] initWithType: tOval :[curPix pixelSpacingX] :[curPix pixelSpacingY] : NSMakePoint( [curPix originX], [curPix originY])];
		[temproi setROIRect:temprect];
		NSString* seedname = [[contrastList objectAtIndex: i] objectForKey:@"Name"] ;
		[temproi setName: seedname];	
		NSColor* seedcolor =[[contrastList objectAtIndex: i] objectForKey:@"Color"] ;
		float r, g, b;
		[seedcolor getRed:&r green:&g blue:&b alpha:0L];
		RGBColor c;
		c.red =(short unsigned int) (r * 65535.);
		c.green =(short unsigned int)( g * 65535.);
		c.blue = (short unsigned int)(b * 65535.);
		[temproi setColor:c];
		[seedListInResult addObject: temproi];
		if((![seedname isEqualToString: @"barrier"])&&(![seedname isEqualToString: @"other"]))
			[shownColorList addObject: [NSNumber numberWithInt:i+1]];

	}

	
	[dic setObject:seedListInResult  forKey:@"SeedList"];
	[seedListInResult release];
	[dic setObject:shownColorList  forKey:@"ShownColorList"];
	[shownColorList release];
	[dic setObject:totalROIList  forKey:@"ROIList"];
	[parent setDataofWizard:dic];
	[self onCancel:nextButton];
	[parent gotoStepNo:3];
	
	
}
- (IBAction)goNextStep:(id)sender
{
	if(currentTool == 7)
		[self covertRegoinToSeeds:nil];
	if(currentStep>=(totalSteps-1))
	{
		[self runSegmentation];
		return;
	}
	else 
		[self goSubStep:currentStep+1:YES];
	if(currentStep>=(totalSteps-1))
		[nextButton setTitle:@"Run Segmentation"];
	if(currentStep>0)
		[previousButton setEnabled: YES];
}
- (IBAction)goPreviousStep:(id)sender
{
	[self updateOView];
	if(currentStep>0)
		[self goSubStep:currentStep-1:YES];
	if(currentStep<(totalSteps-1))
		[nextButton setTitle:@"Next Step"]; 
	if(currentStep<=0)
		[previousButton setEnabled: NO];
}
- (void) goSubStep:(int)step:(bool)needResetViews
{
	if(step<0)
		step=0;
	else if(step>=totalSteps)
		step=totalSteps-1;
	
	NSString *tempstr;
	NSColor *color;
	NSNumber *number;
	
	if(step>=0&&step<[contrastList count])
	{
		
		currentStep=step;
		//load name
		tempstr = [[contrastList objectAtIndex: step] objectForKey:@"Name"] ;
		currentSeedName=tempstr;
		//load color
		color =[[contrastList objectAtIndex: step] objectForKey:@"Color"] ;
		currentSeedColor=color;
		//load brush
		number=[[contrastList objectAtIndex: step] objectForKey:@"BrushWidth"] ;
		[[NSUserDefaults standardUserDefaults] setFloat:[number floatValue] forKey:@"ROIRegionThickness"];

		//chang current tool
		number=[[contrastList objectAtIndex: step] objectForKey:@"CurrentTool"] ;
		[self changeCurrentTool:[number intValue]];
		//load tips
		tempstr = [[contrastList objectAtIndex: step] objectForKey:@"Tips"] ;
		[currentTips setStringValue:tempstr];
		
	}	
	if(needResetViews)
		[self resetOriginalView:nil];
}
- (IBAction)continuePlanting:(id)sender
{
	[nextButton setEnabled: YES];
	if(currentStep>0)
		[previousButton setEnabled: YES];
	[self goSubStep:currentStep:NO];
	[continuePlantingButton setHidden: YES];
}
- (IBAction)selectANewCenterline:(id)sender
{
	unsigned int row = [centerlinesList selectedRow];
	if(row>=0&&row<[cpr3DPaths count])
	{
		[self setCurrentCPRPathWithPath:[cpr3DPaths objectAtIndex:row]:[resampleRatioSlider floatValue]];
	}
	
}
- (IBAction)showCPRImageDialog:(id)sender
{
	if(currentTool==5||isInCPROnlyMode)
	[NSApp beginSheet: exportCPRWindow modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
	else
		NSRunAlertPanel(NSLocalizedString(@"no CPR image", nil), NSLocalizedString(@"Please choose CPR tools again.", nil), NSLocalizedString(@"OK", nil), nil, nil);

	
}
- (void) convertCenterlinesToVTKCoordinate:(NSArray*)centerlines
{
	CMIV3DPoint* temppoint;
	float x,y,z;
	unsigned int i,j;
	for(i=0;i<[centerlines count];i++)
		for(j=0;j<[[centerlines objectAtIndex: i] count];j++)
		{
			temppoint=[[centerlines objectAtIndex:i] objectAtIndex: j];
			x= [temppoint x];
			y= [temppoint y];
			z= [temppoint z];
			[temppoint setX: vtkOriginalX + x*xSpacing];
			[temppoint setY: vtkOriginalY + y*ySpacing];
			[temppoint setZ: vtkOriginalZ + z*zSpacing];
			
		}
	
}
- (IBAction)setResampleRatio:(id)sender
{
	[resampleRatioText setFloatValue: [sender floatValue]];
	
	unsigned int row = [centerlinesList selectedRow];

	
	if(row>=0&&row<[cpr3DPaths count])
	{
		[self setCurrentCPRPathWithPath:[cpr3DPaths objectAtIndex:row]:[resampleRatioSlider floatValue]];
	}
	
}
- (IBAction)endCPRImageDialog:(id)sender
{
	int tag =[sender tag];
	[exportCPRWindow orderOut:sender];
    [NSApp endSheet:exportCPRWindow returnCode:tag];
	
	if(tag)
	{
		id waitWindow = [originalViewController startWaitWindow:@"processing"];	
		ViewerController *new2DViewer;
		
		if([ifExportCrossSectionButton state]== NSOnState)
		{
			new2DViewer=[self exportCrossSectionImages];
			
			if(isInCPROnlyMode&&parent&&new2DViewer)
			{
				NSString* tempstr=[NSString stringWithString:@"Cross Section "];
				unsigned int row;
				row = [centerlinesList selectedRow];
				[new2DViewer checkEverythingLoaded];
				tempstr=[tempstr stringByAppendingString:[centerlinesNameArrays objectAtIndex: row]  ];
				[[new2DViewer window] setTitle:tempstr];
				
				NSMutableArray	*temparray=[[parent dataOfWizard] objectForKey:@"VCList"];
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
		
		NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
		NSMutableArray	*tempPixList = [NSMutableArray arrayWithCapacity: 0];
		NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];

		int imageNumber=[howManyImageToExport intValue] ;
		float angleofstep,currentangle;
		DCMPix * temppix;
		int maxwidth=0,maxheight=0;
		
		
		if([howManyAngleToExport selectedColumn]==0)
			angleofstep=180/imageNumber;
		else
			angleofstep=360/imageNumber;
		int i;
		for( i = 0 ; i < imageNumber; i ++)
		{
			temppix=[cViewPixList objectAtIndex: 0];
			[tempPixList addObject:temppix];
			if(maxwidth<[temppix pwidth])
				maxwidth=[temppix pwidth];
			if(maxheight<[temppix pheight ])
				maxheight=[temppix pheight];
			
			
			if(isStraightenedCPR)
			{
				currentangle=[cYRotateSlider floatValue];
				currentangle+=angleofstep;
				if(currentangle>180)
					currentangle-=360;
				[cYRotateSlider setFloatValue: currentangle ];
				[self updateCView];
			}
			else
			{
				currentangle=[oYRotateSlider floatValue];
				currentangle+=angleofstep;
				if(currentangle>180)
					currentangle-=360;
				[oYRotateSlider setFloatValue: currentangle ];
				[self rotateYOView:oYRotateSlider];
			}

		}
		float* newVolumeData=nil;
		long size= sizeof(float)*maxwidth*maxheight*imageNumber;
		newVolumeData=(float*) malloc(size);
		if(!newVolumeData)
		{
			NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);
			[tempPixList removeAllObjects];
			[originalViewController endWaitWindow: waitWindow];
			return;
		}
		for( i = 0 ; i < imageNumber; i ++)
		{
			//copy data
			int width,height;
			int x,y;
			int offsetx;
			float* tempfloat;
			temppix=[tempPixList objectAtIndex: i];
			

			width = [temppix pwidth];
			height = [temppix pheight];
			tempfloat = [temppix fImage];
			offsetx = (maxwidth-width)/2;
			for(y=0;y<maxheight;y++)
				for(x=0;x<maxwidth;x++)
				{
					if(x>=offsetx&&x<(width+offsetx)&&y>=0&&y<height)
					   *(newVolumeData+i*maxwidth*maxheight+y*maxwidth+x)=*(tempfloat+y*width+x-offsetx);
					else
						*(newVolumeData+i*maxwidth*maxheight+y*maxwidth+x) = minValueInSeries;
				}
			DCMPix	*newPix = [[DCMPix alloc] initwithdata:(float*) (newVolumeData + i*maxwidth*maxheight ):32 :maxwidth :maxheight :cViewSpace[0] :cViewSpace[1] :cViewOrigin[0] :cViewOrigin[1] :cViewOrigin[2]:YES];
			[newPixList addObject: newPix];
			[newPix release];
			[newDcmList addObject: [[originalViewController fileList] objectAtIndex: 0]];
		}
		
		NSData	*newData = [NSData dataWithBytesNoCopy:newVolumeData length: size freeWhenDone:YES];

		new2DViewer = [originalViewController newWindow	:newPixList
														:newDcmList
														:newData]; 
		[tempPixList removeAllObjects];

		if(isInCPROnlyMode&&parent)
		{
			NSString* tempstr=[NSString stringWithString:@"CPR of "];
			unsigned int row;
			row = [centerlinesList selectedRow];
			[new2DViewer checkEverythingLoaded];
			tempstr=[tempstr stringByAppendingString:[centerlinesNameArrays objectAtIndex: row]  ];
			[[new2DViewer window] setTitle:tempstr];

			NSMutableArray	*temparray=[[parent dataOfWizard] objectForKey:@"VCList"];
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
		
		
		[originalViewController endWaitWindow: waitWindow];
		
	}
}
- (IBAction)exportCenterlines:(id)sender
{
	NSArray* pathsList=cpr3DPaths;
	NSArray* namesList=centerlinesNameArrays;

	NSArray				*pixList = [originalViewController pixList];
	curPix = [pixList objectAtIndex: 0];
	id waitWindow = [originalViewController startWaitWindow:@"processing"];		
	long size=sizeof(float)*imageWidth*imageHeight*imageAmount;
	float* newVolumeData=(float*)malloc(size);
	if(!newVolumeData)
	{
		NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);
		[originalViewController endWaitWindow: waitWindow];
		return ;	
	}
	float* tempinput=[originalViewController volumePtr:0];
	memcpy(newVolumeData,tempinput,size);
	
	NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
	NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
	NSData	*newData = [NSData dataWithBytesNoCopy:newVolumeData length: size freeWhenDone:YES];
	int z;
	unsigned i;
	for( z = 0 ; z < imageAmount; z ++)
	{
		curPix = [pixList objectAtIndex: z];
		DCMPix	*copyPix = [curPix copy];
		[newPixList addObject: copyPix];
		[copyPix release];
		[newDcmList addObject: [[originalViewController fileList] objectAtIndex: z]];
		
		[[newPixList lastObject] setfImage: (float*) (newVolumeData + imageSize * z)];
	}
	ViewerController *new2DViewer=0L;
	new2DViewer = [originalViewController newWindow	:newPixList
													:newDcmList
													:newData];  
	if(new2DViewer)
	{
		NSMutableArray      *newROIList= [new2DViewer roiList];
		curPix = [pixList objectAtIndex: 0];
		for(i=0;i<[pathsList count];i++)
			[self creatROIfrom3DPath:[pathsList objectAtIndex: i]:[namesList objectAtIndex:i]:newROIList];
	}
	
	[originalViewController endWaitWindow: waitWindow];
	if(parent)
	{
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
		[temparray addObject:[NSString stringWithString:@"Centerlines"]];
	}
	
}
- (void) creatROIfrom3DPath:(NSArray*)path:(NSString*)name:(NSMutableArray*)newViewerROIList
{
	RGBColor color;
	color.red = 65535;
	color.blue = 0;
	color.green = 0;
	unsigned char * textureBuffer;
	CMIV3DPoint* temp3dpoint;
	
	float xv,yv,zv;
	int x,y,z;
	int pointIndex=0;
	unsigned int j;
	
	for(j=0;j<[path count];j++)
	{
		temp3dpoint=[path objectAtIndex: j];
		xv=[temp3dpoint x];
		yv=[temp3dpoint y];
		zv=[temp3dpoint z];
		x=(int)((xv-vtkOriginalX)/xSpacing);
		y=(int)((yv-vtkOriginalY)/ySpacing);
		z=(int)((zv-vtkOriginalZ)/zSpacing);
		textureBuffer = (unsigned char *) malloc(sizeof(unsigned char ));
		*textureBuffer = 0xff;
		ROI *newROI=[[ROI alloc] initWithTexture:textureBuffer textWidth:1 textHeight:1 textName:name positionX:x positionY:y spacingX:[curPix pixelSpacingY] spacingY:[curPix pixelSpacingY]  imageOrigin:NSMakePoint( [curPix originX], [curPix originY])];
		
		[[newViewerROIList objectAtIndex: z] addObject:newROI];
		[newROI setColor: color];
		NSString *indexstr=[NSString stringWithFormat:@"%d",pointIndex];
		[newROI setComments:indexstr];	
		pointIndex++;
		[newROI release];
	}
	if(isInCPROnlyMode)
	{
		temp3dpoint=[path objectAtIndex: 0];
		xv=[temp3dpoint x];
		yv=[temp3dpoint y];
		zv=[temp3dpoint z];
		x=(int)((xv-vtkOriginalX)/xSpacing);
		y=(int)((yv-vtkOriginalY)/ySpacing);
		z=(int)((zv-vtkOriginalZ)/zSpacing);
	}
	NSRect roiRect;
	roiRect.origin.x=x;
	roiRect.origin.y=y;
	ROI *endPointROI = [[ROI alloc] initWithType: t2DPoint :[curPix pixelSpacingX] :[curPix pixelSpacingY] : NSMakePoint( [curPix originX], [curPix originY])];
	[endPointROI setName:name];
	[endPointROI setROIRect:roiRect];
	[[newViewerROIList objectAtIndex: z] addObject:endPointROI];
	[endPointROI release];

}
- (IBAction)showCenterlinesDialog:(id)sender
{
	if([curvedMPR3DPath count] )
		[NSApp beginSheet: savePathWindow modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
	else
		NSRunAlertPanel(NSLocalizedString(@"no Path", nil), NSLocalizedString(@"Please define a path first.", nil), NSLocalizedString(@"OK", nil), nil, nil);
}
- (IBAction)endCenterlinesDialog:(id)sender
{
	[savePathWindow orderOut:sender];
    [NSApp endSheet:savePathWindow returnCode:[sender tag]];

	if([sender tag])
	{
		NSArray				*pixList = [originalViewController pixList];
		curPix = [pixList objectAtIndex: 0];
		id waitWindow = [originalViewController startWaitWindow:@"processing"];		
		long size=sizeof(float)*imageWidth*imageHeight*imageAmount;
		float* newVolumeData=(float*)malloc(size);
		if(!newVolumeData)
		{
			NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);
			[originalViewController endWaitWindow: waitWindow];
			return ;	
		}
		float* tempinput=[originalViewController volumePtr:0];
		memcpy(newVolumeData,tempinput,size);
		
		NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
		NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
		NSData	*newData = [NSData dataWithBytesNoCopy:newVolumeData length: size freeWhenDone:YES];
		int z;
		for( z = 0 ; z < imageAmount; z ++)
		{
			curPix = [pixList objectAtIndex: z];
			DCMPix	*copyPix = [curPix copy];
			[newPixList addObject: copyPix];
			[copyPix release];
			[newDcmList addObject: [[originalViewController fileList] objectAtIndex: z]];
			
			[[newPixList lastObject] setfImage: (float*) (newVolumeData + imageSize * z)];
		}
		ViewerController *new2DViewer=0L;
		new2DViewer = [originalViewController newWindow	:newPixList
														:newDcmList
														:newData];  
		if(new2DViewer)
		{
			NSMutableArray      *newROIList= [new2DViewer roiList];
			curPix = [pixList objectAtIndex: 0];
			NSMutableArray      *reversePath=[[NSMutableArray alloc] initWithCapacity:0];
			unsigned int ii,pointNumber;
			pointNumber=[curvedMPR3DPath count];
			for(ii=0;ii<pointNumber;ii++)
				[reversePath addObject: [curvedMPR3DPath objectAtIndex:(pointNumber-ii-1)]]; 
			[self creatROIfrom3DPath:reversePath :[pathName stringValue] :newROIList];
			[reversePath removeAllObjects];
			[reversePath release];
		}
		
		[originalViewController endWaitWindow: waitWindow];
		[new2DViewer checkEverythingLoaded];
		[[new2DViewer window] setTitle:@"Centerlines"];
		if(parent)
		{
			NSMutableArray	*temparray=[[parent dataOfWizard] objectForKey: @"VCList"];
			if(!temparray)
			{
				temparray=[NSMutableArray arrayWithCapacity:0];
				[[parent dataOfWizard] setObject:temparray forKey:@"VCTitleList"];
			}
			[temparray addObject:new2DViewer];
			temparray=[[parent dataOfWizard] objectForKey: @"VCTitleList"];
			if(!temparray)
			{
				temparray=[NSMutableArray arrayWithCapacity:0];
				[[parent dataOfWizard] setObject:temparray forKey:@"VCTitleList"];
			}
			[temparray addObject:[pathName stringValue]];
		}
		
	}
}
- (IBAction)removeCenterline:(id)sender
{
	unsigned int row = [centerlinesList selectedRow];
	if(row>=0&&row<[cpr3DPaths count])
	{
		NSMutableArray      * path= [cpr3DPaths objectAtIndex: row];
		[path removeAllObjects];
		[cpr3DPaths removeObjectAtIndex:row];
		[centerlinesNameArrays removeObjectAtIndex:row];
	}		
	[centerlinesList reloadData];
	if(row>=[cpr3DPaths count])
		row=[cpr3DPaths count]-1;
	[centerlinesList selectRow:row byExtendingSelection:NO];
	[self selectANewCenterline: centerlinesList];	
	
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

- (IBAction)switchStraightenedCPR:(id)sender
{
	if(isStraightenedCPR)
	{
		isStraightenedCPR = NO;
		[straightenedCPRSwitchMenu setTitle:@"Straightened CPR"];
		[cYRotateSlider setEnabled: NO];
		axViewSlice->SetResliceTransform( axViewTransform);
		if(isInCPROnlyMode)
			[straightenedCPRButton setState:NSOffState];
		[self relocateAxViewSlider];
	}
	else
	{
		isStraightenedCPR = YES;
		[straightenedCPRSwitchMenu setTitle:@"Curved MPR"];
		[cYRotateSlider setEnabled: YES];
		axViewSlice->SetResliceTransform( axViewTransformForStraightenCPR);
		if(isInCPROnlyMode)
			[straightenedCPRButton setState:NSOnState];	
		[self relocateAxViewSlider];
	}
	axViewSlice->Update();
	[self updateCView];
	[self updateAxView];
}
- (void)relocateAxViewSlider
{
	if([curvedMPR3DPath count]!=[curvedMPRProjectedPaths count])
		[self updateOView];
	NSArray* points2D=[curvedMPR2DPath points];
	int pointNum = [points2D count];
	if(pointNum<2)
		return;

	if(isStraightenedCPR)
	{

		float path2DLength=0;
		float steplength=0;
		float curLocation = [axImageSlider floatValue]/10;
		int   curPoint=0;
		float substep=0;
		int i;
		for( i = 0; i < pointNum-1; i++ )
		{
			steplength = [curvedMPR2DPath Length:[[points2D objectAtIndex:i] point] :[[points2D objectAtIndex:i+1] point]];
			
			if(path2DLength+steplength >= curLocation)
				break;
			path2DLength+=steplength;

		}
		curPoint=i;
		substep=(curLocation-path2DLength)/steplength;
		float x1,y1,z1,x2,y2,z2;
		
		CMIV3DPoint* a3DPoint;
		a3DPoint=[curvedMPR3DPath objectAtIndex: 0];
		x1=[a3DPoint x];
		y1=[a3DPoint y];
		z1=[a3DPoint z];
		curLocation=0;
		for(i=1;i<=curPoint;i++)
		{
			a3DPoint=[curvedMPR3DPath objectAtIndex: i];
			x2=[a3DPoint x];
			y2=[a3DPoint y];
			z2=[a3DPoint z];
			steplength = sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)+(z2-z1)*(z2-z1));
			curLocation += steplength;
			x1=x2;
			y1=y2;
			z1=z2;
		}
		
		a3DPoint=[curvedMPR3DPath objectAtIndex: i];
		x2=[a3DPoint x];
		y2=[a3DPoint y];
		z2=[a3DPoint z];
		steplength = sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)+(z2-z1)*(z2-z1));
		curLocation += steplength*substep;
		[axImageSlider setFloatValue: curLocation];
	}
	else
	{
		float path3DLength=0;
		float steplength=0;
		float curLocation = [axImageSlider floatValue];
		int   curPoint=0;
		float substep=0;
		int i;
		float x1,y1,z1,x2,y2,z2;
		
		CMIV3DPoint* a3DPoint;
		a3DPoint=[curvedMPR3DPath objectAtIndex: 0];
		x1=[a3DPoint x];
		y1=[a3DPoint y];
		z1=[a3DPoint z];

		for(i=1;i<pointNum;i++)
		{
			a3DPoint=[curvedMPR3DPath objectAtIndex: i];
			x2=[a3DPoint x];
			y2=[a3DPoint y];
			z2=[a3DPoint z];
			steplength = sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)+(z2-z1)*(z2-z1));
			if(path3DLength+steplength >= curLocation)
				break;

			path3DLength += steplength;
			x1=x2;
			y1=y2;
			z1=z2;
		}
		curPoint=i-1;
		substep=(curLocation-path3DLength)/steplength;
		
		curLocation=0;
		for( i = 0; i < curPoint; i++ )
		{
			steplength = [curvedMPR2DPath Length:[[points2D objectAtIndex:i] point] :[[points2D objectAtIndex:i+1] point]];
			curLocation+=steplength;
			
		}
		steplength = [curvedMPR2DPath Length:[[points2D objectAtIndex:i] point] :[[points2D objectAtIndex:i+1] point]];
		curLocation += steplength*substep;
		curLocation = curLocation * 10;
		[axImageSlider setFloatValue: curLocation];
	}
}


/*
 * TriCubic - tri-cubic interpolation at point, p.
 *   inputs:
 *     p - the interpolation point.
 *     volume - a pointer to the float volume data, stored in x,
 *              y, then z order (x index increasing fastest).
 *     xDim, yDim, zDim - dimensions of the array of volume data.
 *   returns:
 *     the interpolated value at p.
 *   note:
 *     NO range checking is done in this function.
 */


- (float)TriCubic : (float*) p :(float *)volume : (int) xDim : (int) yDim :(int) zDim
{
	int             x, y, z;
	register int    i, j, k;
	float           dx, dy, dz;
	register float *pv;
	float           u[4], v[4], w[4];
	float           r[4], q[4];
	float           vox = 0;
	int             xyDim;
	
	xyDim = xDim * yDim;
	
	x = (int) p[0], y = (int) p[1], z = (int) p[2];
	if (x < 1 || x >= xDim-2 || y < 1 || y >= yDim-2 || z < 1 || z >= zDim-2)
		return (minValueInSeries);
	
	dx = p[0] - (float) x, dy = p[1] - (float) y, dz = p[2] - (float) z;
	pv = volume + (x - 1) + (y - 1) * xDim + (z - 1) * xyDim;
	
# define CUBE(x)   ((x) * (x) * (x))
# define SQR(x)    ((x) * (x))
	/*
#define DOUBLE(x) ((x) + (x))
#define HALF(x)   ...
	 *
	 * may also be used to reduce the number of floating point
	 * multiplications. The IEEE standard allows for DOUBLE/HALF
	 * operations.
	 */
	
	/* factors for Catmull-Rom interpolation */
	
	u[0] = -0.5 * CUBE (dx) + SQR (dx) - 0.5 * dx;
	u[1] = 1.5 * CUBE (dx) - 2.5 * SQR (dx) + 1;
	u[2] = -1.5 * CUBE (dx) + 2 * SQR (dx) + 0.5 * dx;
	u[3] = 0.5 * CUBE (dx) - 0.5 * SQR (dx);
	
	v[0] = -0.5 * CUBE (dy) + SQR (dy) - 0.5 * dy;
	v[1] = 1.5 * CUBE (dy) - 2.5 * SQR (dy) + 1;
	v[2] = -1.5 * CUBE (dy) + 2 * SQR (dy) + 0.5 * dy;
	v[3] = 0.5 * CUBE (dy) - 0.5 * SQR (dy);
	
	w[0] = -0.5 * CUBE (dz) + SQR (dz) - 0.5 * dz;
	w[1] = 1.5 * CUBE (dz) - 2.5 * SQR (dz) + 1;
	w[2] = -1.5 * CUBE (dz) + 2 * SQR (dz) + 0.5 * dz;
	w[3] = 0.5 * CUBE (dz) - 0.5 * SQR (dz);
	
	for (k = 0; k < 4; k++)
	{
		q[k] = 0;
		for (j = 0; j < 4; j++)
		{
			r[j] = 0;
			for (i = 0; i < 4; i++)
			{
				r[j] += u[i] * *pv;
				pv++;
			}
			q[k] += v[j] * r[j];
			pv += xDim - 4;
		}
		vox += w[k] * q[k];
		pv += xyDim - 4 * xDim;
	}
	return (vox < minValueInSeries ? minValueInSeries : vox);
}
- (IBAction)exportOrthogonalDataset:(id)sender
{

	if(currentTool==5||isInCPROnlyMode)
	{
		NSRunAlertPanel(NSLocalizedString(@"CPR mode", nil), NSLocalizedString(@"In CPR mode, please use export CPR dialog.", nil), NSLocalizedString(@"OK", nil), nil, nil);
		return;
	}

	id waitWindow = [originalViewController startWaitWindow:@"processing"];
	ViewerController * newviewer;
	newviewer=[self exportCrossSectionImages];
	if(newviewer)
		newviewer=[self exportCViewImages];
	
	if(newviewer)
		newviewer=[self exportOViewImages];
	
	[originalViewController endWaitWindow: waitWindow];	
	
}

- (ViewerController *) exportCrossSectionImages
{
	
	NSPoint point[4];
	NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];

	NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
	NSArray				*pixList = [originalViewController pixList];
	DCMPix	*firstPix=[pixList objectAtIndex: 0];
	DCMPix  *temppix;
	float vector[ 9], origin[3];
	double doublevector[3];
	int i;
	
	vtkTransform* currentTransform;
	if(isStraightenedCPR)
		currentTransform=axViewTransformForStraightenCPR;
	else
		currentTransform=axViewTransform;
	// cross section view Images
	

	

	
	int imageNumber=([axImageSlider maxValue]-[axImageSlider minValue])/minSpacing;
	float distanceofstep,currentdistance,startfromdistance;
	int maxwidth=0,maxheight=0;
	startfromdistance=[axImageSlider minValue];
	currentdistance = [axImageSlider floatValue];
	distanceofstep = minSpacing;
	
	if(imageNumber>512&&currentTool!=5&&!isInCPROnlyMode)
	{
		imageNumber=512;
		distanceofstep=([axImageSlider maxValue]-[axImageSlider minValue])/512.0;
	}
	
	
	NSRect viewsize = [crossAxiasView frame];
	maxwidth=viewsize.size.width/[crossAxiasView scaleValue];
	maxheight=viewsize.size.height/[crossAxiasView scaleValue];
	
	
	
	float* newVolumeData=nil;
	long size= sizeof(float)*maxwidth*maxheight*imageNumber;
	newVolumeData=(float*) malloc(size);
	if(!newVolumeData)
	{
		NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);
		
		return nil;
	}
	
	
	for( i = 0 ; i < imageNumber; i ++)
	{
		[axImageSlider setFloatValue:(startfromdistance+i*distanceofstep)];
		[self pageAxView:axImageSlider];
		
		//copy data
		int x,y;
		int offsetx,offsety;
		int minx,miny,maxx,maxy;
		int width,height;
		float* tempfloat;
		temppix=[axViewPixList objectAtIndex: 0];
		
		
		width = [temppix pwidth];
		height = [temppix pheight];
		tempfloat = [temppix fImage];
		
		point[0].x=0;
		point[1].x=viewsize.size.width;
		point[2].x=0;
		point[3].x=viewsize.size.width;
		
		point[0].y=0;
		point[1].y=0;
		point[2].y=viewsize.size.height;
		point[3].y=viewsize.size.height;
		
		point[0]=[crossAxiasView ConvertFromView2GL:point[0]];
		point[1]=[crossAxiasView ConvertFromView2GL:point[1]];
		point[2]=[crossAxiasView ConvertFromView2GL:point[2]];
		point[3]=[crossAxiasView ConvertFromView2GL:point[3]];
		
		minx=maxx=point[0].x;
		miny=maxy=point[0].y;
		int j;
		for(j=1;j<4;j++)
		{
			if(point[j].x<minx)
				minx=point[j].x;
			if(point[j].y<miny)
				miny=point[j].y;
			if(point[j].x>maxx)
				maxx=point[j].x;
			if(point[j].y>maxy)
				maxy=point[j].y;
		
		}
		
		offsetx=minx;
		offsety=miny;
		if(minx<0)
			minx=0;
		if(miny<0)
			miny=0;
		if(maxx>width)
			maxx=width;
		if(maxy>height)
			maxy=height;
		
		for(y=0;y<maxheight;y++)
			for(x=0;x<maxwidth;x++)
			{
				if(x+offsetx>=minx&&x+offsetx<maxx&&y+offsety>=miny&&y+offsety<maxy)
					*(newVolumeData+i*maxwidth*maxheight+y*maxwidth+x)=*(tempfloat+(y+offsety)*width+x+offsetx);
				else
					*(newVolumeData+i*maxwidth*maxheight+y*maxwidth+x) = minValueInSeries;
			}
		
		//calculate orietion
		origin[0]=0;
		origin[1]=0;
		origin[2]=0;
		currentTransform->TransformPoint(origin,origin);
		
		
		[firstPix orientation:vector];
		
		doublevector[0]=vector[0];
		doublevector[1]=vector[1];
		doublevector[2]=vector[2];
		currentTransform->TransformPoint(doublevector,doublevector);
		vector[0]=doublevector[0]-origin[0];
		vector[1]=doublevector[1]-origin[1];
		vector[2]=doublevector[2]-origin[2];
		
		doublevector[0]=vector[3];
		doublevector[1]=vector[4];
		doublevector[2]=vector[5];
		currentTransform->TransformPoint(doublevector,doublevector);
		vector[3]=doublevector[0]-origin[0];
		vector[4]=doublevector[1]-origin[1];
		vector[5]=doublevector[2]-origin[2];
		
		doublevector[0]=vector[6];
		doublevector[1]=vector[7];
		doublevector[2]=vector[8];
		currentTransform->TransformPoint(doublevector,doublevector);
		vector[6]=doublevector[0]-origin[0];
		vector[7]=doublevector[1]-origin[1];
		vector[8]=doublevector[2]-origin[2];
		
		
		origin[0]=axViewOrigin[0]+offsetx*axViewSpace[0];
		origin[1]=axViewOrigin[1]+offsety*axViewSpace[1];
		origin[2]=axViewOrigin[2];
		currentTransform->TransformPoint(origin,origin);
		

				
				
		DCMPix	*newPix = [firstPix copy];
		[newPix setPwidth: maxwidth];
		[newPix setRowBytes: maxwidth];
		[newPix setPheight: maxheight];
		
		[newPix setfImage:(float*) (newVolumeData + i*maxwidth*maxheight )];
		[newPix setTot:imageNumber ];
		[newPix setFrameNo: i];
		[newPix setID: i];
		[newPix setPixelSpacingX: axViewSpace[0]];
		[newPix setPixelSpacingY: axViewSpace[1]];
		[newPix setOrigin:origin];
		[newPix setOrientation: vector];
		[newPix setSliceLocation:startfromdistance+i*distanceofstep];
		[newPix setPixelRatio:  axViewSpace[1] / axViewSpace[0]];
		[newPix setSliceThickness: distanceofstep];
		[newPix setSliceInterval: distanceofstep];

	
		[newPixList addObject: newPix];
		[newPix release];
		[newDcmList addObject: [[originalViewController fileList] objectAtIndex: 0]];
		

		
	}
	[axImageSlider setFloatValue:currentdistance];
	[self pageAxView:axImageSlider];	
	
	
	
	NSData	*newData = [NSData dataWithBytesNoCopy:newVolumeData length: size freeWhenDone:YES];
	ViewerController *new2DViewer;
	new2DViewer = [originalViewController newWindow	:newPixList
													:newDcmList
													:newData]; 
	return new2DViewer;
}
- (ViewerController *) exportCViewImages
{
	
	NSPoint point[4];
	NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
	
	NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
	NSArray				*pixList = [originalViewController pixList];
	DCMPix	*firstPix=[pixList objectAtIndex: 0];
	DCMPix  *temppix;
	float vector[ 9], origin[3];
	double doublevector[3];
	int i;
	
	// cross section view Images
	
	
	
	
	int imageNumber=([cImageSlider maxValue]-[cImageSlider minValue])/minSpacing;
	float distanceofstep,currentdistance,startfromdistance;
	int maxwidth=0,maxheight=0;
	startfromdistance=[cImageSlider minValue];
	currentdistance = [cImageSlider floatValue];
	distanceofstep = minSpacing;
	
	if(imageNumber>512)
	{
		imageNumber=512;
		distanceofstep=([cImageSlider maxValue]-[cImageSlider minValue])/512.0;
	}
	
	
	NSRect viewsize = [cPRView frame];
	maxwidth=viewsize.size.width/[cPRView scaleValue];
	maxheight=viewsize.size.height/[cPRView scaleValue];
	
	float* newVolumeData=nil;
	long size= sizeof(float)*maxwidth*maxheight*imageNumber;
	newVolumeData=(float*) malloc(size);
	if(!newVolumeData)
	{
		NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);
		
		return nil;
	}
	
	
	for( i = 0 ; i < imageNumber; i ++)
	{
		[cImageSlider setFloatValue:(startfromdistance+i*distanceofstep)];
		[self pageCView:cImageSlider];
		
		//copy data
		int x,y;
		int offsetx,offsety;
		int minx,miny,maxx,maxy;
		int width,height;
		float* tempfloat;
		temppix=[cViewPixList objectAtIndex: 0];
		
		
		width = [temppix pwidth];
		height = [temppix pheight];
		tempfloat = [temppix fImage];
		
		point[0].x=0;
		point[1].x=viewsize.size.width;
		point[2].x=0;
		point[3].x=viewsize.size.width;
		
		point[0].y=0;
		point[1].y=0;
		point[2].y=viewsize.size.height;
		point[3].y=viewsize.size.height;
		
		point[0]=[cPRView ConvertFromView2GL:point[0]];
		point[1]=[cPRView ConvertFromView2GL:point[1]];
		point[2]=[cPRView ConvertFromView2GL:point[2]];
		point[3]=[cPRView ConvertFromView2GL:point[3]];
		
		minx=maxx=point[0].x;
		miny=maxy=point[0].y;
		int j;
		for(j=1;j<4;j++)
		{
			if(point[j].x<minx)
				minx=point[j].x;
			if(point[j].y<miny)
				miny=point[j].y;
			if(point[j].x>maxx)
				maxx=point[j].x;
			if(point[j].y>maxy)
				maxy=point[j].y;
			
		}
		
		offsetx=minx;
		offsety=miny;
		if(minx<0)
			minx=0;
		if(miny<0)
			miny=0;
		if(maxx>width)
			maxx=width;
		if(maxy>height)
			maxy=height;
		
		for(y=0;y<maxheight;y++)
			for(x=0;x<maxwidth;x++)
			{
				if(x+offsetx>=minx&&x+offsetx<maxx&&y+offsety>=miny&&y+offsety<maxy)
					*(newVolumeData+i*maxwidth*maxheight+y*maxwidth+x)=*(tempfloat+(y+offsety)*width+x+offsetx);
				else
					*(newVolumeData+i*maxwidth*maxheight+y*maxwidth+x) = minValueInSeries;
			}
				
				//calculate orietion
				origin[0]=0;
		origin[1]=0;
		origin[2]=0;
		cViewTransform->TransformPoint(origin,origin);
		
		
		[firstPix orientation:vector];
		
		doublevector[0]=vector[0];
		doublevector[1]=vector[1];
		doublevector[2]=vector[2];
		cViewTransform->TransformPoint(doublevector,doublevector);
		vector[0]=doublevector[0]-origin[0];
		vector[1]=doublevector[1]-origin[1];
		vector[2]=doublevector[2]-origin[2];
		
		doublevector[0]=vector[3];
		doublevector[1]=vector[4];
		doublevector[2]=vector[5];
		cViewTransform->TransformPoint(doublevector,doublevector);
		vector[3]=doublevector[0]-origin[0];
		vector[4]=doublevector[1]-origin[1];
		vector[5]=doublevector[2]-origin[2];
		
		doublevector[0]=vector[6];
		doublevector[1]=vector[7];
		doublevector[2]=vector[8];
		cViewTransform->TransformPoint(doublevector,doublevector);
		vector[6]=doublevector[0]-origin[0];
		vector[7]=doublevector[1]-origin[1];
		vector[8]=doublevector[2]-origin[2];
		
		
		origin[0]=cViewOrigin[0]+offsetx*cViewSpace[0];
		origin[1]=cViewOrigin[1]+offsety*cViewSpace[1];
		origin[2]=cViewOrigin[2];
		cViewTransform->TransformPoint(origin,origin);
		
		
		
		
		DCMPix	*newPix = [firstPix copy];
		[newPix setPwidth: maxwidth];
		[newPix setRowBytes: maxwidth];
		[newPix setPheight: maxheight];
		
		[newPix setfImage:(float*) (newVolumeData + i*maxwidth*maxheight )];
		[newPix setTot:imageNumber ];
		[newPix setFrameNo: i];
		[newPix setID: i];
		[newPix setPixelSpacingX: cViewSpace[0]];
		[newPix setPixelSpacingY: cViewSpace[1]];
		[newPix setOrigin:origin];
		[newPix setOrientation: vector];
		[newPix setSliceLocation:startfromdistance+i*distanceofstep];
		[newPix setPixelRatio:  cViewSpace[1] / cViewSpace[0]];
		[newPix setSliceThickness: distanceofstep];
		[newPix setSliceInterval: distanceofstep];
		
		
		[newPixList addObject: newPix];
		[newPix release];
		[newDcmList addObject: [[originalViewController fileList] objectAtIndex: 0]];
		
		
		
	}
	[cImageSlider setFloatValue:currentdistance];
	[self pageCView:cImageSlider];	
	
	
	
	NSData	*newData = [NSData dataWithBytesNoCopy:newVolumeData length: size freeWhenDone:YES];
	ViewerController *new2DViewer;
	new2DViewer = [originalViewController newWindow	:newPixList
													:newDcmList
													:newData]; 
	return new2DViewer;
}
- (ViewerController *) exportOViewImages
{
	
	NSPoint point[4];
	NSMutableArray	*newPixList = [NSMutableArray arrayWithCapacity: 0];
	
	NSMutableArray	*newDcmList = [NSMutableArray arrayWithCapacity: 0];
	NSArray				*pixList = [originalViewController pixList];
	DCMPix	*firstPix=[pixList objectAtIndex: 0];
	DCMPix  *temppix;
	float vector[ 9], origin[3];
	double doublevector[3];
	int i;
	
	// cross section view Images
	
	
	
	
	int imageNumber=([oImageSlider maxValue]-[oImageSlider minValue])/minSpacing;
	float distanceofstep,currentdistance,startfromdistance;
	int maxwidth=0,maxheight=0;
	startfromdistance=[oImageSlider minValue];
	currentdistance = [oImageSlider floatValue];
	distanceofstep = minSpacing;
	
	if(imageNumber>512)
	{
		imageNumber=512;
		distanceofstep=([oImageSlider maxValue]-[oImageSlider minValue])/512.0;
	}
	
	NSRect viewsize = [originalView frame];
	maxwidth=viewsize.size.width/[originalView scaleValue];
	maxheight=viewsize.size.height/[originalView scaleValue];
	
	float* newVolumeData=nil;
	long size= sizeof(float)*maxwidth*maxheight*imageNumber;
	newVolumeData=(float*) malloc(size);
	if(!newVolumeData)
	{
		NSRunAlertPanel(NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"no enough RAM", nil), NSLocalizedString(@"OK", nil), nil, nil);
		
		return nil;
	}
	
	
	for( i = 0 ; i < imageNumber; i ++)
	{
		[oImageSlider setFloatValue:(startfromdistance+i*distanceofstep)];
		[self pageOView:oImageSlider];
		
		//copy data
		int x,y;
		int offsetx,offsety;
		int minx,miny,maxx,maxy;
		int width,height;
		float* tempfloat;
		temppix=[oViewPixList objectAtIndex: 0];
		
		
		width = [temppix pwidth];
		height = [temppix pheight];
		tempfloat = [temppix fImage];
		
		point[0].x=0;
		point[1].x=viewsize.size.width;
		point[2].x=0;
		point[3].x=viewsize.size.width;
		
		point[0].y=0;
		point[1].y=0;
		point[2].y=viewsize.size.height;
		point[3].y=viewsize.size.height;
		
		point[0]=[originalView ConvertFromView2GL:point[0]];
		point[1]=[originalView ConvertFromView2GL:point[1]];
		point[2]=[originalView ConvertFromView2GL:point[2]];
		point[3]=[originalView ConvertFromView2GL:point[3]];
		
		minx=maxx=point[0].x;
		miny=maxy=point[0].y;
		int j;
		for(j=1;j<4;j++)
		{
			if(point[j].x<minx)
				minx=point[j].x;
			if(point[j].y<miny)
				miny=point[j].y;
			if(point[j].x>maxx)
				maxx=point[j].x;
			if(point[j].y>maxy)
				maxy=point[j].y;
			
		}
		
		offsetx=minx;
		offsety=miny;
		if(minx<0)
			minx=0;
		if(miny<0)
			miny=0;
		if(maxx>width)
			maxx=width;
		if(maxy>height)
			maxy=height;
		
		for(y=0;y<maxheight;y++)
			for(x=0;x<maxwidth;x++)
			{
				if(x+offsetx>=minx&&x+offsetx<maxx&&y+offsety>=miny&&y+offsety<maxy)
					*(newVolumeData+i*maxwidth*maxheight+y*maxwidth+x)=*(tempfloat+(y+offsety)*width+x+offsetx);
				else
					*(newVolumeData+i*maxwidth*maxheight+y*maxwidth+x) = minValueInSeries;
			}
				
				//calculate orietion
				origin[0]=0;
		origin[1]=0;
		origin[2]=0;
		oViewUserTransform->TransformPoint(origin,origin);
		
		
		[firstPix orientation:vector];
		
		doublevector[0]=vector[0];
		doublevector[1]=vector[1];
		doublevector[2]=vector[2];
		oViewUserTransform->TransformPoint(doublevector,doublevector);
		vector[0]=doublevector[0]-origin[0];
		vector[1]=doublevector[1]-origin[1];
		vector[2]=doublevector[2]-origin[2];
		
		doublevector[0]=vector[3];
		doublevector[1]=vector[4];
		doublevector[2]=vector[5];
		oViewUserTransform->TransformPoint(doublevector,doublevector);
		vector[3]=doublevector[0]-origin[0];
		vector[4]=doublevector[1]-origin[1];
		vector[5]=doublevector[2]-origin[2];
		
		doublevector[0]=vector[6];
		doublevector[1]=vector[7];
		doublevector[2]=vector[8];
		oViewUserTransform->TransformPoint(doublevector,doublevector);
		vector[6]=doublevector[0]-origin[0];
		vector[7]=doublevector[1]-origin[1];
		vector[8]=doublevector[2]-origin[2];
		
		
		origin[0]=oViewOrigin[0]+offsetx*oViewSpace[0];
		origin[1]=oViewOrigin[1]+offsety*oViewSpace[1];
		origin[2]=oViewOrigin[2];
		oViewUserTransform->TransformPoint(origin,origin);
		
		
		
		
		DCMPix	*newPix = [firstPix copy];
		[newPix setPwidth: maxwidth];
		[newPix setRowBytes: maxwidth];
		[newPix setPheight: maxheight];
		
		[newPix setfImage:(float*) (newVolumeData + i*maxwidth*maxheight )];
		[newPix setTot:imageNumber ];
		[newPix setFrameNo: i];
		[newPix setID: i];
		[newPix setPixelSpacingX: oViewSpace[0]];
		[newPix setPixelSpacingY: oViewSpace[1]];
		[newPix setOrigin:origin];
		[newPix setOrientation: vector];
		[newPix setSliceLocation:startfromdistance+i*distanceofstep];
		[newPix setPixelRatio:  oViewSpace[1] / oViewSpace[0]];
		[newPix setSliceThickness: distanceofstep];
		[newPix setSliceInterval: distanceofstep];
		
		
		[newPixList addObject: newPix];
		[newPix release];
		[newDcmList addObject: [[originalViewController fileList] objectAtIndex: 0]];
		
		
		
	}
	[oImageSlider setFloatValue:currentdistance];
	[self pageOView:oImageSlider];	
	
	
	
	NSData	*newData = [NSData dataWithBytesNoCopy:newVolumeData length: size freeWhenDone:YES];
	ViewerController *new2DViewer;
	new2DViewer = [originalViewController newWindow	:newPixList
													:newDcmList
													:newData]; 
	return new2DViewer;
}

@end
