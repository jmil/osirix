//
//  ArthroplastyTemplatingStepByStepController.h
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Step.h"
#import "StepByStep.h"
#import "SBSView.h"

#import "ViewerController.h"
#import "DCMView.h"
#import "DCMPix.h"
#import "ROI.h"

#import "ArthroplastyTemplate.h"
@class ArthroplastyTemplatingWindowController;

@interface ArthroplastyTemplatingStepByStepController : NSWindowController {
	IBOutlet StepByStep *stepByStep;
	Step *stepPlannerName, *stepHorizontalAxis, *stepFemurAxis, *stepCalibrationPoints, *stepCutting, *stepCup, *stepStem, *stepPlacement, *stepSave;
	IBOutlet NSView *viewPlannerName, *viewHorizontalAxis, *viewFemurAxis, *viewCalibrationPoints, *viewCutting, *viewCup, *viewStem, *viewPlacement, *viewSave;
	
	ViewerController *viewerController;
	int userTool; // stores the tool that the user was using before starting this step by step
	int currentTool; // tool used for the step by step
	ROI *horizontalAxis, *femurAxis, *pointA1, *pointA2, *pointB1, *pointB2, *femurROI, *femurLayer, *cupLayer, *stemLayer, *infoBoxROI;
	ROI **pointerROI;
	int expectedROIType;
	
	NSString *nameROI;
	
	ArthroplastyTemplate *cupTemplate, *stemTemplate;
	
	IBOutlet NSTextField *plannerNameTextField;
	
	float horizontalAngle, cupAngle;
	IBOutlet NSTextField *cupAngleTextField;
	
	IBOutlet NSTextField *femurOpacityTextField;
	IBOutlet NSTextField *verticalOffsetTextField;
	IBOutlet NSTextField *horizontalOffsetTextField;
	IBOutlet NSColorWell *femurColorWell;
	
	IBOutlet NSTextField *chosenSizeTextField;
	
	NSPoint planningOffset;
	NSDate *planningDate;
	
	ArthroplastyTemplatingWindowController *templateWindowController;
	
	IBOutlet NSButton *sendToPACSButton;
	NSString *imageToSendName;
}


#pragma mark Link to OsiriX

- (void)setViewerController:(ViewerController*)aViewerController;
- (void)viewerWillClose:(NSNotification*)notification;


#pragma mark Templates

- (IBAction)showTemplatePanel:(id)sender;
- (void)showTemplatePanel;
- (void)closeTemplatePanel;


#pragma mark General Methods

- (IBAction)resetStepByStep:(id)sender;
- (void)resetStepByStepUpdatingView:(BOOL)updateView;


#pragma mark StepByStep Delegate Methods

- (void)willBeginStep:(Step*)step;
- (BOOL)shouldValidateStep:(Step*)step;
- (void)validateStep:(Step*)step;


#pragma mark Steps specific Methods

- (void)computeOffset;
- (IBAction)changeFemurLayerOpacity:(id)sender;
- (void)setFemurLayerOpacity:(float)opacity;
- (IBAction)changeFemurLayerColor:(id)sender;
- (void)setFemurLayerColor:(NSColor*)color;
- (void)computeHorizontalAngle;
- (void)computeCupAngle;


#pragma mark Result

- (void)createInfoBoxROI;
- (IBAction)updateInfoBoxROI:(id)sender;
- (void)updateInfoBoxROI;

@end
