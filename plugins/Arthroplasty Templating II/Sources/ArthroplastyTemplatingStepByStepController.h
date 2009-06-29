//
//  ArthroplastyTemplatingStepByStepController.h
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SBSStep, SBS, SBSView;

#import "ViewerController.h"
#import "DCMView.h"
#import "DCMPix.h"
#import "ROI.h"

#import "ArthroplastyTemplate.h"
@class ArthroplastyTemplatingPlugin;

@interface ArthroplastyTemplatingStepByStepController : NSWindowController {
	ArthroplastyTemplatingPlugin* _plugin;
	ViewerController* _viewerController;
	
	IBOutlet SBS* _sbs;
	SBSStep *_stepCalibration, *_stepAxes, *_stepLandmarks, *_stepCutting, *_stepCup, *_stepStem, *_stepPlacement, *_stepSave;
	IBOutlet NSView *_viewCalibration, *_viewAxes, *_viewLandmarks, *_viewCutting, *_viewCup, *_viewStem, *_viewPlacement, *_viewSave;
	
	NSMutableSet* _knownRois;
	ROI *_magnificationLine, *_horizontalAxis, *_femurAxis, *_landmark1, *_landmark2, *_femurRoi, *_femurLayer, *_cupLayer, *_stemLayer, *_infoBox;
	ROI *_femurLandmark, *_landmark1Axis, *_landmark2Axis, *_legInequality;
	ArthroplastyTemplate *_cupTemplate, *_stemTemplate;
	
	// calibration
	IBOutlet NSButton *_magnificationRadioCustom, *_magnificationRadioCalibrate;
	IBOutlet NSTextField *_magnificationCustomFactor, *_magnificationCalibrateLength;
	CGFloat _magnification;
	// axes
	float _horizontalAngle, _femurAngle;
	// cup
	IBOutlet NSTextField* _cupAngleTextField;
	float _cupAngle;
	// stem
	IBOutlet NSTextField* _stemAngleTextField;
	float _stemAngle;
	// placement
	IBOutlet NSTextField* _femurOpacityTextField;
	IBOutlet NSSlider* _femurOpacitySlider;
	IBOutlet NSPopUpButton* _neckSizePopUpButton;

	IBOutlet NSTextField* _verticalOffsetTextField;
	IBOutlet NSTextField* _horizontalOffsetTextField;
	IBOutlet NSColorWell* _femurColorWell;
	IBOutlet NSTextField* _plannersNameTextField;
	
	NSPoint _planningOffset;
	NSDate* _planningDate;
	BOOL _userOpenedTemplates;
	
	IBOutlet NSButton* _sendToPACSButton;
	NSString* _imageToSendName;
	
}

-(id)initWithPlugin:(ArthroplastyTemplatingPlugin*)plugin viewerController:(ViewerController*)viewerController;

#pragma mark Templates

- (IBAction)showTemplatesPanel:(id)sender;
-(void)hideTemplatesPanel;

#pragma mark General Methods

- (IBAction)resetSBS:(id)sender;
- (void)resetSBSUpdatingView:(BOOL)updateView;

#pragma mark StepByStep Delegate Methods

-(void)stepByStep:(SBS*)sbs willBeginStep:(SBSStep*)step;
-(void)advanceAfterInput:(id)change;
-(BOOL)stepByStep:(SBS*)sbs shouldValidateStep:(SBSStep*)step;
-(void)stepByStep:(SBS*)sbs validateStep:(SBSStep*)step;

#pragma mark Steps specific Methods

-(void)setFemurLayerColor:(NSColor*)color;

-(void)computeMagnification;
-(void)computeVarious;
-(void)computeLegInequality;
-(void)computeOffset;
-(void)updateInfo;

#pragma mark Result


@end
