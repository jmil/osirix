//
//  EjectionFractionStepsController.h
//  Ejection Fraction II
//
//  Created by Alessandro Volz on 7/20/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

@class N2Steps, N2Step, EjectionFractionPlugin, ROI;

@interface EjectionFractionStepsController : NSWindowController {
	EjectionFractionPlugin* _plugin;

	IBOutlet N2Steps* _steps;
	IBOutlet N2StepsView* _stepsView;

	N2Step* _stepAlgorithm;
	IBOutlet NSView* _viewAlgorithm;
	CGFloat _viewAlgorithmOriginalFrameHeight;
	IBOutlet NSPopUpButton* _viewAlgorithmChoice;
	IBOutlet NSImageView* _viewAlgorithmPreview;
	NSMutableArray* _activeSteps;
	
	N2Step* _stepDiastolic;
	ROI *_diasLongAxis, *_diasArea1, *_diasArea2;
	
	N2Step* _stepSystolic;
	ROI *_systLongAxis, *_systArea1, *_systArea2;
}

-(id)initWithPlugin:(EjectionFractionPlugin*)plugin;
-(void)steps:(N2Steps*)steps willBeginStep:(N2Step*)step;
-(void)steps:(N2Steps*)steps valueChanged:(id)sender;
-(BOOL)steps:(N2Steps*)steps shouldValidateStep:(N2Step*)step;
-(void)steps:(N2Steps*)steps validateStep:(N2Step*)step;

@end
