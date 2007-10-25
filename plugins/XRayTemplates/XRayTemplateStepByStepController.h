//
//  XRayTemplateStepByStepController.h
//  XRayTemplatesPlugin
//
//  Created by Joris Heuberger on 04/04/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Step.h"
#import "StepByStep.h"
#import "StepByStepView.h"

#import "ViewerController.h"
#import "DCMView.h"
#import "DCMPix.h"
#import "ROI.h"

#import "XRayTemplateWindowController.h"
#import "XRayTemplate.h"

@interface XRayTemplateStepByStepController : NSWindowController {
	IBOutlet StepByStep *stepByStep;
	Step *stepMagnificationFactor, *stepLandmarks, *stepPlannerName, *stepHorizontalAxis, *stepFemurAxis, *stepCalibrationPoints, *stepCutting, *stepCup, *stepStem, *stepPlacement, *stepSave;
	IBOutlet NSView *viewMagnificationFactor, *viewLandmarks, *viewPlannerName, *viewHorizontalAxis, *viewFemurAxis, *viewCalibrationPoints, *viewCutting, *viewCup, *viewStem, *viewPlacement, *viewSave;
	
	ViewerController *viewerController;
	int userTool; // stores the tool that the user was using before starting this step by step
	int currentTool; // tool used for the step by step
	ROI *calibrationMeasurement, *horizontalAxis, *femurAxis, *point1, *point2, *point1Axis, *point2Axis, *point3Axis, *pointA1, *pointA2, *pointB1, *pointB2, *femurROI, *femurLayer, *cupLayer, *stemLayer, *infoBoxROI;
	ROI **pointerROI;
	int expectedROIType;
	
	float legInequality, finalLegInequality;
	
	NSString *nameROI;
	
	XRayTemplate *cupTemplate, *stemTemplate;
	
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
	
	XRayTemplateWindowController *templateWindowController;
	
	IBOutlet NSButton *sendToPACSButton;
	NSString *imageToSendName;
	
	IBOutlet NSButton *standardMagnificationFactorButton, *manualCalibrationButton;
	IBOutlet NSTextField *standardMagnificationFactorTextField, *manualCalibrationTextField;
	float magnificationFactor;
	float pixelSpacingX, pixelSpacingY;
}

#pragma mark -
#pragma mark Link to OsiriX

- (void)setViewerController:(ViewerController*)aViewerController;
- (void)viewerWillClose:(NSNotification*)notification;

#pragma mark -
#pragma mark Templates

- (IBAction)showTemplatePanel:(id)sender;
- (void)showTemplatePanel;
- (void)closeTemplatePanel;

#pragma mark -
#pragma mark General Methods

- (IBAction)resetStepByStep:(id)sender;
- (void)resetStepByStepUpdatingView:(BOOL)updateView;

#pragma mark -
#pragma mark StepByStep Delegate Methods

- (void)willBeginStep:(Step*)step;
- (BOOL)shouldValidateStep:(Step*)step;
- (void)validateStep:(Step*)step;

#pragma mark -
#pragma mark Steps specific Methods

- (void)computeOffset;
- (IBAction)changeFemurLayerOpacity:(id)sender;
- (void)setFemurLayerOpacity:(float)opacity;
- (IBAction)changeFemurLayerColor:(id)sender;
- (void)setFemurLayerColor:(NSColor*)color;
- (void)computeHorizontalAngle;
- (void)computeCupAngle;
- (float)femurRotationAngle;
- (void)updatePointsAxis;
- (void)computeLegInequalityMeasurement;
- (float)computeLegInequalityUsingPoint:(ROI*)pointROI;
- (ROI*)femurROINearestPoint;
- (IBAction)standardMagnificationFactorButtonPressed:(id)sender;
- (IBAction)manualCalibrationButtonPressed:(id)sender;
- (void)keyDownNotification:(NSNotification*)notification;
- (void)increaseSizeOfCurrentTemplate;
- (void)decreaseSizeOfCurrentTemplate;
- (void)rotateLeftCurrentTemplate;
- (void)rotateRightCurrentTemplate;
- (void)rotateLayerROI:(ROI*)roi withAngle:(float)angle;
- (void)calibrate;

#pragma mark -
#pragma mark Result

- (void)createInfoBoxROI;
- (IBAction)updateInfoBoxROI:(id)sender;
- (void)updateInfoBoxROI;

@end
