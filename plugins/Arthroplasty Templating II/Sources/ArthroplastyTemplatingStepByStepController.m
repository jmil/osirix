//
//  ArthroplastyTemplatingStepByStepController.m
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "ArthroplastyTemplatingStepByStepController.h"
#import "ArthroplastyTemplatingWindowController.h"
#import "SendController.h"
#import "BrowserController.h"

@implementation ArthroplastyTemplatingStepByStepController


#pragma mark Initialization

//- (id)initWithWindowNibName:(NSString *)windowNibName
- (void)awakeFromNib
{
//	NSLog(@"ArthroplastyTemplatingStepByStepController initWithWindowNibName");
//	NSLog(@"ArthroplastyTemplatingStepByStepController awakeFromNib");
	//self = [super initWithWindowNibName:windowNibName];
	
	stepHorizontalAxis = [stepByStep addStepWithTitle:@"Horizontal Axis" enclosedView:viewHorizontalAxis];
	stepFemurAxis = [stepByStep addStepWithTitle:@"Femur Axis" enclosedView:viewFemurAxis];
	stepCalibrationPoints = [stepByStep addStepWithTitle:@"Femoral landmarks" enclosedView:viewCalibrationPoints];
	stepCutting = [stepByStep addStepWithTitle:@"Femur identification" enclosedView:viewCutting];
	stepCup = [stepByStep addStepWithTitle:@"Cup" enclosedView:viewCup];
	stepStem = [stepByStep addStepWithTitle:@"Stem" enclosedView:viewStem];
	stepPlacement = [stepByStep addStepWithTitle:@"Reduction" enclosedView:viewPlacement];
	stepPlannerName = [stepByStep addStepWithTitle:@"Planner's name" enclosedView:viewPlannerName];
	stepSave = [stepByStep addStepWithTitle:@"Save" enclosedView:viewSave];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roiChanged:) name:@"roiChange" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roiRemoved:) name:@"removeROI" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:@"NSWindowWillCloseNotification" object:[self window]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendToPACS:) name:@"OsirixAddToDBNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:@"CloseViewerNotification" object:nil];
	
//	[[self window] setAlphaValue:0.75];
//	[[self window] setBackgroundColor:[NSColor blackColor]];
	
	[[stepByStep view] setControlColor:[NSColor whiteColor]];
	[[stepByStep view] setDisabledControlColor:[NSColor grayColor]];
	
	templateWindowController = [[ArthroplastyTemplatingWindowController alloc] initWithWindowNibName:@"TemplatePanel"];
	[templateWindowController window]; // forces nib loading
	
	[stepByStep enableSteps];
	[stepByStep showFirstStep];
	
	//return self;
}

- (void)dealloc
{
	[self resetStepByStepUpdatingView:NO];
	
	[stepPlannerName release];
	[stepHorizontalAxis release];
	[stepFemurAxis release];
	[stepCalibrationPoints release];
	[stepCutting release];
	[stepCup release];
	[stepStem release];
	[stepPlacement release];
	[stepSave release];
	if(infoBoxROI) [infoBoxROI release];
	if(pointA2) [pointA2 release];
	if(pointB2) [pointB2 release];
	if(cupTemplate) [cupTemplate release];
	if(stemTemplate) [stemTemplate release];
	if(templateWindowController) [templateWindowController close];
	if(planningDate)[planningDate release];
	if(imageToSendName)[imageToSendName release];
	[viewerController release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void)windowWillClose:(NSNotification *)aNotification { // this window is closing
	[templateWindowController close];
	[self release];
}

- (IBAction)showWindow:(id)sender; {
	[super showWindow:sender];
	[stepByStep enableSteps];
//	[stepByStep showFirstStep];
}

- (void)viewerWillClose:(NSNotification*)notification;
{
	[self close];
}


#pragma mark Link to OsiriX

- (void)setViewerController:(ViewerController*)aViewerController;
{
	if(viewerController!=aViewerController)
	{
		[viewerController release];
		viewerController = aViewerController;
		[viewerController retain];
	}
	userTool = [[viewerController imageView] currentTool];
	[stepByStep showFirstStep];
}

- (void)roiChanged:(NSNotification*)notification;
{
	if(![[self window] isVisible]) return;
	
	ROI *roi = [notification object];
	if(roi==nil) return;
	if(roi==infoBoxROI) return;

//	NSLog(@"roi name : %@", [roi name]);
//	NSLog(@"roi type : %d", [roi type]);
//	NSLog(@"roi uniqueID : %@", [roi valueForKey:@"uniqueID"]);
	if(pointerROI)
	{
		if(*pointerROI==nil && [roi type]==expectedROIType)
		{
			if(![horizontalAxis isEqualTo:roi] && ![femurAxis isEqualTo:roi] && ![pointA1 isEqualTo:roi] && ![pointB1 isEqualTo:roi] && ![femurROI isEqualTo:roi] && ![femurLayer isEqualTo:roi] && ![cupLayer isEqualTo:roi] && ![stemLayer isEqualTo:roi])
				*pointerROI = roi;
		}
		if(nameROI)[*pointerROI setName:nameROI];
	}
	
	if((pointA1!=nil || pointB1!=nil) && femurLayer!=nil && stemLayer!=nil)
	{
		if([femurLayer groupID]==[stemLayer groupID])
		{
			if(roi==stemLayer)
			{
				[self computeOffset];
				[self updateInfoBoxROI];
			}
		}
	}

	if(horizontalAxis!=nil)
	{
		if(roi==horizontalAxis)
		{
			[self computeHorizontalAngle];
		}
	}
	
	if(cupLayer!=nil)
	{
		if(roi==cupLayer)
		{
			[self computeCupAngle];
			[self updateInfoBoxROI];
		}
	}
	
//	if(femurROI!=nil)
//	{
//		if(roi==femurROI)
//		{
//			if(femurLayer)
//			{
//				[[[viewerController roiList] objectAtIndex:0] removeObject:femurLayer];
//				[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurLayer userInfo:nil];
//			}
//			if(pointA2)
//			{
//				[[[viewerController roiList] objectAtIndex:0] removeObject:pointA2];
//				[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointA2 userInfo:nil];
//			}
//			if(pointB2)
//			{
//				[[[viewerController roiList] objectAtIndex:0] removeObject:pointB2];
//				[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointB2 userInfo:nil];
//			}
//			[[viewerController imageView] display];
//		}
//	}
}

- (void)roiRemoved:(NSNotification*)notification;
{
	ROI *roi = [notification object];
	if(pointerROI)
	{
		if(*pointerROI==roi)
		{
			*pointerROI = nil;
		}
	}

	if([horizontalAxis isEqualTo:roi])
	{
		horizontalAxis = nil;
		[stepHorizontalAxis setIsDone:NO];
		[stepByStep setCurrentStep:stepHorizontalAxis];
		[self updateInfoBoxROI];
	}
	
	if([femurAxis isEqualTo:roi])
	{
		femurAxis = nil;
		[stepFemurAxis setIsDone:NO];
		[stepByStep setCurrentStep:stepFemurAxis];
		[self updateInfoBoxROI];
	}
	
	if([pointA1 isEqualTo:roi])
	{
		pointA1 = nil;
		if(pointA2)
		{
			[[[viewerController roiList] objectAtIndex:0] removeObject:pointA2];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointA2 userInfo:nil];
		}
		
		if(pointB1==nil)
		{
			[[[viewerController roiList] objectAtIndex:0] removeObject:femurLayer];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurLayer userInfo:nil];
			[stepCalibrationPoints setIsDone:NO];
			[stepCutting setIsDone:NO];
			[stepStem setIsDone:NO];
			[stepByStep setCurrentStep:stepCalibrationPoints];
		}
	}
	
	if([pointB1 isEqualTo:roi])
	{
		pointB1 = nil;
		if(pointB2)
		{
			[[[viewerController roiList] objectAtIndex:0] removeObject:pointB2];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointB2 userInfo:nil];
		}
		if(pointA1==nil)
		{
			[[[viewerController roiList] objectAtIndex:0] removeObject:femurLayer];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurLayer userInfo:nil];
			[stepCalibrationPoints setIsDone:NO];
			[stepCutting setIsDone:NO];
			[stepStem setIsDone:NO];
			[stepByStep setCurrentStep:stepCalibrationPoints];
		}
	}
	
	if([femurROI isEqualTo:roi])
	{
		femurROI = nil;
		//[stepCutting setIsDone:NO];
	}
	
	if([femurLayer isEqualTo:roi])
	{
		femurLayer = nil;
		[stepCutting setIsDone:NO];
		[stepByStep setCurrentStep:stepCutting];
	}
	
	if([cupLayer isEqualTo:roi])
	{
		cupLayer = nil;
		if(cupTemplate)
		{
			[cupTemplate release];
			cupTemplate = nil;
		}
		[stepCup setIsDone:NO];
		[stepByStep setCurrentStep:stepCup];
		[self updateInfoBoxROI];
	}
	
	if([stemLayer isEqualTo:roi])
	{
		stemLayer = nil;
		if(stemTemplate)
		{
			[stemTemplate release];
			stemTemplate = nil;
		}
		[stepStem setIsDone:NO];
		[stepByStep setCurrentStep:stepStem];
		[self updateInfoBoxROI];
	}
	
	if([pointA2 isEqualTo:roi])
	{
		[pointA2 release];
		pointA2 = nil;
	}
	
	if([pointB2 isEqualTo:roi])
	{
		[pointB2 release];
		pointB2 = nil;
	}
	
	if([infoBoxROI isEqualTo:roi])
	{
		[infoBoxROI release];
		infoBoxROI = nil;
	}
	
	[stepByStep enableSteps];
	[stepByStep showCurrentStep];
}


#pragma mark Templates

- (IBAction)showTemplatePanel:(id)sender {
	[self showTemplatePanel];
}

- (void)showTemplatePanel {
	[templateWindowController showWindow:self];
}

- (void)closeTemplatePanel {
	if (templateWindowController)
		[templateWindowController close];
}


#pragma mark General Methods

- (IBAction)resetStepByStep:(id)sender;
{
	[self resetStepByStepUpdatingView:YES];
}

- (void)resetStepByStepUpdatingView:(BOOL)updateView;
{	
	if(horizontalAxis)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:horizontalAxis];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:horizontalAxis userInfo:NULL];
	}
	if(femurAxis)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:femurAxis];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurAxis userInfo:NULL];
	}
	if(femurROI)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:femurROI];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurROI userInfo:NULL];
	}
	if(pointA1)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:pointA1];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointA1 userInfo:NULL];
	}
	if(pointB1)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:pointB1];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointB1 userInfo:NULL];
	}
	if(femurLayer)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:femurLayer];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurLayer userInfo:NULL];
	}
	if(pointA2)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:pointA2];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointA2 userInfo:NULL];
//		[pointA2 release];
//		pointA2 = nil;
	}		
	if(pointB2)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:pointB2];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointB2 userInfo:NULL];
//		[pointB2 release];
//		pointB2 = nil;
	}
	if(cupLayer)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:cupLayer];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:cupLayer userInfo:NULL];
//		[cupLayer release];
//		cupLayer = nil;
	}
	if(stemLayer)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:stemLayer];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:stemLayer userInfo:NULL];
//		[stemLayer release];
//		stemLayer = nil;
	}
	if(infoBoxROI)
	{
//		NSLog(@"infoBoxROI");
		[[[viewerController roiList] objectAtIndex:0] removeObject:infoBoxROI];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:infoBoxROI];
//		[infoBoxROI release];
//		infoBoxROI = nil;
	}
	
	if(cupTemplate) {[cupTemplate release]; cupTemplate=nil;}
	if(stemTemplate) {[stemTemplate release]; stemTemplate=nil;}
	if(templateWindowController) [templateWindowController close];
	if(planningDate){[planningDate release]; planningDate=nil;}
	
	[plannerNameTextField setStringValue:@""];
	[chosenSizeTextField setStringValue:@""];
	
	[viewerController roiDeleteAll:self];
	
	if(updateView)
	{
		[stepByStep reset];
		[stepByStep showCurrentStep];
		[[viewerController imageView] display];
	}
}


#pragma mark StepByStep Delegate Methods

- (void)willBeginStep:(Step*)step;
{
	BOOL changeTool = NO;
	BOOL bringViewerControllerToFront = YES;
	BOOL needsTemplatePanel = NO;
	pointerROI = nil;
	expectedROIType = -1;

	// if the step was already done before (i.e. the user re-did a prvious step) we skip it
	// this will bring the user to the first undone step.
//	if([step isDone])
//	{
//		[stepByStep nextStep:self];
//		return;
//	}

	if([step isEqualTo:stepPlannerName])
	{
		// nothing special to do before the user types his/her name
		bringViewerControllerToFront = NO;
	}
	else if([step isEqualTo:stepHorizontalAxis])
	{
		// the user will have to draw a line
		// select the correct tool in OsiriX
		changeTool = YES;
		currentTool = tMesure;
		expectedROIType = tMesure;
		pointerROI = &horizontalAxis;
		nameROI = @"Horizontal Axis";
	}
	else if([step isEqualTo:stepFemurAxis])
	{
		// the user will have to draw a line
		// select the correct tool in OsiriX
		changeTool = YES;
		currentTool = tMesure;
		expectedROIType = tMesure;
		pointerROI = &femurAxis;
		nameROI = @"Femur Axis";
	}
	else if([step isEqualTo:stepCalibrationPoints])
	{
		// the user will have to place 1 or 2 points
		// select the correct tool in OsiriX
		changeTool = YES;
		currentTool = t2DPoint;
		expectedROIType = t2DPoint;
	}	
	else if([step isEqualTo:stepCutting])
	{
		// the user will have to draw a ROI around the Femur
		// select the correct tool in OsiriX
		changeTool = YES;
		currentTool = tPencil;
		expectedROIType = tPencil;
		pointerROI = &femurROI;
		nameROI = @"Femur ROI";
		if(stemLayer)
		{
			[stemLayer setGroupID:0.0];
			[stepStem setIsDone:NO];
		}
	}
	else if([step isEqualTo:stepCup])
	{
		// the user will have to place the Cup
		// select the correct tool in OsiriX
		changeTool = YES;
		currentTool = tROISelector;
		expectedROIType = tLayerROI;
		needsTemplatePanel = YES;
		pointerROI = &cupLayer;
	}
	else if([step isEqualTo:stepStem])
	{
		// the user will have to place the Stem in the Femur
		// select the correct tool in OsiriX
		changeTool = YES;
		currentTool = tROISelector;
		expectedROIType = tLayerROI;
		needsTemplatePanel = YES;
		pointerROI = &stemLayer;
		if(stemLayer)
		{
			[stemLayer setGroupID:0.0];
			[stepStem setIsDone:NO];
		}
	}
	else if([step isEqualTo:stepPlacement])
	{
		// the user will have to move the Femur+Stem
		// select the correct tool in OsiriX
		changeTool = YES;
		currentTool = tROISelector;
	}
	else if([step isEqualTo:stepSave])
	{
		bringViewerControllerToFront = NO;
	}
	
	if(changeTool)
	{
		[viewerController setROIToolTag:currentTool];
	}

	if(needsTemplatePanel)
		[self showTemplatePanel];
	else
		[self closeTemplatePanel];
		
	if(bringViewerControllerToFront)
		[[viewerController window] makeKeyAndOrderFront:self];
}

- (BOOL)shouldValidateStep:(Step*)step;
{
	BOOL error = NO;
	NSString *errorMessage;
	if([step isEqualTo:stepPlannerName])
	{
		errorMessage = @"The planner's name should not remain empty.";
		error = [[plannerNameTextField stringValue] length]<=0;
	}
	else if([step isEqualTo:stepHorizontalAxis])
	{
		errorMessage = @"Please draw a line parallel to the horizontal axis of the pelvis.";
		error = horizontalAxis==nil;
	}
	else if([step isEqualTo:stepFemurAxis])
	{
		errorMessage = @"Please draw the axis of the femoral shaft.";
		error = femurAxis==nil;
	}
	else if([step isEqualTo:stepCalibrationPoints])
	{
		errorMessage = @"Please locate one or up to two landmarks on the proximal femur (example tip of the greater trochanter).";
		int nbPoint = [[viewerController point2DList] count];
		error = (nbPoint<1) || (nbPoint>2);
		error &= pointA1==nil;
	}
	else if([step isEqualTo:stepCutting])
	{
		errorMessage = @"Please encircle the proximal femur, destined to receive the femoral implant. Femoral head and neck should not be included if you plan to remove them.";
		error = femurROI==nil;
	}
	else if([step isEqualTo:stepCup])
	{
		errorMessage = @"Please select an acetabular template, rotate and locate the component into the pelvic bone.";
		error = cupLayer==nil;
	}
	else if([step isEqualTo:stepStem])
	{
		errorMessage = @"Please select a femoral template, then rotate and insert the femoral component into the proximal femur.";
		error = stemLayer==nil;
	}

	if(error)
	{
		NSRunCriticalAlertPanel([step title],errorMessage, @"OK", nil, nil);		
		return NO;
	}
	else
		return YES;
}

- (void)validateStep:(Step*)step;
{
	pointerROI = nil;
	nameROI = nil;
	
	if([step isEqualTo:stepPlannerName])
	{
		[self updateInfoBoxROI];
	}
	else if([step isEqualTo:stepHorizontalAxis])
	{
		[self computeHorizontalAngle];
	}
	else if([step isEqualTo:stepCalibrationPoints])
	{
		if(!pointA1)
		{
			// finds the points
			NSArray *points = [viewerController point2DList];
			pointA1 = [points objectAtIndex:0];
			if([points count]==2) pointB1 = [points objectAtIndex:1];
		}
	}
	else if([step isEqualTo:stepCutting])
	{
		if(!femurLayer)
		{
			// create the layer
			femurLayer = [viewerController createLayerROIFromROI:femurROI splineScale:.01];
			
			// change the color		
			float red = 1.0;
			float green = 248.0/255.0;
			float blue = 177.0/255.0;
			
			RGBColor femurLayerRGBColor;
			femurLayerRGBColor.red = 65535.0 * red;
			femurLayerRGBColor.green = 65535.0 * green;
			femurLayerRGBColor.blue = 65535.0 * blue;
			
			[femurColorWell setColor:[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0]];
			
			[femurLayer setColor:femurLayerRGBColor];
		}

		if(!pointA2)
		{			
			// compute the shift (when the layer is created, it is shifted, but we don't want this. Thus we shift it back)
			NSPoint offset;
			offset.x = -10;
			offset.y = 10;
			
			[femurLayer roiMove:offset];
			
			// duplicate the points
			pointA2 = [[ROI alloc] initWithType:t2DPoint :[[pointA1 valueForKey:@"pixelSpacingX"] floatValue] :[[pointA1 valueForKey:@"pixelSpacingY"] floatValue] :[[pointA1 valueForKey:@"imageOrigin"] pointValue]];
			[pointA2 setROIRect:[pointA1 rect]];
			[pointA2 setName:[NSString stringWithFormat:@"%@'",[pointA1 name]]]; // same name + prime
			[pointA2 setDisplayTextualData:NO];
			
			[[viewerController imageView] roiSet:pointA2];
			[[[viewerController roiList] objectAtIndex:[[viewerController imageView] curImage]] addObject:pointA2];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:pointA2 userInfo:nil];
			
			if(pointB1)
			{
				pointB2 = [[ROI alloc] initWithType:t2DPoint :[[pointB1 valueForKey:@"pixelSpacingX"] floatValue] :[[pointB1 valueForKey:@"pixelSpacingY"] floatValue] :[[pointB1 valueForKey:@"imageOrigin"] pointValue]];
				[pointB2 setROIRect:[pointB1 rect]];
				[pointB2 setName:[NSString stringWithFormat:@"%@'",[pointB1 name]]]; // same name + prime
				[pointB2 setDisplayTextualData:NO];
				
				[[viewerController imageView] roiSet:pointB2];
				[[[viewerController roiList] objectAtIndex:[[viewerController imageView] curImage]] addObject:pointB2];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:pointB2 userInfo:nil];
			}
			
			// bring the 2 points to front (we don't want them behind the layer)
			if(pointB1)[viewerController bringToFrontROI:pointB2];
			[viewerController bringToFrontROI:pointA2];
			
			// group the layer and the 2 points
			NSTimeInterval newGroupID = [NSDate timeIntervalSinceReferenceDate];
			[femurLayer setGroupID:newGroupID];
			[pointA2 setGroupID:newGroupID];
			if(pointB1)[pointB2 setGroupID:newGroupID];
		}
	}
	else if([step isEqualTo:stepCup])
	{
		[self computeCupAngle];
		if(cupTemplate)
		{
			[cupTemplate release];
			cupTemplate = nil;
		}
		cupTemplate = [templateWindowController templateAtPath:[cupLayer layerReferenceFilePath]];
		[self updateInfoBoxROI];
	}
	else if([step isEqualTo:stepStem])
	{
		[stemLayer setGroupID:[femurLayer groupID]];
		[viewerController bringToFrontROI:stemLayer];
				
		stemTemplate = [templateWindowController templateAtPath:[stemLayer layerReferenceFilePath]];
		[self updateInfoBoxROI];
	}
//	[self updateInfoBoxROI];
	
	if([step isEqualTo:stepSave])
	{
		if(planningDate)[planningDate release];
		planningDate = [[NSDate date] retain];
		[self updateInfoBoxROI];

		NSManagedObject *study = [[[viewerController fileList:0] objectAtIndex:[[viewerController imageView] curImage]] valueForKeyPath:@"series.study"];
		NSArray	*seriesArray = [[study valueForKey:@"series"] allObjects];

		NSString *namePrefix = @"Planning ";

		int i, n, m;
		n = 1;
		for(i=0; i<[seriesArray count]; i++)
		{
			NSString *currentSeriesName = [[seriesArray objectAtIndex:i] valueForKey:@"name"];
			if([currentSeriesName hasPrefix:namePrefix])
			{
				m = [[currentSeriesName substringFromIndex:[namePrefix length]] intValue];
				if(n<=m) n = m+1;
			}
		}
		
		NSString *name = [NSString stringWithFormat:@"%@%d", namePrefix, n];
		[viewerController deselectAllROIs];
		[viewerController exportDICOMFileInt:YES withName:name];
		[[BrowserController currentBrowser] checkIncoming:self];
		
		// send to PACS
		if([sendToPACSButton state]==NSOnState)
		{
//			NSLog(@"prepare to send to PACS");
			imageToSendName = [name retain];
		}
	}
}


#pragma mark Steps specific methods

float distanceNSPoint(NSPoint p1, NSPoint p2)
{
	float dx = p1.x - p2.x;
	float dy = p1.y - p2.y;
	return sqrt(dx*dx+dy*dy);
}

- (void)computeOffset;
{
	NSPoint pA1, pA2;
	
	if(pointA1)
	{
		pA1 = [[[pointA1 points] objectAtIndex:0] point];
		pA2 = [[[pointA2 points] objectAtIndex:0] point];
	}
	else if(pointB1)
	{
		pA1 = [[[pointB1 points] objectAtIndex:0] point];
		pA2 = [[[pointB2 points] objectAtIndex:0] point];
	}
	else
		return;
			
	NSPoint p1 = [[[femurAxis points] objectAtIndex:0] point];
	NSPoint p2 = [[[femurAxis points] objectAtIndex:1] point];

	if(p2.x == p1.x) // the line p1p2 is vertical
	{
		planningOffset.x = pA2.x - pA1.x;
		planningOffset.y = pA2.y - pA1.y;
	}
	else if(p2.y == p1.y) // the line p1p2 is horizontal
	{
		planningOffset.x = pA2.y - pA1.y;
		planningOffset.y = pA2.x - pA1.x;
	}
	else
	{
		float a, b; // y = a * x + b is the equation of the line going from p1 to p2
		a = (p2.y - p1.y) / (p2.x - p1.x); // division by zero handled previously
		b = p1.y - a * p1.x;

		float b2 = pA1.y - a * pA1.x; // y2 = parallel going through pA1
	//	float b3 = pA2.y - a * pA2.x; // y3 = parallel going through pA2

	//	float b4 = pA1.y + (1.0/a) * pA1.x; // y4 = perpendicular going through pA1
		float b5 = pA2.y + (1.0/a) * pA2.x; // y5 = perpendicular going through pA2

		// intersection between y2 and y5
		NSPoint v;
		v.x = (b5 - b2) / (a + (1.0/a));
		v.y = a * v.x + b2;

		// intersection between y3 and y4
	//	NSPoint w;
	//	w.x = (b4 - b3) / (a + (1.0/a));
	//	w.y = a * w.x + b3;

		// compute offset
		planningOffset.x = distanceNSPoint(pA2, v);
		planningOffset.y = distanceNSPoint(pA1, v);
	}

	planningOffset.x *= [[viewerController imageView] pixelSpacingX];
	planningOffset.y *= [[viewerController imageView] pixelSpacingY];
	
	if(verticalOffsetTextField)[verticalOffsetTextField setStringValue:[NSString stringWithFormat:@"Vertical offset (Lengthening): %.1f mm", planningOffset.y]];
	if(horizontalOffsetTextField)[horizontalOffsetTextField setStringValue:[NSString stringWithFormat:@"Lateral offset: %.1f mm", planningOffset.x]];
}

- (IBAction)changeFemurLayerOpacity:(id)sender;
{
	float opacity = [sender floatValue] / 100.0;
	[self setFemurLayerOpacity:opacity];
}

- (void)setFemurLayerOpacity:(float)opacity;
{
	if(!femurLayer) return;
	[femurLayer setOpacity:opacity];
	[femurOpacityTextField setFloatValue:opacity];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:femurLayer userInfo:nil];
}

- (IBAction)changeFemurLayerColor:(id)sender;
{
//	if(![sender isActive])
//		[[NSColorPanel sharedColorPanel] close];
//	else
		[self setFemurLayerColor:[sender color]];
}

- (void)setFemurLayerColor:(NSColor*)color;
{
	RGBColor femurLayerRGBColor;
	femurLayerRGBColor.red = [color redComponent] * 65535.0;
	femurLayerRGBColor.green = [color greenComponent] * 65535.0;
	femurLayerRGBColor.blue = [color blueComponent] * 65535.0;
	[femurLayer setColor:femurLayerRGBColor];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:femurLayer userInfo:nil];
}

- (void)computeHorizontalAngle;
{
	if(!horizontalAxis) return;
	if([[horizontalAxis points] count]<=0) return;
	
	NSPoint h1 = [[[horizontalAxis points] objectAtIndex:0] point];
	NSPoint h2 = [[[horizontalAxis points] objectAtIndex:1] point];

	float slope;

	if(h2.y == h1.y)
		horizontalAngle = 0;
	else if(h2.x == h1.x)
		horizontalAngle = 90;
	else
	{
		slope = (h2.y-h1.y) / (h2.x-h1.x);
		horizontalAngle = -atan(slope) * 360/(2*pi);
	}
}

- (void)computeCupAngle;
{
	if(!cupLayer) return;
	if([[cupLayer points] count]<=0) return;
	
	NSPoint p1 = [[[cupLayer points] objectAtIndex:0] point];
	NSPoint p2 = [[[cupLayer points] objectAtIndex:3] point];

	float slope;

	if(p2.y == p1.y)
		cupAngle = 0;
	else if(p2.x == p1.x)
		cupAngle = 90;
	else
	{
		slope = (p2.y-p1.y) / (p2.x-p1.x);
		cupAngle = atan(slope) * 360/(2*pi);
	}	
	cupAngle += horizontalAngle;
	if(cupAngle>90) cupAngle -= 180;
	if(cupAngle<0) cupAngle = -cupAngle;
	NSString *degreeSign = [NSString stringWithUTF8String: "\xC2\xB0"];
	if(cupAngleTextField)[cupAngleTextField setStringValue:[NSString stringWithFormat:@"Rotation angle: %.0f%@", cupAngle, degreeSign]];
}

- (void)sendToPACS:(NSNotification*)notification;
{
	if([sendToPACSButton state]==NSOnState && imageToSendName!=nil)
	{
//		NSLog(@"send to PACS");
		NSManagedObject *study = [[[viewerController fileList:0] objectAtIndex:[[viewerController imageView] curImage]] valueForKeyPath:@"series.study"];
		NSArray	*seriesArray = [[study valueForKey:@"series"] allObjects];
//		NSLog(@"[seriesArray count] : %d", [seriesArray count]);
		NSString *pathOfImageToSend;
		
		
		NSManagedObject *imageToSend;
		
		int i;
		for(i=0; i<[seriesArray count]; i++)
		{
			NSString *currentSeriesName = [[seriesArray objectAtIndex:i] valueForKey:@"name"];
//			NSLog(@"currentSeriesName : %@", currentSeriesName);
			if([currentSeriesName isEqualToString:imageToSendName])
			{
				NSArray *images = [[[seriesArray objectAtIndex:i] valueForKey:@"images"] allObjects];
//				NSLog(@"[images count] : %d", [images count]);
//				NSLog(@"images : %@", images);
				imageToSend = [images objectAtIndex:0];
				pathOfImageToSend = [[images objectAtIndex:0] valueForKey:@"path"];
				//pathOfImageToSend = [images valueForKey:@"path"];
//				NSLog(@"pathOfImageToSend : %@", pathOfImageToSend);
			}
		}
		
		NSMutableArray *file2Send = [NSMutableArray arrayWithCapacity:1];
		//[file2Send addObject:pathOfImageToSend];
		[file2Send addObject:imageToSend];
		[SendController sendFiles:file2Send];
	}
}


#pragma mark Result

- (void)createInfoBoxROI;
{
//	NSLog(@"createInfoBoxROI ?");
	if(infoBoxROI) return;
//	NSLog(@"createInfoBoxROI !");
	infoBoxROI = [[ROI alloc] initWithType:tText :[[viewerController imageView] pixelSpacingX] :[[viewerController imageView] pixelSpacingY] :[[viewerController imageView] origin]];
	[infoBoxROI setROIRect:NSMakeRect([[[viewerController imageView] curDCM] pwidth]/2.0, [[[viewerController imageView] curDCM] pheight]/2.0, 0.0, 0.0)];
	[[viewerController imageView] roiSet:infoBoxROI];
	[[[viewerController roiList] objectAtIndex:[[viewerController imageView] curImage]] addObject:infoBoxROI];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:infoBoxROI userInfo:nil];
}

- (IBAction)updateInfoBoxROI:(id)sender;
{
	[self updateInfoBoxROI];
}

- (void)updateInfoBoxROI;
{
//	NSLog(@"infoBoxROI : %@", infoBoxROI);
	[self createInfoBoxROI];

//	if(infoBoxROI) NSLog(@"infoBoxROI created!");
//	NSLog(@"infoBoxROI : %@", infoBoxROI);
	NSMutableString *text = [NSMutableString string];
	NSString *plannerName=nil;
	NSMutableString *cupInfo=nil, *stemInfo=nil;
	
	int maxLength = 0;
	
	if([[plannerNameTextField stringValue] length]>0)
	{
		plannerName = [plannerNameTextField stringValue];
		maxLength = [plannerName length];
	}
	
	NSString *title, *name, *size, *manufacturer, *vOffset, *hOffset, *chosenSize, *angle, *degreeSign;
	
	// Cup info
	if(cupTemplate)
	{
		cupInfo = [NSMutableString string];
		title = @"\nCup";
		name = [NSString stringWithFormat:@"\nName: %@", [cupTemplate name]];
		size = [NSString stringWithFormat:@"\nSize: %@", [cupTemplate size]];
		manufacturer = [NSString stringWithFormat:@"\nManufacturer: %@", [cupTemplate manufacturerName]];
		
		degreeSign = [NSString stringWithUTF8String: "\xC2\xB0"];
		if(horizontalAxis)
			angle = [NSString stringWithFormat:@"\nRotation angle: %.0f%@", cupAngle, degreeSign];
		else
			angle = @"\nRotation angle: (needs the Horizontal Axis)";
		
		[cupInfo appendString:title];
		[cupInfo appendString:name];
		[cupInfo appendString:size];
		[cupInfo appendString:manufacturer];
		[cupInfo appendString:angle];
		
		if([title length]>maxLength) maxLength = [title length];
		if([name length]>maxLength) maxLength = [name length];
		if([size length]>maxLength) maxLength = [size length];
		if([manufacturer length]>maxLength) maxLength = [manufacturer length];
		if([angle length]>maxLength) maxLength = [angle length];
	}
	// Stem info
	if(stemTemplate)
	{
		stemInfo = [NSMutableString string];
		
		title = @"\nStem";
		name = [NSString stringWithFormat:@"\nName: %@", [stemTemplate name]];
		size = [NSString stringWithFormat:@"\nSize: %@", [stemTemplate size]];
		manufacturer = [NSString stringWithFormat:@"\nManufacturer: %@", [stemTemplate manufacturerName]];
		if(femurAxis)
		{
			vOffset = [NSString stringWithFormat:@"\nVertical offset (Lengthening): %.1f mm", planningOffset.y];
			hOffset = [NSString stringWithFormat:@"\nLateral offset: %.1f mm", planningOffset.x];
		}
		else
		{
			vOffset = @"\nVertical offset (Lengthening): (needs the Femur Axis)";
			hOffset = @"\nLateral offset: (needs the Femur Axis)";
		}
		
		if([[chosenSizeTextField stringValue] length]>0)
		{
			chosenSize = [NSString stringWithFormat:@"\nNeck size: %@", [chosenSizeTextField stringValue]];
			if([chosenSize length]>maxLength) maxLength = [chosenSize length];
		}
		
		[stemInfo appendString:title];
		[stemInfo appendString:name];
		[stemInfo appendString:size];
		[stemInfo appendString:manufacturer];
		[stemInfo appendString:vOffset];
		[stemInfo appendString:hOffset];
		if([[chosenSizeTextField stringValue] length]>0)[stemInfo appendString:chosenSize];

		if([title length]>maxLength) maxLength = [title length];
		if([name length]>maxLength) maxLength = [name length];
		if([size length]>maxLength) maxLength = [size length];
		if([manufacturer length]>maxLength) maxLength = [manufacturer length];		
		if([vOffset length]>maxLength) maxLength = [vOffset length];		
		if([hOffset length]>maxLength) maxLength = [hOffset length];
	}

	NSString *separator = [@"_" stringByPaddingToLength:maxLength withString: @"_" startingAtIndex:0];

	if(plannerName)
	{
		[text appendFormat:@"Planner : %@", plannerName];
	}
	if(planningDate)
	{
		[text appendString:@"\n"];
		[text appendFormat:@"Date : %@", [planningDate descriptionWithCalendarFormat:nil timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
	}
	
	if(plannerName || planningDate)
	{
		[text appendString:@"\n"];
		[text appendString:separator];
	}
	
	if(cupInfo)
	{
		[text appendString:cupInfo];
	}
	if(stemInfo)
	{
		[text appendString:@"\n"];
		[text appendString:separator];
		[text appendString:stemInfo];
	}
	[infoBoxROI setName:text];
}

@end
