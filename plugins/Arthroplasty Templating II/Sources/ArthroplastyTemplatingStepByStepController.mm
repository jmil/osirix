//
//  ArthroplastyTemplatingStepByStepController.m
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "ArthroplastyTemplatingStepByStepController.h"
#import "ArthroplastyTemplatingWindowController.h"
#import "ArthroplastyTemplatingPlugin.h"
#import "SendController.h"
#import "BrowserController.h"
#import "StepByStep/SBS.h"
#import "StepByStep/SBSStep.h"
#import "Notifications.h"
#import "NSButton+ArthroplastyTemplating.h"
#import "NSUtils.h"

#define kInvalidAngle 666
#define kInvalidMagnification 0

@implementation ArthroplastyTemplatingStepByStepController


#pragma mark Initialization

-(id)initWithPlugin:(ArthroplastyTemplatingPlugin*)plugin viewerController:(ViewerController*)viewerController {
	self = [self initWithWindowNibName:@"ArthroplastyTemplatingStepByStep"];
	_plugin = [plugin retain];
	_viewerController = [viewerController retain];
	
	_knownRois = [[NSMutableSet alloc] initWithCapacity:16];
	
	// place at viewer window upper right corner
	NSRect frame = [[self window] frame];
	NSRect screen = [[[_viewerController window] screen] frame];
	frame.origin.x = screen.origin.x+screen.size.width-frame.size.width;
	frame.origin.y = screen.origin.y+screen.size.height-frame.size.height;
	[[self window] setFrame:frame display:YES];
	
	[_viewerController roiDeleteAll:self];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roiChanged:) name:OsirixROIChangeNotification object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roiRemoved:) name:OsirixRemoveROINotification object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerDidChangeKeyStatus:) name:NSWindowDidBecomeKeyNotification object:[_viewerController window]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerDidChangeKeyStatus:) name:NSWindowDidResignKeyNotification object:[_viewerController window]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeKeyStatus:) name:NSWindowDidBecomeKeyNotification object:[self window]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeKeyStatus:) name:NSWindowDidResignKeyNotification object:[self window]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendToPACS:) name:OsirixAddToDBNotification object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:OsirixCloseViewerNotification object:NULL];
	
	return self;
}

-(void)awakeFromNib {
	[_sbs addStep: _stepCalibration = [[SBSStep alloc] initWithTitle:@"Calibration" enclosedView:_viewCalibration]];
	[_sbs addStep: _stepAxes = [[SBSStep alloc] initWithTitle:@"Axes" enclosedView:_viewAxes]];
	[_sbs addStep: _stepLandmarks = [[SBSStep alloc] initWithTitle:@"Femoral landmarks" enclosedView:_viewLandmarks]];
	[_sbs addStep: _stepCutting = [[SBSStep alloc] initWithTitle:@"Femur identification" enclosedView:_viewCutting]];
	[_sbs addStep: _stepCup = [[SBSStep alloc] initWithTitle:@"Cup" enclosedView:_viewCup]];
	[_sbs addStep: _stepStem = [[SBSStep alloc] initWithTitle:@"Stem" enclosedView:_viewStem]];
	[_sbs addStep: _stepPlacement = [[SBSStep alloc] initWithTitle:@"Reduction" enclosedView:_viewPlacement]];
	[_sbs addStep: _stepSave = [[SBSStep alloc] initWithTitle:@"Save" enclosedView:_viewSave]];
	[_sbs enableDisableSteps];
	[_magnificationRadioCustom setAttributedTitle:[[[NSAttributedString alloc] initWithString:[_magnificationRadioCustom title] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, [_magnificationRadioCustom font], NSFontAttributeName, NULL]] autorelease]];
	[_magnificationRadioCalibrate setAttributedTitle:[[[NSAttributedString alloc] initWithString:[_magnificationRadioCalibrate title] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, [_magnificationRadioCalibrate font], NSFontAttributeName, NULL]] autorelease]];
	[_magnificationCustomFactor setBackgroundColor:[[self window] backgroundColor]];
	[_magnificationCustomFactor setFloatValue:_magnification];
	[_magnificationCalibrateLength setBackgroundColor:[[self window] backgroundColor]];
	[_plannersNameTextField setBackgroundColor:[[self window] backgroundColor]];
}

- (void)dealloc {
	[self hideTemplatesPanel];
	
	[self resetSBSUpdatingView:NO];
	
	[_stepCalibration release];
	[_stepAxes release];
	[_stepLandmarks release];
	[_stepCutting release];
	[_stepCup release];
	[_stepStem release];
	[_stepPlacement release];
	[_stepSave release];
	[_knownRois release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

#pragma mark Windows

- (void)windowWillClose:(NSNotification *)aNotification { // this window is closing
	[self release];
}

- (void)viewerWillClose:(NSNotification*)notification {
//	[self close];
}

-(void)viewerDidChangeKeyStatus:(NSNotification*)notif {
	if ([[_viewerController window] isKeyWindow])
		[[self window] orderFront:self];
	else { 
		if ([[self window] isKeyWindow]) return; // TODO: somehow this is not yet valid (both windows are not the key window)
		if ([[[_plugin templatesWindowController] window] isKeyWindow]) return;
//		[[self window] orderOut:self];
	}
}

-(void)windowDidChangeKeyStatus:(NSNotification*)notif {
	NSLog(@"windowDidChangeKeyStatus");
}

#pragma mark Link to OsiriX

-(void)removeRoiFromViewer:(ROI*)roi {
	if (!roi) return;
	[[[_viewerController roiList] objectAtIndex:0] removeObject:roi];
	[[NSNotificationCenter defaultCenter] postNotificationName:OsirixRemoveROINotification object:roi userInfo:NULL];
}

// landmark OR horizontal axis has changed
-(BOOL)landmarkChanged:(ROI*)landmark axis:(ROI**)axis {
	if (!landmark || [[landmark points] count] != 1 || !_horizontalAxis) {
		if (*axis) {
			[self removeRoiFromViewer:*axis];
			*axis = NULL;
		} return NO;	
	}
	
	BOOL newAxis = !*axis;
	if (newAxis) {
		*axis = [[ROI alloc] initWithType:tMesure :[[_horizontalAxis valueForKey:@"pixelSpacingX"] floatValue] :[[_horizontalAxis valueForKey:@"pixelSpacingY"] floatValue] :[[_horizontalAxis valueForKey:@"imageOrigin"] pointValue]];
		[*axis setDisplayTextualData:NO];
		[*axis setThickness:1]; [*axis setOpacity:.5];
		[*axis setSelectable:NO];
		NSTimeInterval group = [NSDate timeIntervalSinceReferenceDate];
		[landmark setGroupID:group];
		[*axis setGroupID:group];
		[[_viewerController imageView] roiSet:*axis];
		[[[_viewerController roiList] objectAtIndex:[[_viewerController imageView] curImage]] addObject:*axis];
		[*axis release];
	}
	
	NSPoint horizontalAxisD = [[[_horizontalAxis points] objectAtIndex:0] point] - [[[_horizontalAxis points] objectAtIndex:1] point];
	NSPoint axisPM = [[[landmark points] objectAtIndex:0] point];
	NSPoint axisP0 = axisPM+horizontalAxisD/2;
	NSPoint axisP1 = axisPM-horizontalAxisD/2;
	
	ROI* otherLandmark = landmark==_landmark1? _landmark2 : _landmark1;
	if (otherLandmark) {
		NSPoint otherPM = [[[otherLandmark points] objectAtIndex:0] point];
		axisP1 = NSMakeLine(axisP0, axisP1) * NSMakeLine(otherPM, !NSMakeVector(axisP0, axisP1));
		axisP0 = axisPM;
		
		// move the distance marker
		if (!_legInequality) {
			_legInequality = [[ROI alloc] initWithType:tMesure :[[_horizontalAxis valueForKey:@"pixelSpacingX"] floatValue] :[[_horizontalAxis valueForKey:@"pixelSpacingY"] floatValue] :[[_horizontalAxis valueForKey:@"imageOrigin"] pointValue]];
			[_legInequality setThickness:1]; [_legInequality setOpacity:.5];
			[_legInequality setSelectable:NO];
			[[_viewerController imageView] roiSet:_legInequality];
			[[[_viewerController roiList] objectAtIndex:[[_viewerController imageView] curImage]] addObject:_legInequality];
			[_legInequality release];
		}
		
		NSPoint p0 = (axisP0+axisP1)/2;
		NSPoint p1 = otherPM + (axisP0-axisP1)/2;
		[[_legInequality points] removeAllObjects];
		[_legInequality setPoints:[NSArray arrayWithObjects:[MyPoint point:p0], [MyPoint point:p1], NULL]];
		[_legInequality setName:[NSString stringWithFormat:@"Leg Inequality: %.3f cm", [_legInequality MesureLength:NULL]/_magnification]];
		[[NSNotificationCenter defaultCenter] postNotificationName:OsirixROIChangeNotification object:_legInequality userInfo:NULL];
	} else if (_legInequality) {
		[self removeRoiFromViewer:_legInequality];
		_legInequality = NULL;
	}
	
	if (!newAxis)
		if (axisP0 != [[[*axis points] objectAtIndex:0] point] || axisP1 != [[[*axis points] objectAtIndex:1] point]) {
			[[*axis points] removeAllObjects];
			newAxis = YES;
		}
	
	if (newAxis) {
		[*axis setPoints:[NSArray arrayWithObjects:[MyPoint point:axisP0], [MyPoint point:axisP1], NULL]];
		[[NSNotificationCenter defaultCenter] postNotificationName:OsirixROIChangeNotification object:*axis userInfo:NULL];
		[_viewerController bringToFrontROI:landmark]; // TODO: this makes the landmark disappear!
	}
	
	
	
	return newAxis; // returns YES if the axis was changed
}

-(void)roiChanged:(NSNotification*)notification {
	ROI* roi = [notification object];
	if (!roi) return;
	
	// verify that the ROI is on our viewer
	if (![_viewerController containsROI:roi]) return;
	
	// add to known list
	BOOL wasKnown = [_knownRois containsObject:roi];
	if (!wasKnown) [_knownRois addObject:roi];
	
	// if is _infoBoxRoi then return (we already know about it) // TODO: verify
	if (roi == _infoBox) return;	
	
	// step dependant
	if (!wasKnown) {
		if ([_sbs currentStep] == _stepCalibration)
			if (!_magnificationLine && [roi type] == tMesure) {
				_magnificationLine = roi;
				[roi setName:@"Calibration Line"];
			}
		
		if ([_sbs currentStep] == _stepAxes)
			if (!_horizontalAxis && [roi type] == tMesure) {
				_horizontalAxis = roi;
				[roi setName:@"Horizontal Axis"];
			} else if (!_femurAxis && [roi type] == tMesure) {
				_femurAxis = roi;
				[roi setName:@"Femur Axis"];
			}
		
		if ([_sbs currentStep] == _stepLandmarks)
			if (!_landmark1 && [roi type] == t2DPoint) {
				_landmark1 = roi;
				[roi setName:@"Landmark 1"];
			} else if (!_landmark2 && [roi type] == t2DPoint) {
				_landmark2 = roi;
				[roi setName:@"Landmark 2"];
			}
		
		if ([_sbs currentStep] == _stepCutting)
			if (!_femurRoi && [roi type] == tPencil) {
				_femurRoi = roi;
				[roi setName:@"Femur"];
			}
		
		if ([_sbs currentStep] == _stepCup)
			if (!_cupLayer && [roi type] == tLayerROI) {
				_cupLayer = roi;
				_cupTemplate = [[_plugin templatesWindowController] templateAtPath:[roi layerReferenceFilePath]];
			}
		
		if ([_sbs currentStep] == _stepStem)
			if (!_stemLayer && [roi type] == tLayerROI) {
				_stemLayer = roi;
				_stemTemplate = [[_plugin templatesWindowController] templateAtPath:[roi layerReferenceFilePath]];
			}
	}
	
	if (roi == _landmark1 || roi == _landmark2 || roi == _horizontalAxis) {
		[self landmarkChanged:_landmark1 axis:&_landmark1Axis];
		[self landmarkChanged:_landmark2 axis:&_landmark2Axis];
	}
	
	[self advanceAfterInput:roi];
}

- (void)roiRemoved:(NSNotification*)notification {
	ROI *roi = [notification object];
	
	[_knownRois removeObject:roi];

	if (roi == _magnificationLine) {
		_magnificationLine = NULL;
		[_stepCalibration setIsDone:NO];
		[_sbs setCurrentStep:_stepCalibration];
		[self computeMagnification];
	}
	
	if (roi == _horizontalAxis) {
		_horizontalAxis = NULL;
		[_stepAxes setIsDone:NO];
		[_sbs setCurrentStep:_stepAxes];
		[self computeVarious];
	}
	
	if (roi == _femurAxis) {
		_femurAxis = NULL;
		[_sbs setCurrentStep:_stepAxes];
		[self computeVarious];
	}
	
	if (roi == _landmark1) {
		_landmark1 = NULL;
		[self landmarkChanged:_landmark1 axis:&_landmark1Axis]; // removes _landmark1Axis
		if (_landmark2) {
			_landmark1 = _landmark2; _landmark2 = NULL;
			_landmark1Axis = _landmark2Axis; _landmark2Axis = NULL;
			[_landmark1 setName:@"Landmark 1"];
			if (![self landmarkChanged:_landmark1 axis:&_landmark1Axis])
				[[NSNotificationCenter defaultCenter] postNotificationName:OsirixROIChangeNotification object:_landmark1 userInfo:NULL];
		} else
			[_stepLandmarks setIsDone:NO];
		[_sbs setCurrentStep:_stepLandmarks];
		[self computeLegInequality];
	}
	
	if (roi == _landmark2) {
		_landmark2 = NULL;
		[self landmarkChanged:_landmark1 axis:&_landmark1Axis];
		[self landmarkChanged:_landmark2 axis:&_landmark2Axis];
		[self computeLegInequality];
	}
	
	if (roi == _femurRoi)
		_femurRoi = NULL;
	
	if (roi == _femurLayer) {
		_femurLayer = NULL;
		[_stepCutting setIsDone:NO];
		[_sbs setCurrentStep:_stepCutting];
	}
	
	if (roi == _cupLayer) {
		_cupLayer = NULL;
		_cupTemplate = NULL;
		[_stepCup setIsDone:NO];
		[_sbs setCurrentStep:_stepCup];
		[self computeVarious];
	}
	
	if (roi == _stemLayer) {
		_stemLayer = nil;
		_stemTemplate = NULL;
		[_stepStem setIsDone:NO];
		[_sbs setCurrentStep:_stepStem];
		[self computeVarious];
	}
	
	if (roi == _infoBox)
		_infoBox = NULL;

	[self advanceAfterInput:NULL];
}


#pragma mark General Methods

-(IBAction)resetSBS:(id)sender {
	[self resetSBSUpdatingView:YES];
}

- (void)resetSBSUpdatingView:(BOOL)updateView {
	[self removeRoiFromViewer:_stemLayer];
	[self removeRoiFromViewer:_cupLayer];
	[self removeRoiFromViewer:_femurLayer];
	[self removeRoiFromViewer:_femurRoi];
	[self removeRoiFromViewer:_landmark2];
	[self removeRoiFromViewer:_landmark1];
	[self removeRoiFromViewer:_femurAxis];
	[self removeRoiFromViewer:_horizontalAxis];
	[self removeRoiFromViewer:_magnificationLine];
	[self removeRoiFromViewer:_infoBox];
	[_viewerController roiDeleteAll:self];
	
	if (_planningDate) [_planningDate release]; _planningDate = NULL;
	
	if(updateView) {
		[_sbs reset:self];
		[[_viewerController imageView] display];
	}
}

#pragma mark Templates

-(IBAction)showTemplatesPanel:(id)sender {
	if ([[[_plugin templatesWindowController] window] isVisible]) return;
	[[[_plugin templatesWindowController] window] makeKeyAndOrderFront:sender];
	_userOpenedTemplates = [sender class] == [NSButton class];
}

-(void)hideTemplatesPanel {
	[[[_plugin templatesWindowController] window] orderOut:self];
}

#pragma mark Step by Step

-(void)stepByStep:(SBS*)sbs willBeginStep:(SBSStep*)step {
	if (sbs != _sbs)
		return; // this should never happen
	
	if ([_sbs currentStep] != step)
		[sbs setCurrentStep:step];

	BOOL showTemplates = NO, selfKey = NO;
	int tool = tROISelector;

	if (step == _stepCalibration) {
		tool = [_magnificationRadioCalibrate state]? tMesure : tROISelector;
		selfKey = YES;
	} else if (step == _stepAxes)
		tool = tMesure;
	else if (step == _stepLandmarks)
		tool = t2DPoint;
	else if (step == _stepCutting)
		tool = tPencil;
	else if (step == _stepCup)
		showTemplates = [[_plugin templatesWindowController] setFilter:@"Cup"];
	else if (step == _stepStem)
		showTemplates = [[_plugin templatesWindowController] setFilter:@"Stem"];
	else if (step == _stepSave)
		selfKey = YES;
	
	[_viewerController setROIToolTag:tool];
	if (showTemplates)
		[self showTemplatesPanel:self];
	else if (!_userOpenedTemplates) [self hideTemplatesPanel];
	
	[(ATPanel*)[self window] setCanBecomeKeyWindow:selfKey];
	[[_viewerController window] makeKeyAndOrderFront:self];
}

-(void)stepByStep:(SBS*)sbs valueChanged:(id)sender {
	// calibration
	if (sender == _magnificationRadioCustom)
		[_magnificationRadioCalibrate setState:![_magnificationRadioCustom state]];
	if (sender == _magnificationRadioCalibrate)
		[_magnificationRadioCustom setState:![_magnificationRadioCalibrate state]];
	if (sender == _magnificationRadioCustom || sender == _magnificationRadioCalibrate) {
		BOOL calibrate = [_magnificationRadioCalibrate state];
		[_magnificationCustomFactor setEnabled:!calibrate];
		[_magnificationCalibrateLength setEnabled:calibrate];
	}
	// cutting
	if (sender == _femurColorWell)
		[_femurLayer setNSColor:[sender color]];
	// placement
	if (sender == _neckSizePopUpButton)
		;
	if (sender == _femurOpacitySlider || sender == _femurColorWell) {
		[self setFemurLayerColor:[[_femurColorWell color] colorWithAlphaComponent:[sender floatValue]/100]];
	}
	
	[self advanceAfterInput:sender];
}

-(void)advanceAfterInput:(id)sender {
	if (sender == _magnificationRadioCustom || sender == _magnificationRadioCalibrate) {
		BOOL calibrate = [_magnificationRadioCalibrate state];
		[_viewerController setROIToolTag: calibrate? tMesure : tROISelector];
		[[self window] makeKeyWindow];
		if (calibrate)
			[_magnificationCalibrateLength performClick:self];
		else [_magnificationCustomFactor performClick:self];
	}
	
	if (sender == _magnificationLine || sender == _magnificationRadioCustom || sender == _magnificationRadioCalibrate || sender == _magnificationCustomFactor || sender == _magnificationCalibrateLength)
		[self computeMagnification];
	if (sender == _horizontalAxis || sender == _femurAxis)
		[self computeVarious];
	if (sender == _landmark1 || sender == _landmark1)
		[self computeLegInequality];
	if (sender == _cupLayer || sender == _stemLayer)
		[self computeVarious];

	
}

-(BOOL)stepByStep:(SBS*)sbs shouldValidateStep:(SBSStep*)step {
	NSString* errorMessage = NULL;
	
	if (step == _stepCalibration) {
		if ([_magnificationRadioCustom state]) {
			if ([_magnificationCustomFactor floatValue] <= 0)
				errorMessage = @"Please specify a custom magnification factor value.";
		} else
			if (!_magnificationLine)
				errorMessage = @"Please draw a line the size of the calibration object.";
			else if ([_magnificationCalibrateLength floatValue] <= 0)
				errorMessage = @"Please specify the real size of the calibration object.";
	}
	else if (step == _stepAxes) {
		if (!_horizontalAxis)
			errorMessage = @"Please draw a line parallel to the horizontal axis of the pelvis.";
	}
	else if (step == _stepLandmarks) {
		if (!_landmark1)
			errorMessage = @"Please locate one or two landmarks on the proximal femur (e.g. the tips of the greater trochanters).";
	}
	else if (step == _stepCutting) {
		if (!_femurRoi)
			errorMessage = @"Please encircle the proximal femur destined to receive the femoral implant. Femoral head and neck should not be included if you plan to remove them.";
	}
	else if (step == _stepCup) {
		if (!_cupLayer)
			errorMessage = @"Please select an acetabular template, rotate and locate the component into the pelvic bone.";
	}
	else if (step == _stepStem) {
		if (!_stemLayer)
			errorMessage = @"Please select a femoral template, drag it and drop it into the proximal femur, then rotate it.";
	}
	else if (step == _stepSave) {
		if ([[_plannersNameTextField stringValue] length] == 0)
			errorMessage = @"The planner's name must be specified.";
	}

	if (errorMessage)
		[[NSAlert alertWithMessageText:[step title] defaultButton:@"OK" alternateButton:NULL otherButton:NULL informativeTextWithFormat:errorMessage] beginSheetModalForWindow:[self window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
	return errorMessage == NULL;
}

-(ROI*)closestROIFromSet:(NSSet*)rois toPoints:(NSArray*)points {
	NSArray* roisArray = [rois allObjects];
	CGFloat distances[[rois count]];
	// fill distances
	for (unsigned i = 0; i < [rois count]; ++i) {
		distances[i] = MAXFLOAT;
		if (![roisArray objectAtIndex:i]) continue;
		NSPoint roiPoint = [[[[roisArray objectAtIndex:i] points] objectAtIndex:0] point];
		for (unsigned j = 0; j < [points count]; ++j)
			distances[i] = std::min(distances[i], NSDistance(roiPoint, [[points objectAtIndex:j] point]));
	}
	
	unsigned minIndex = 0;
	for (unsigned i = 1; i < [rois count]; ++i)
		if (distances[i] < distances[minIndex])
			minIndex = i;
	
	return [roisArray objectAtIndex:minIndex];
}

-(void)stepByStep:(SBS*)sbs validateStep:(SBSStep*)step {
	if (step == _stepCalibration) {
	}
	else if(step == _stepAxes) {
	}
	else if(step == _stepLandmarks) {
	}
	else if(step == _stepCutting) {
		if (!_femurLayer) {
			_femurLayer = [_viewerController createLayerROIFromROI:_femurRoi splineScale:.01];
			[_femurLayer roiMove:NSMakePoint(-10,10)]; // when the layer is created it is shifted, but we don't want this so we move it back // TODO: pas possible de faire [x setOrigin:[x origin]] ?
			[_femurLayer setNSColor:[_femurColorWell color]];
			
			ROI* nearestLandmark = [self closestROIFromSet:[NSSet setWithObjects:_landmark1, _landmark2, NULL] toPoints:[_femurRoi points]];
			_femurLandmark = [[ROI alloc] initWithType:t2DPoint :[[nearestLandmark valueForKey:@"pixelSpacingX"] floatValue] :[[nearestLandmark valueForKey:@"pixelSpacingY"] floatValue] :[[nearestLandmark valueForKey:@"imageOrigin"] pointValue]];
			[_femurLandmark setROIRect:[nearestLandmark rect]];
			[_femurLandmark setName:[NSString stringWithFormat:@"%@'",[nearestLandmark name]]]; // same name + prime
			[_femurLandmark setDisplayTextualData:NO];
			
			[[_viewerController imageView] roiSet:_femurLandmark];
			[[[_viewerController roiList] objectAtIndex:[[_viewerController imageView] curImage]] addObject:_femurLandmark];
			[[NSNotificationCenter defaultCenter] postNotificationName:OsirixROIChangeNotification object:_femurLandmark userInfo:NULL];
			
			// bring the point to front (we don't want it behind the layer)
			[_viewerController bringToFrontROI:_femurLandmark];
			
			// group the layer and the points
			NSTimeInterval group = [NSDate timeIntervalSinceReferenceDate];
			[_femurLayer setGroupID:group];
			[_femurLandmark setGroupID:group];
		}
	}
	else if (step == _stepCup) {
	}
	else if (step == _stepStem) {
		[_stemLayer setGroupID:[_femurLayer groupID]];
		[_viewerController bringToFrontROI:_stemLayer];
	}
	else if (step == _stepSave) {
		if (_planningDate) [_planningDate release];
		_planningDate = [[NSDate date] retain];
		[self updateInfo];

		NSManagedObject* study = [[[_viewerController fileList:0] objectAtIndex:[[_viewerController imageView] curImage]] valueForKeyPath:@"series.study"];
		NSArray* seriesArray = [[study valueForKey:@"series"] allObjects];

		NSString* namePrefix = @"Planning";

		int n = 1, m;
		for (unsigned i = 0; i < [seriesArray count]; i++) {
			NSString *currentSeriesName = [[seriesArray objectAtIndex:i] valueForKey:@"name"];
			if ([currentSeriesName hasPrefix:namePrefix]) {
				m = [[currentSeriesName substringFromIndex:[namePrefix length]+1] intValue];
				if (n <= m) n = m+1;
			}
		}
		
		NSString* name = [NSString stringWithFormat:@"%@ %d", namePrefix, n];
		[_viewerController deselectAllROIs];
		[_viewerController exportDICOMFileInt:YES withName:name];
		[[BrowserController currentBrowser] checkIncoming:self];
		
		// send to PACS
		if ([_sendToPACSButton state]==NSOnState)
			_imageToSendName = [name retain];
	}
}


#pragma mark Steps specific methods

-(void)setFemurLayerColor:(NSColor*)color {
	if (!_femurLayer) return;
	[_femurLayer setNSColor:color];
	[_femurOpacityTextField setFloatValue:[color alphaComponent]];
	[[NSNotificationCenter defaultCenter] postNotificationName:OsirixROIChangeNotification object:_femurLayer userInfo:NULL];
}

// dicom was added to database, send it to PACS
-(void)sendToPACS:(NSNotification*)notification {
	if (_sendToPACSButton && _imageToSendName) {
//		NSLog(@"send to PACS");
		NSManagedObject *study = [[[_viewerController fileList:0] objectAtIndex:[[_viewerController imageView] curImage]] valueForKeyPath:@"series.study"];
		NSArray	*seriesArray = [[study valueForKey:@"series"] allObjects];
//		NSLog(@"[seriesArray count] : %d", [seriesArray count]);
		NSString *pathOfImageToSend;
		
		
		NSManagedObject* imageToSend = NULL;
		
		for (unsigned i = 0; i < [seriesArray count]; i++)
		{
			NSString *currentSeriesName = [[seriesArray objectAtIndex:i] valueForKey:@"name"];
//			NSLog(@"currentSeriesName : %@", currentSeriesName);
			if([currentSeriesName isEqualToString:_imageToSendName])
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

- (void)createInfoBox {
	if(_infoBox) return;
	_infoBox = [[ROI alloc] initWithType:tText :[[_viewerController imageView] pixelSpacingX] :[[_viewerController imageView] pixelSpacingY] :[[_viewerController imageView] origin]];
	[_infoBox setROIRect:NSMakeRect([[[_viewerController imageView] curDCM] pwidth]/2.0, [[[_viewerController imageView] curDCM] pheight]/2.0, 0.0, 0.0)];
	[[_viewerController imageView] roiSet:_infoBox];
	[[[_viewerController roiList] objectAtIndex:[[_viewerController imageView] curImage]] addObject:_infoBox];
	[[NSNotificationCenter defaultCenter] postNotificationName:OsirixROIChangeNotification object:_infoBox userInfo:NULL];
}


-(void)computeMagnification {
	_magnification = kInvalidMagnification;
	
	if ([_magnificationRadioCalibrate state]) {
		if (!_magnificationLine || [[_magnificationLine points] count] != 2) return;
		NSLog(@"_magnificationCalibrateLength %f", [_magnificationCalibrateLength floatValue]);
		[_magnificationCustomFactor setFloatValue:[_magnificationLine MesureLength:NULL]/[_magnificationCalibrateLength floatValue]];
	}
	
	_magnification = [_magnificationCustomFactor floatValue];
	
	[self computeVarious];
}


-(void)computeVarious {
	// horizontal angle
	_horizontalAngle = kInvalidAngle;
	if (_horizontalAxis && [[_horizontalAxis points] count] == 2)
		_horizontalAngle = NSAngle([[[_horizontalAxis points] objectAtIndex:0] point], [[[_horizontalAxis points] objectAtIndex:1] point]);
	
	// femur angle
	_femurAngle = kInvalidAngle;
	if (_femurAxis && [[_femurAxis points] count] == 2)
		_femurAngle = NSAngle([[[_femurAxis points] objectAtIndex:0] point], [[[_femurAxis points] objectAtIndex:1] point]);
	else if (_horizontalAngle != kInvalidAngle)
		_femurAngle = _horizontalAngle+pi/2;
	
	
}

-(void)computeLegInequality {
	
}

-(void)computeOffset {
	
}

-(void)updateInfo {
	// TODO: update contents of infoBoxROI
}

@end
