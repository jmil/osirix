//
//  XRayTemplateStepByStepController.m
//  XRayTemplatesPlugin
//
//  Created by joris on 04/04/07.
//  Copyright 2007 OsiriX Team. All rights reserved.
//

#import "XRayTemplateStepByStepController.h"
#import "SendController.h"
#import "BrowserController.h"
#import "OsiriX/DCM.h"

#define STANDARD_MAGNIFICATION_FACTOR 1.15
//#define BETAVERSION

#import </usr/include/objc/objc-class.h>
void MethodSwizzle(Class aClass, SEL orig_sel, SEL alt_sel)
{
	#ifndef __LP64__
    Method orig_method = nil, alt_method = nil;

    // First, look for the methods
    orig_method = class_getInstanceMethod(aClass, orig_sel);
    alt_method = class_getInstanceMethod(aClass, alt_sel);

    // If both are found, swizzle them
    if ((orig_method != nil) && (alt_method != nil))
        {
        char *temp1;
        IMP temp2;

        temp1 = orig_method->method_types;
        orig_method->method_types = alt_method->method_types;
        alt_method->method_types = temp1;

        temp2 = orig_method->method_imp;
        orig_method->method_imp = alt_method->method_imp;
        alt_method->method_imp = temp2;
        }
	#endif
}

@interface DCMView (myMethods)

- (void)myKeyDown:(NSEvent *)theEvent;

@end

@implementation DCMView (myMethods)

- (void)myKeyDown:(NSEvent *)theEvent;
{
	unichar	c = [[theEvent characters] characterAtIndex:0];
	if((c == NSLeftArrowFunctionKey) || (c == NSRightArrowFunctionKey) || (c == NSUpArrowFunctionKey) || (c == NSDownArrowFunctionKey) || c == 13 || c == 3 || c == '	') // Return - Enter - Tab
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"XRayTemplateKeyDownNotification" object:theEvent];
	}
	else
	{
		[self myKeyDown:theEvent];
	}
}

@end

//@interface NSPanel (myMethods)
//
//- (void)myKeyDown:(NSEvent *)theEvent;
//
//@end
//
//@implementation NSPanel (myMethods)
//
//- (void)myKeyDown:(NSEvent *)theEvent;
//{
//	unichar	c = [[theEvent characters] characterAtIndex:0];
//	if((c == NSLeftArrowFunctionKey) || (c == NSRightArrowFunctionKey) || (c == NSUpArrowFunctionKey) || (c == NSDownArrowFunctionKey) || c == 13 || c == 3 || c == '	') // Return - Enter - Tab
//	{
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"XRayTemplateKeyDownNotification" object:theEvent];
//	}
//	else
//	{
//		[self myKeyDown:theEvent];
//	}
//}
//
//@end

@implementation XRayTemplateStepByStepController

#pragma mark -
#pragma mark Initialization

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	NSLog(@"initWithWindowNibName");
	self = [super initWithWindowNibName:windowNibName];
	if (self != nil)
	{
		[[self window] setFrameAutosaveName:@"XrayTemplateStepByStepPanel"];
	}
	NSLog(@"initWithWindowNibName END");
	return self;
}

- (void)awakeFromNib
{	
	NSLog(@"awakeFromNib");
	//[[self window] setFrameAutosaveName:@"XrayTemplateStepByStepPanel"];
	
	stepMagnificationFactor = [stepByStep addStepWithTitle:@"Magnification Factor" enclosedView:viewMagnificationFactor];
	stepHorizontalAxis = [stepByStep addStepWithTitle:@"Horizontal Axis" enclosedView:viewHorizontalAxis];
	stepLandmarks = [stepByStep addStepWithTitle:@"Leg length inequality measurement" enclosedView:viewLandmarks];
	stepFemurAxis = [stepByStep addStepWithTitle:@"Femur Axis" enclosedView:viewFemurAxis];
	//stepCalibrationPoints = [stepByStep addStepWithTitle:@"Femoral landmarks" enclosedView:viewCalibrationPoints];
	stepCutting = [stepByStep addStepWithTitle:@"Femur identification" enclosedView:viewCutting];
	stepCup = [stepByStep addStepWithTitle:@"Cup" enclosedView:viewCup];
	stepStem = [stepByStep addStepWithTitle:@"Stem" enclosedView:viewStem];
	stepPlacement = [stepByStep addStepWithTitle:@"Reduction" enclosedView:viewPlacement];
	stepPlannerName = [stepByStep addStepWithTitle:@"Planner's name" enclosedView:viewPlannerName];
	stepSave = [stepByStep addStepWithTitle:@"Save" enclosedView:viewSave];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roiChanged:) name:@"roiChange" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roiRemoved:) name:@"removeROI" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:@"NSWindowWillCloseNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendToPACS:) name:@"OsirixAddToDBNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:@"CloseViewerNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyDownNotification:) name:@"XRayTemplateKeyDownNotification" object:nil];
		
	[[stepByStep view] setControlColor:[NSColor whiteColor]];
	[[stepByStep view] setDisabledControlColor:[NSColor grayColor]];
	
//	[[self window] orderOut:self];
//	[stepByStep enableSteps];
//	[stepByStep showFirstStep];
//	[[self window] orderFront:self];
	
	[standardMagnificationFactorTextField setFloatValue:STANDARD_MAGNIFICATION_FACTOR];
	
	#ifdef BETAVERSION
		if(betaVersionTextField==nil)
		{
			NSRunCriticalAlertPanel(@"Warning", @"This plugin is a Beta version. Don't use it in clinical practice!", @"OK", nil, nil);
			[self release];
		}
		else
		{
			[betaVersionTextField setFrameOrigin:NSMakePoint(0.0,0.0)];
			[betaVersionTextField setFrameSize:NSMakeSize(280,17)];
			[betaVersionTextField setStringValue:@"Beta version! No clinical use!"];
			[[self window] setTitle:@"Beta version! No clinical use!"];
			[betaVersionTextField setHidden:NO];
			[betaVersionTextField setEnabled:YES];
			[betaVersionTextField setTextColor:[NSColor whiteColor]];
			[betaVersionTextField setBackgroundColor:[NSColor clearColor]];
			[betaVersionTextField setDrawsBackground:NO];
		}
	#endif
	NSLog(@"awakeFromNib END");
}

- (void)dealloc
{
	NSLog(@"XRayTemplateStepByStepController dealloc");
	[self resetStepByStepUpdatingView:NO];
	
	[stepPlannerName release];
	[stepMagnificationFactor release];
	[stepLandmarks release];
	[stepHorizontalAxis release];
	[stepFemurAxis release];
	//[stepCalibrationPoints release];
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
	
	[[viewerController imageView] setCurrentTool:userTool];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:userTool], @"toolIndex", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"defaultToolModified" object:nil userInfo:userInfo];

	[viewerController release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

    MethodSwizzle([DCMView class], @selector(myKeyDown:), @selector(keyDown:));
	
	[super dealloc];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	if([[aNotification object] isEqualTo:[self window]])
	{
		[templateWindowController close];

		[[[viewerController imageView] curDCM] setPixelSpacingX: pixelSpacingX];
		[[[viewerController imageView] curDCM] setPixelSpacingY: pixelSpacingY];
		
//		NSPoint origin = [[self window] frame].origin;
//		[[NSUserDefaults standardUserDefaults] setFloat:origin.x forKey:@"XRayTemplatePluginStepByStepWindowOriginX"];
//		[[NSUserDefaults standardUserDefaults] setFloat:origin.x forKey:@"XRayTemplatePluginStepByStepWindowOriginY"];
		
		[self release];
	}
}

- (IBAction)showWindow:(id)sender;
{
	NSLog(@"showWindow");
	
	[super showWindow:sender];

//	float x = [[NSUserDefaults standardUserDefaults] floatForKey:@"XRayTemplatePluginStepByStepWindowOriginX"];
//	float y = [[NSUserDefaults standardUserDefaults] floatForKey:@"XRayTemplatePluginStepByStepWindowOriginY"];
//
//
//
//	if(x>0 || y>0)
//	{
//		NSLog(@"windowOrigin");
//		NSPoint origin = NSMakePoint(x, y);
//		[[self window] setFrameOrigin:origin];
//	}
	
[stepByStep showFirstStep];
	
    MethodSwizzle([DCMView class], @selector(keyDown:), @selector(myKeyDown:));
	
	
	
NSLog(@"showWindow END");
}

- (void)viewerWillClose:(NSNotification*)notification;
{
	[self close];
}

#pragma mark -
#pragma mark Link to OsiriX

- (void)setViewerController:(ViewerController*)aViewerController;
{
	if(viewerController!=aViewerController)
	{
		[viewerController release];
		viewerController = aViewerController;
		[viewerController retain];
		
		DCMObject *dcmObject = [DCMObject objectWithContentsOfFile:[[[viewerController imageView] curDCM] srcFile] decodingPixelData:NO];
		if (dcmObject)
		{
			NSArray *pixelSpacing = [dcmObject attributeArrayWithName:@"PixelSpacing"];
			if([pixelSpacing count] >= 2)
			{
				pixelSpacingY = [[pixelSpacing objectAtIndex:0] floatValue];
				pixelSpacingX = [[pixelSpacing objectAtIndex:1] floatValue];
			}
			else if([pixelSpacing count] >= 1)
			{
				pixelSpacingY = [[pixelSpacing objectAtIndex:0] floatValue];
				pixelSpacingX = [[pixelSpacing objectAtIndex:0] floatValue];
			}
			else
			{
				NSArray *pixelSpacing = [dcmObject attributeArrayWithName:@"ImagerPixelSpacing"];
				if([pixelSpacing count] >= 2)
				{
					pixelSpacingY = [[pixelSpacing objectAtIndex:0] floatValue];
					pixelSpacingX = [[pixelSpacing objectAtIndex:1] floatValue];
				}
				else if([pixelSpacing count] >= 1)
				{
					pixelSpacingY = [[pixelSpacing objectAtIndex:0] floatValue];
					pixelSpacingX = [[pixelSpacing objectAtIndex:0] floatValue];
				}
			}
		}
	}
	userTool = [[viewerController imageView] currentTool];
//	[stepByStep showFirstStep];
}

- (void)roiChanged:(NSNotification*)notification;
{
///	if([notification userInfo]) return;
	if(![[self window] isVisible]) return;
	
	ROI *roi = [notification object];
	if(roi==nil) return;
	if(roi==infoBoxROI) return;

//	NSLog(@"roiChanged");
//	NSLog(@"roi name : %@", [roi name]);
//	NSLog(@"roi type : %d", [roi type]);
//	NSLog(@"roi uniqueID : %@", [roi valueForKey:@"uniqueID"]);

	if(pointerROI)
	{
		if(*pointerROI==nil && [roi type]==expectedROIType)
		{
			if(![horizontalAxis isEqualTo:roi] && ![femurAxis isEqualTo:roi] && ![pointA1 isEqualTo:roi] && ![pointB1 isEqualTo:roi] && ![femurROI isEqualTo:roi] && ![femurLayer isEqualTo:roi] && ![cupLayer isEqualTo:roi] && ![stemLayer isEqualTo:roi] && ![point1 isEqualTo:roi] && ![point2 isEqualTo:roi] && ![point1Axis isEqualTo:roi] && ![point2Axis isEqualTo:roi] && ![calibrationMeasurement isEqualTo:roi])
				*pointerROI = roi;
				[*pointerROI setDisplayTextualData:NO];
		}
		if(nameROI)[*pointerROI setName:nameROI];
	}
	
	if(femurLayer!=nil && stemLayer!=nil)
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
			if([[horizontalAxis points] count]>0)
			{
				[self computeHorizontalAngle];
				[self updatePointsAxis];
				[self computeLegInequalityMeasurement];
			}
		}
	}

	if(point1Axis!=nil)
		if(roi==point1Axis)
			[self updatePointsAxis];

	if(point2Axis!=nil)
		if(roi==point2Axis)
			[self updatePointsAxis];
				
	if(point1Axis!=nil && point2Axis!=nil)
	{
		if(roi==point1Axis || roi==point2Axis )//|| roi==horizontalAxis)
		{
			[self updatePointsAxis];
			[self computeLegInequalityMeasurement];
			[self updateInfoBoxROI];
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
	
	if(pointA2)
	{
		if(roi==pointA2)
		{
			[self computeLegInequalityMeasurement];
			[self updateInfoBoxROI];
		}
	}

	if(femurAxis!=nil)
	{
		if(roi==femurAxis)
		{
			[self computeOffset];
			[self updateInfoBoxROI];
		}
	}

//	if(calibrationMeasurement!=nil)
//	{
//		if(roi==calibrationMeasurement)
//		{
//			if([[calibrationMeasurement points] count]>0)
//			{
//				[self calibrate];
//				[self updateInfoBoxROI];
//			}
//		}
//	}


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

	if([[stepByStep currentStep] isEqualTo:stepLandmarks])
	{
		if([roi type]==t2DPoint)
		{
			if(point1==nil && roi!=point2)
			{
				point1 = roi;
				[self updatePointsAxis];
			}
			else if(point2==nil && roi!=point1)
			{
				point2 = roi;
				[self updatePointsAxis];
			}
		}
	}
	
	if(stemLayer)
	{
		if(stemTemplate==nil)
			stemTemplate = [templateWindowController templateAtPath:[stemLayer layerReferenceFilePath]];
	}

	if(cupLayer)
	{
		if(cupTemplate==nil)
			cupTemplate = [templateWindowController templateAtPath:[cupLayer layerReferenceFilePath]];
	}
}

- (void)roiRemoved:(NSNotification*)notification;
{
	ROI *roi = [notification object];

//	NSLog(@"roiRemoved");
//	NSLog(@"roi name : %@", [roi name]);
//	NSLog(@"roi type : %d", [roi type]);
//	NSLog(@"roi uniqueID : %@", [roi valueForKey:@"uniqueID"]);

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
	
//	if([pointA1 isEqualTo:roi])
//	{
//		pointA1 = nil;
//		if(pointA2)
//		{
//			[[[viewerController roiList] objectAtIndex:0] removeObject:pointA2];
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointA2 userInfo:nil];
//		}
//		
//		if(pointB1==nil)
//		{
//			[[[viewerController roiList] objectAtIndex:0] removeObject:femurLayer];
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurLayer userInfo:nil];
//			[stepCalibrationPoints setIsDone:NO];
//			[stepCutting setIsDone:NO];
//			[stepStem setIsDone:NO];
//			[stepByStep setCurrentStep:stepCalibrationPoints];
//		}
//	}
	
//	if([pointB1 isEqualTo:roi])
//	{
//		pointB1 = nil;
//		if(pointB2)
//		{
//			[[[viewerController roiList] objectAtIndex:0] removeObject:pointB2];
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointB2 userInfo:nil];
//		}
//		if(pointA1==nil)
//		{
//			[[[viewerController roiList] objectAtIndex:0] removeObject:femurLayer];
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurLayer userInfo:nil];
//			[stepCalibrationPoints setIsDone:NO];
//			[stepCutting setIsDone:NO];
//			[stepStem setIsDone:NO];
//			[stepByStep setCurrentStep:stepCalibrationPoints];
//		}
//	}
	
	if([femurROI isEqualTo:roi])
	{
		femurROI = nil;
		pointerROI = nil;
	}
	
	if([femurLayer isEqualTo:roi])
	{
		femurLayer = nil;
		[stepCutting setIsDone:NO];
		[stepByStep setCurrentStep:stepCutting];
	}
	
	if([cupLayer isEqualTo:roi])
	{
		NSLog(@"remove cupLayer");
		cupLayer = nil;
		if(cupTemplate)
		{
			NSLog(@"release cupTemplate");
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
	
	if([point1 isEqualTo:roi])
	{
		point1 = nil;
		[stepLandmarks setIsDone:NO];
		[stepByStep setCurrentStep:stepLandmarks];

		if(point2)
		{
			[[[viewerController roiList] objectAtIndex:0] removeObject:point2];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:point2 userInfo:nil];
			if(point2Axis)
			{
				[[[viewerController roiList] objectAtIndex:0] removeObject:point2Axis];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:point2Axis userInfo:nil];
			}
		}
		pointA1 = nil;
	}

	if([point2 isEqualTo:roi])
	{
		point2 = nil;
		[stepLandmarks setIsDone:NO];
		[stepByStep setCurrentStep:stepLandmarks];
		if(point1)
		{
			[[[viewerController roiList] objectAtIndex:0] removeObject:point2];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:point2 userInfo:nil];
			if(point1Axis)
			{
				[[[viewerController roiList] objectAtIndex:0] removeObject:point1Axis];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:point1Axis userInfo:nil];
			}
		}

	}

	if([point1Axis isEqualTo:roi])
	{
		point1Axis = nil;
		[stepLandmarks setIsDone:NO];
		[stepByStep setCurrentStep:stepLandmarks];
	}

	if([point2Axis isEqualTo:roi])
	{
		point2Axis = nil;
		[stepLandmarks setIsDone:NO];
		[stepByStep setCurrentStep:stepLandmarks];
	}

	if([calibrationMeasurement isEqualTo:roi])
	{
		calibrationMeasurement = nil;
//		[stepMagnificationFactor setIsDone:NO];
//		[stepByStep setCurrentStep:stepMagnificationFactor];
	}	
	
	if(pointerROI)
	{
		if(*pointerROI==roi)
		{
			*pointerROI = nil;
		}
	}
	
	[stepByStep enableSteps];
	[stepByStep showCurrentStep];
}

#pragma mark -
#pragma mark Templates

- (IBAction)showTemplatePanel:(id)sender;
{
	[self showTemplatePanel];
}

- (void)showTemplatePanel;
{
	if(!templateWindowController) 
		templateWindowController = [[XRayTemplateWindowController alloc] initWithWindowNibName:@"TemplatePanel"];
	[templateWindowController showWindow:self];
}

- (void)closeTemplatePanel;
{
	if(templateWindowController)
		[templateWindowController close];
}

#pragma mark -
#pragma mark General Methods

- (IBAction)resetStepByStep:(id)sender;
{
	[self resetStepByStepUpdatingView:YES];
}

- (void)resetStepByStepUpdatingView:(BOOL)updateView;
{	
	if(![stepByStep souldReset]) return;
	if(horizontalAxis)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:horizontalAxis];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:horizontalAxis userInfo:nil];
	}
	horizontalAxis = nil;
	if(femurAxis)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:femurAxis];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurAxis userInfo:nil];
	}
	femurAxis = nil;
	
	if(femurROI)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:femurROI];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurROI userInfo:nil];
	}
	femurROI = nil;
//	if(pointA1)
//	{
//		[[[viewerController roiList] objectAtIndex:0] removeObject:pointA1];
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointA1 userInfo:nil];
//	}
//	if(pointB1)
//	{
//		[[[viewerController roiList] objectAtIndex:0] removeObject:pointB1];
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointB1 userInfo:nil];
//	}
	if(femurLayer)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:femurLayer];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurLayer userInfo:nil];
	}
	femurLayer = nil;
	if(pointA2)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:pointA2];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointA2 userInfo:nil];
//		[pointA2 release];
//		pointA2 = nil;
	}
	pointA2 = nil;
	if(pointB2)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:pointB2];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:pointB2 userInfo:nil];
//		[pointB2 release];
//		pointB2 = nil;
	}
	pointB2 = nil;
	if(cupLayer)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:cupLayer];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:cupLayer userInfo:nil];
//		[cupLayer release];
//		cupLayer = nil;
	}
	cupLayer = nil;
	if(stemLayer)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:stemLayer];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:stemLayer userInfo:nil];
//		[stemLayer release];
//		stemLayer = nil;
	}
	stemLayer = nil;
	if(infoBoxROI)
	{
//		NSLog(@"infoBoxROI");
		[[[viewerController roiList] objectAtIndex:0] removeObject:infoBoxROI];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:infoBoxROI userInfo:nil];
//		[infoBoxROI release];
//		infoBoxROI = nil;
	}
	infoBoxROI = nil;
	
	if(point1)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:point1];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:point1 userInfo:nil];
	}
	point1 = nil;
	if(point1Axis)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:point1Axis];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:point1Axis userInfo:nil];
	}
	point1Axis = nil;
	if(point2)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:point2];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:point2 userInfo:nil];
	}
	if(point2Axis)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:point2Axis];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:point2Axis userInfo:nil];
	}
	point2Axis = nil;
	
	if(calibrationMeasurement)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:calibrationMeasurement];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:calibrationMeasurement userInfo:nil];
	}
	calibrationMeasurement = nil;
	
	if(cupTemplate) {[cupTemplate release]; cupTemplate=nil;}
	if(stemTemplate) {[stemTemplate release]; stemTemplate=nil;}
	if(templateWindowController) [templateWindowController close];
	if(planningDate){[planningDate release]; planningDate=nil;}
	
	[plannerNameTextField setStringValue:@""];
	[chosenSizeTextField setStringValue:@""];
	
	[[NSNotificationCenter defaultCenter] postNotificationName: @"roiRemovedFromArray" object: 0L userInfo: 0L];
	
	//[viewerController roiDeleteAll:self];
	
	if(updateView)
	{
		[stepByStep reset];
		[stepByStep showCurrentStep];
		[[viewerController imageView] display];
	}
}

#pragma mark -
#pragma mark StepByStep Delegate Methods

- (void)willBeginStep:(Step*)step;
{
	
	if(![[stepByStep currentStep] isEqualTo:step]) [stepByStep setCurrentStep:step];

	BOOL changeTool = NO;
	BOOL bringViewerControllerToFront = YES;
	BOOL needsTemplatePanel = NO;
	pointerROI = nil;
	expectedROIType = -1;
	nameROI = nil;
	
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
	else if([step isEqualTo:stepMagnificationFactor])
	{
		[self resetStepByStepUpdatingView:YES];
		[[[viewerController imageView] curDCM] setPixelSpacingX: pixelSpacingX];
		[[[viewerController imageView] curDCM] setPixelSpacingY: pixelSpacingY];

		changeTool = YES;
		if([manualCalibrationButton state]==NSOnState)
			currentTool = tMesure;
		else
			currentTool = userTool;
		expectedROIType = tMesure;
		pointerROI = &calibrationMeasurement;
		nameROI = @"Calibration Measurement";
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
	else if([step isEqualTo:stepLandmarks])
	{
		// the user will have to draw 2 points
		// select the correct tool in OsiriX
		changeTool = YES;
		currentTool = t2DPoint;
		expectedROIType = t2DPoint;
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
	else if([step isEqualTo:stepMagnificationFactor])
	{
		if([standardMagnificationFactorButton state]==NSOnState)
		{
			errorMessage = @"The magnification factor field should not remain empty.";
			error = [[standardMagnificationFactorTextField stringValue] isEqualToString:@""];
			if(!error)
			{
				errorMessage = @"The magnification factor should be a positive value.";
				error = [standardMagnificationFactorTextField floatValue] <= 0.0;
			}
		}
		else if([manualCalibrationButton state]==NSOnState)
		{
			errorMessage = @"The object size field should not remain empty.";
			error = [[manualCalibrationTextField stringValue] isEqualToString:@""];
			if(!error)
			{
				errorMessage = @"The object size should be a positive value.";
				error = [manualCalibrationTextField floatValue] <= 0.0;
				if(!error)
				{
					errorMessage = @"Please draw a line of the size of the calibration object.";
					error = calibrationMeasurement==nil;
				}
			}
		}
	}
	else if([step isEqualTo:stepHorizontalAxis])
	{
		errorMessage = @"Please draw a line parallel to the horizontal axis of the pelvis.";
		error = horizontalAxis==nil;
	}
	else if([step isEqualTo:stepLandmarks])
	{
		errorMessage = @"Please place 2 points.";
		int nbPoint = [[viewerController point2DList] count];
		if(point1 && point2)
			error = NO;
		else
			error = (nbPoint!=2);
	}
	else if([step isEqualTo:stepFemurAxis])
	{
		errorMessage = @"Please draw the axis of the femoral shaft.";
		error = femurAxis==nil;
	}
//	else if([step isEqualTo:stepCalibrationPoints])
//	{
//		errorMessage = @"Please locate one or up to two landmarks on the proximal femur (example tip of the greater trochanter).";
//		int nbPoint = [[viewerController point2DList] count];
//		error = (nbPoint<1) || (nbPoint>2);
//		error &= pointA1==nil;
//	}
	else if([step isEqualTo:stepCutting])
	{
		errorMessage = @"Please encircle the proximal femur, destined to receive the femoral implant. Femoral head and neck should not be included if you plan to remove them.";
		error = (femurROI==nil) && (femurLayer==nil);
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
	else if([step isEqualTo:stepPlacement])
	{
		errorMessage = @"The proximal femur sould not be rotated.";
		error = [self femurRotationAngle] != 0.0;
		if(error)
		{
			NSPoint p1 = [[[femurLayer points] objectAtIndex:0] point];
			NSPoint p2 = [[[femurLayer points] objectAtIndex:2] point];
			NSPoint rotationCenter = NSMakePoint((p1.x+p2.x)*0.5, (p1.y+p2.y)*0.5);
			float angle = [self femurRotationAngle]*(-1.0);
			
			[femurLayer rotate:angle :rotationCenter];
			[stemLayer rotate:angle :rotationCenter];
			//[stepStem setIsDone:NO];
			//[stepByStep setCurrentStep:stepStem];
			[stepByStep showCurrentStep];
		}
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
	else if([step isEqualTo:stepMagnificationFactor])
	{
		[self calibrate];
	}
	else if([step isEqualTo:stepHorizontalAxis])
	{
		[self computeHorizontalAngle];
	}
	else if([step isEqualTo:stepLandmarks])
	{
		// finds the points
		NSArray *points = [viewerController point2DList];
		if(!point1)
		{
			point1 = [points objectAtIndex:0];
			pointA1 = point1;
		}
		if(!point2 && [points count]==2)
			point2 = [points objectAtIndex:1];
			
		[self updatePointsAxis];
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
			femurLayer = [viewerController createLayerROIFromROI:femurROI];
			
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
			
			ROI *pt = [self femurROINearestPoint];
			if(pt==point2)
			{
				ROI *pTemp;
				pTemp = point1;
				point1 = point2;
				point2 = pTemp;
				
				pTemp = point1Axis;
				point1Axis = point2Axis;
				point2Axis = pTemp;
				
				pointA1 = point2;
			}		
			
			// duplicate the points
			pointA2 = [[ROI alloc] initWithType:t2DPoint :[[pt valueForKey:@"pixelSpacingX"] floatValue] :[[pt valueForKey:@"pixelSpacingY"] floatValue] :[[pt valueForKey:@"imageOrigin"] pointValue]];
			[pointA2 setROIRect:[pt rect]];
			[pointA2 setName:[NSString stringWithFormat:@"%@'",[pt name]]]; // same name + prime
			[pointA2 setDisplayTextualData:NO];
			
			[[viewerController imageView] roiSet:pointA2];
			[[[viewerController roiList] objectAtIndex:[[viewerController imageView] curImage]] addObject:pointA2];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:pointA2 userInfo:nil];
			
			// duplicate the axis
//			point3Axis = [[ROI alloc] initWithType:tMesure :[[point1Axis valueForKey:@"pixelSpacingX"] floatValue] :[[point1Axis valueForKey:@"pixelSpacingY"] floatValue] :[[point1Axis valueForKey:@"imageOrigin"] pointValue]];
//			[point3Axis setROIRect:[point1Axis rect]];
//			[point3Axis setName:[NSString stringWithFormat:@"%@'",[point1Axis name]]]; // same name + prime
//			[point3Axis setDisplayTextualData:NO];			
//
//			[[viewerController imageView] roiSet:point3Axis];
//			[[[viewerController roiList] objectAtIndex:[[viewerController imageView] curImage]] addObject:point3Axis];
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:point3Axis userInfo:nil];

//			if(pointB1)
//			{
//				pointB2 = [[ROI alloc] initWithType:t2DPoint :[[pointB1 valueForKey:@"pixelSpacingX"] floatValue] :[[pointB1 valueForKey:@"pixelSpacingY"] floatValue] :[[pointB1 valueForKey:@"imageOrigin"] pointValue]];
//				[pointB2 setROIRect:[pointB1 rect]];
//				[pointB2 setName:[NSString stringWithFormat:@"%@'",[pointB1 name]]]; // same name + prime
//				[pointB2 setDisplayTextualData:NO];
//				
//				[[viewerController imageView] roiSet:pointB2];
//				[[[viewerController roiList] objectAtIndex:[[viewerController imageView] curImage]] addObject:pointB2];
//				[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:pointB2 userInfo:nil];
//			}
			
			// bring the 2 points to front (we don't want them behind the layer)
//			if(pointB1)[viewerController bringToFrontROI:pointB2];
			[viewerController bringToFrontROI:pointA2];
			
			// group the layer and the 2 points
			NSTimeInterval newGroupID = [NSDate timeIntervalSinceReferenceDate];
			[femurLayer setGroupID:newGroupID];
			[pointA2 setGroupID:newGroupID];
//			[point3Axis setGroupID:newGroupID];

		}
		
		if(femurROI)
		{
			[[[viewerController roiList] objectAtIndex:0] removeObject:femurROI];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:femurROI userInfo:nil];
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
		
		NSLog(@"[cupLayer layerReferenceFilePath] : %@", [cupLayer layerReferenceFilePath]);
		
		if(cupTemplate==nil)
			cupTemplate = [templateWindowController templateAtPath:[cupLayer layerReferenceFilePath]];
		[self updateInfoBoxROI];
	}
	else if([step isEqualTo:stepStem])
	{
		[stemLayer setGroupID:[femurLayer groupID]];
		[viewerController bringToFrontROI:stemLayer];
			
		if(stemTemplate==nil)
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
	
	[self updatePointsAxis];
}

#pragma mark -
#pragma mark Steps specific methods

float distanceNSPoint(NSPoint p1, NSPoint p2)
{
	float dx = p1.x - p2.x;
	float dy = p1.y - p2.y;
	return sqrt(dx*dx+dy*dy);
}

- (void)computeOffset;
{
	NSLog(@"computeOffset");
	if(point1==nil || pointA2==nil) return;
	
	NSPoint pA1, pA2;
//	if(pointA1)
//	{
//		pA1 = [[[pointA1 points] objectAtIndex:0] point];
//		pA2 = [[[pointA2 points] objectAtIndex:0] point];
//	}
	if(point1)
	{
		pA1 = [[[point1 points] objectAtIndex:0] point];
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
		
		planningOffset.x *= [[viewerController imageView] pixelSpacingX];
		planningOffset.y *= [[viewerController imageView] pixelSpacingY];
	}
	else if(p2.y == p1.y) // the line p1p2 is horizontal
	{
		planningOffset.x = pA2.y - pA1.y;
		planningOffset.y = pA2.x - pA1.x;
		
		planningOffset.x *= [[viewerController imageView] pixelSpacingX];
		planningOffset.y *= [[viewerController imageView] pixelSpacingY];
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

		pA1.x *= [[viewerController imageView] pixelSpacingX];
		pA1.y *= [[viewerController imageView] pixelSpacingY];

		pA2.x *= [[viewerController imageView] pixelSpacingX];
		pA2.y *= [[viewerController imageView] pixelSpacingY];

		v.x *= [[viewerController imageView] pixelSpacingX];
		v.y *= [[viewerController imageView] pixelSpacingY];
		
		// compute offset
		planningOffset.x = distanceNSPoint(pA2, v);
		planningOffset.y = distanceNSPoint(pA1, v);
	}
	
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

- (float)femurRotationAngle;
{
	if(!femurLayer) return 0.0;
	if([[femurLayer points] count]<=0) return 0.0;
	
	NSPoint p1 = [[[femurLayer points] objectAtIndex:0] point];
	NSPoint p2 = [[[femurLayer points] objectAtIndex:1] point];

	float slope, angle;

	if(p2.y == p1.y)
		angle = 0;
	else if(p2.x == p1.x)
		angle = 90;
	else
	{
		slope = (p2.y-p1.y) / (p2.x-p1.x);
		angle = atan(slope) * 360/(2*pi);
	}
	
	if(p2.x < p1.x)
	{
		if(p2.y > p1.y)
			angle += 180;
		else
			angle -= 180;
	}
	
	return angle;
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

- (void)updatePointsAxis;
{	
	BOOL firstTime, needSetPoints;
	
	NSArray *pts = [horizontalAxis points];
	NSPoint pt0, pt1, ptMiddle, move;
	
	if(point1)
	{
		firstTime = NO;
		
		if(point1Axis==nil)
			firstTime =YES;
			
		if(firstTime)
		{
			point1Axis = [[ROI alloc] initWithType:tMesure :[[horizontalAxis valueForKey:@"pixelSpacingX"] floatValue] :[[horizontalAxis valueForKey:@"pixelSpacingY"] floatValue] :[[horizontalAxis valueForKey:@"imageOrigin"] pointValue]];
		}
		
		//NSArray *pts = [horizontalAxis points];
		pt0 = [[pts objectAtIndex:0] point];
		pt1 = [[pts objectAtIndex:1] point];
		ptMiddle.x = (pt0.x + pt1.x) * 0.5;
		ptMiddle.y = (pt0.y + pt1.y) * 0.5;
		move.x = [[[point1 points] objectAtIndex:0] point].x - ptMiddle.x;
		move.y = [[[point1 points] objectAtIndex:0] point].y - ptMiddle.y;
		pt0.x += move.x;
		pt0.y += move.y;
		pt1.x += move.x;
		pt1.y += move.y;
		
		needSetPoints = NO;
		
		if(!firstTime)
		{
			if([[[point1Axis points] objectAtIndex:0] x] != pt0.x || [[[point1Axis points] objectAtIndex:0] y] != pt0.y || [[[point1Axis points] objectAtIndex:1] x] != pt1.x || [[[point1Axis points] objectAtIndex:1] y] != pt1.y)
			{
				[[point1Axis points] removeAllObjects];
				needSetPoints = YES;
			}
		}
		else
			needSetPoints = YES;

		if(needSetPoints)	
		{
			[point1Axis setPoints:[NSArray arrayWithObjects:[MyPoint point:pt0], [MyPoint point:pt1], nil]];

			if(firstTime)
			{
				[point1Axis setName:[NSString stringWithFormat:@"%@ 1",[horizontalAxis name]]]; // same name + 1
				[point1Axis setDisplayTextualData:NO];
					
				NSTimeInterval newGroupID = [NSDate timeIntervalSinceReferenceDate];
				[point1 setGroupID:newGroupID];
				[point1Axis setGroupID:newGroupID];
			
				[[viewerController imageView] roiSet:point1Axis];
				[[[viewerController roiList] objectAtIndex:[[viewerController imageView] curImage]] addObject:point1Axis];
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:point1Axis userInfo:nil];
		}
	}
	
	// same for 2nd point
	if(point2)
	{
		firstTime = NO;
		if(point2Axis==nil)
			firstTime =YES;
			
		if(firstTime)
		{
			point2Axis = [[ROI alloc] initWithType:tMesure :[[horizontalAxis valueForKey:@"pixelSpacingX"] floatValue] :[[horizontalAxis valueForKey:@"pixelSpacingY"] floatValue] :[[horizontalAxis valueForKey:@"imageOrigin"] pointValue]];
		}
			
		pt0 = [[pts objectAtIndex:0] point];
		pt1 = [[pts objectAtIndex:1] point];
		ptMiddle.x = (pt0.x + pt1.x) * 0.5;
		ptMiddle.y = (pt0.y + pt1.y) * 0.5;
		move.x = [[[point2 points] objectAtIndex:0] point].x - ptMiddle.x;
		move.y = [[[point2 points] objectAtIndex:0] point].y - ptMiddle.y;
		pt0.x += move.x;
		pt0.y += move.y;
		pt1.x += move.x;
		pt1.y += move.y;
		
		needSetPoints = NO;
		
		if(!firstTime)
		{
			if([[[point2Axis points] objectAtIndex:0] x] != pt0.x || [[[point2Axis points] objectAtIndex:0] y] != pt0.y || [[[point2Axis points] objectAtIndex:1] x] != pt1.x || [[[point2Axis points] objectAtIndex:1] y] != pt1.y)
			{
				[[point2Axis points] removeAllObjects];
				needSetPoints = YES;
			}
		}
		else
			needSetPoints = YES;
			
		if(needSetPoints)	
		{
			[point2Axis setPoints:[NSArray arrayWithObjects:[MyPoint point:pt0], [MyPoint point:pt1], nil]];
			
			if(firstTime)
			{
				[point2Axis setName:[NSString stringWithFormat:@"%@ 2",[horizontalAxis name]]]; // same name + 2
				[point2Axis setDisplayTextualData:NO];
			
				NSTimeInterval newGroupID = [NSDate timeIntervalSinceReferenceDate];
				[point2 setGroupID:newGroupID];
				[point2Axis setGroupID:newGroupID];
				
				[[viewerController imageView] roiSet:point2Axis];
				[[[viewerController roiList] objectAtIndex:[[viewerController imageView] curImage]] addObject:point2Axis];
			}
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:point2Axis userInfo:nil];
		}
	}
}

- (void)computeLegInequalityMeasurement;
{
	legInequality = [self computeLegInequalityUsingPoint:point1];
	finalLegInequality = [self computeLegInequalityUsingPoint:pointA2];
}

- (float)computeLegInequalityUsingPoint:(ROI*)pointROI;
{
	if(pointROI==nil || point1==nil || point2==nil) return 0.0;
	
	float inequality = 0.0;
	
//	NSPoint p1;
//	if(pointA2)
//		p1 = [[[pointA2 points] objectAtIndex:0] point];
//	else
//		p1 = [[[point1 points] objectAtIndex:0] point];
	NSPoint p1 = [[[pointROI points] objectAtIndex:0] point];
	NSPoint p2 = [[[point2 points] objectAtIndex:0] point];

	NSPoint pHA1 = [[[horizontalAxis points] objectAtIndex:0] point];
	NSPoint pHA2 = [[[horizontalAxis points] objectAtIndex:1] point];

	if(pHA1.x == pHA2.x) // the horizontalAxis is vertical
	{
		inequality = p2.x - p1.x;
		inequality *= [[viewerController imageView] pixelSpacingX];
	}
	else if(pHA1.y == pHA2.y) // the horizontalAxis is horizontal
	{
		inequality = p2.y - p1.y;
		inequality *= [[viewerController imageView] pixelSpacingY];
	}
	else
	{
		float a, b; // y = a * x + b is the equation of the line going from pHA1 to pHA2
		a = (pHA2.y - pHA1.y) / (pHA2.x - pHA1.x); // division by zero handled previously
		b = p1.y - a * p1.x;

		float b2 = p1.y - a * p1.x; // y2 = parallel going through p1
		float b3 = p2.y + (1.0/a) * p2.x; // y3 = perpendicular going through p2

		// intersection between y2 and y3
		NSPoint v;
		v.x = (b3 - b2) / (a + (1.0/a));
		v.y = a * v.x + b2;

		v.x *= [[viewerController imageView] pixelSpacingX];
		v.y *= [[viewerController imageView] pixelSpacingY];

		p2.x *= [[viewerController imageView] pixelSpacingX];
		p2.y *= [[viewerController imageView] pixelSpacingY];

		// compute the distance
		inequality = distanceNSPoint(p2, v);
	}
	
	inequality = fabs(inequality);
	return inequality;
}

- (ROI*)femurROINearestPoint;
{
	NSArray *femurROIPoints = [femurROI points];
	float point1MeanDistance = 0.0;
	float point2MeanDistance = 0.0;
	
	NSPoint	p1 = [[[point1 points] objectAtIndex:0] point];
	NSPoint p2 = [[[point2 points] objectAtIndex:0] point];

	int i;
	for (i=0; i<[femurROIPoints count]; i++)
	{
		point1MeanDistance += distanceNSPoint(p1, [[femurROIPoints objectAtIndex:i] point]);
		point2MeanDistance += distanceNSPoint(p2, [[femurROIPoints objectAtIndex:i] point]);
	}
	
	if(point1MeanDistance<=point2MeanDistance)
		return point1;
	else
		return point2;
}

- (IBAction)standardMagnificationFactorButtonPressed:(id)sender;
{
	[standardMagnificationFactorButton setState:NSOnState];
	[manualCalibrationButton setState:NSOffState];
	[manualCalibrationButton setNeedsDisplay:YES];
	[standardMagnificationFactorTextField setFloatValue:STANDARD_MAGNIFICATION_FACTOR];
	if(calibrationMeasurement)
	{
		[[[viewerController roiList] objectAtIndex:0] removeObject:calibrationMeasurement];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"removeROI" object:calibrationMeasurement userInfo:nil];
		[calibrationMeasurement release];
		calibrationMeasurement=nil;
		[[viewerController imageView] display];
	}
}

- (IBAction)manualCalibrationButtonPressed:(id)sender;
{
	[manualCalibrationButton setState:NSOnState];
	[standardMagnificationFactorButton setState:NSOffState];
	[standardMagnificationFactorButton setNeedsDisplay:YES];
	[viewerController setROIToolTag:tMesure];
}

- (void)calibrate;
{
	magnificationFactor = 0.0;
	
	if([standardMagnificationFactorButton state]==NSOnState)
	{
		magnificationFactor = [standardMagnificationFactorTextField floatValue];
	}
	else if([manualCalibrationButton state]==NSOnState)
	{
		if(calibrationMeasurement && [manualCalibrationTextField floatValue]!=0.0)
		{
//			[[[viewerController imageView] curDCM] setPixelSpacingX: pixelSpacingX];
//			[[[viewerController imageView] curDCM] setPixelSpacingY: pixelSpacingY];
//			[calibrationMeasurement setOriginAndSpacing:pixelSpacingX :pixelSpacingY :[[viewerController imageView] origin] :NO];
			magnificationFactor = [calibrationMeasurement MesureLength:NULL] / [manualCalibrationTextField floatValue]; // MesureLength is in cm
		}
	}
	NSLog(@"magnificationFactor : %f", magnificationFactor);

	if(magnificationFactor)
	{
		[[[viewerController imageView] curDCM] setPixelSpacingX: pixelSpacingX/magnificationFactor];
		[[[viewerController imageView] curDCM] setPixelSpacingY: pixelSpacingY/magnificationFactor];
	}
}

#pragma mark -
#pragma mark keyDown

- (void)keyDown:(NSEvent *)theEvent
{
	unichar	c = [[theEvent characters] characterAtIndex:0];
	if((c == NSLeftArrowFunctionKey) || (c == NSRightArrowFunctionKey) || (c == NSUpArrowFunctionKey) || (c == NSDownArrowFunctionKey) || c == 13 || c == 3 || c == '	') // Return - Enter - Tab
	{
		NSLog(@"Key down !!!");
	}
	else
	{
		NSLog(@"SUPER Key down !!!");
		[super keyDown:theEvent];
	}

}

- (void)keyDownNotification:(NSNotification*)notification;
{
	unichar	c = [[[notification object] characters] characterAtIndex:0];
	if(c == NSLeftArrowFunctionKey)
		[self rotateLeftCurrentTemplate];
	else if(c == NSRightArrowFunctionKey)
		[self rotateRightCurrentTemplate];
	else if(c == NSUpArrowFunctionKey)
		[self increaseSizeOfCurrentTemplate];
	else if(c == NSDownArrowFunctionKey)
		[self decreaseSizeOfCurrentTemplate];
	else if( c == 13 || c == 3 || c == '	')	// Return - Enter - Tab
	{
		NSLog(@"Return - Enter - Tab");
		if([[viewerController window] isKeyWindow] || [[self window] isKeyWindow] || [[templateWindowController window] isKeyWindow])
			[stepByStep nextStep:self];
	}
}

- (void)replaceLayer:(ROI*)layer usingTemplate:(XRayTemplate*)template;
{
	[layer setLayerReferenceFilePath:[template referenceFilePath]];
	
	float pixelSpacing;
	NSImage *im = [templateWindowController imageForTemplate:template pixelSpacing:&pixelSpacing];
	[im retain];
	
	NSArray *points = [NSArray arrayWithArray:[layer points]];
	NSPoint center;
	center.x = [[points objectAtIndex:0] x] + [[points objectAtIndex:1] x] + [[points objectAtIndex:2] x] + [[points objectAtIndex:3] x];
	center.x /= 4.0;
	center.y = [[points objectAtIndex:0] y] + [[points objectAtIndex:1] y] + [[points objectAtIndex:2] y] + [[points objectAtIndex:3] y];
	center.y /= 4.0;

	NSPoint p1 = [[points objectAtIndex:0] point];
	NSPoint p2 = [[points objectAtIndex:1] point];

	float slope, angle;

	if(p2.y == p1.y)
		angle = 0;
	else if(p2.x == p1.x)
		angle = 90;
	else
	{
		slope = (p2.y-p1.y) / (p2.x-p1.x);
		angle = atan(slope) * 360/(2*pi);
	}
	
	if(p2.x < p1.x)
	{
		if(p2.y > p1.y)
			angle += 180;
		else
			angle -= 180;
	}

	[layer setLayerPixelSpacingX:pixelSpacing];
	[layer setLayerPixelSpacingY:pixelSpacing];
	[layer setLayerImage:im];
	
	[self rotateLayerROI:layer withAngle:angle];
	
	NSPoint newCenter;
	newCenter.x = [[[layer points] objectAtIndex:0] x] + [[[layer points] objectAtIndex:1] x] + [[[layer points] objectAtIndex:2] x] + [[[layer points] objectAtIndex:3] x];
	newCenter.x /= 4.0;
	newCenter.y = [[[layer points] objectAtIndex:0] y] + [[[layer points] objectAtIndex:1] y] + [[[layer points] objectAtIndex:2] y] + [[[layer points] objectAtIndex:3] y];
	newCenter.y /= 4.0;

	NSPoint offset;
	offset.x = center.x - newCenter.x;
	offset.y = center.y - newCenter.y;
			
	[layer roiMove:offset];
				
	[im release];
			
//	[layer generateEncodedLayerImage];
}

- (void)increaseSizeOfCurrentTemplate;
{
	ROI *layer;
	XRayTemplate *curTemplate;
		
	if([[stepByStep currentStep] isEqualTo:stepCup])
	{
		//NSLog(@"CUP SIZE + 1");
		layer = cupLayer;
		curTemplate = cupTemplate;
	}
	else if([[stepByStep currentStep] isEqualTo:stepStem])
	{
		//NSLog(@"STEM SIZE + 1");
		layer = stemLayer;
		curTemplate = stemTemplate;
	}
	
	XRayTemplate *nextTemplate = [templateWindowController nextSizeForTemplate:curTemplate];
	
	if([nextTemplate sizeValue] > [curTemplate sizeValue])
	{
		NSLog(@"Template SIZE : %@ -> %@", [curTemplate size], [nextTemplate size]);
		[self replaceLayer:layer usingTemplate:nextTemplate];
		NSArray *lines;
		if([[stepByStep currentStep] isEqualTo:stepCup])
		{
			[cupTemplate release];
			cupTemplate = nextTemplate;
			[cupTemplate retain];
			lines = [cupTemplate textualData];
		}
		else if([[stepByStep currentStep] isEqualTo:stepStem])
		{
			[stemTemplate release];
			stemTemplate = nextTemplate;
			[stemTemplate retain];
			lines = [stemTemplate textualData];
		}
		if([lines objectAtIndex:0]) [layer setTextualBoxLine1:[lines objectAtIndex:0]];
		if([lines objectAtIndex:1]) [layer setTextualBoxLine2:[lines objectAtIndex:1]];
		if([lines objectAtIndex:2]) [layer setTextualBoxLine3:[lines objectAtIndex:2]];
		if([lines objectAtIndex:3]) [layer setTextualBoxLine4:[lines objectAtIndex:3]];
		if([lines objectAtIndex:4]) [layer setTextualBoxLine5:[lines objectAtIndex:4]];
	}
	[self updateInfoBoxROI];
}

- (void)decreaseSizeOfCurrentTemplate;
{
	ROI *layer;
	XRayTemplate *curTemplate;
	
	if([[stepByStep currentStep] isEqualTo:stepCup])
	{
		//NSLog(@"CUP SIZE - 1");
		layer = cupLayer;
		curTemplate = cupTemplate;
	}
	else if([[stepByStep currentStep] isEqualTo:stepStem])
	{
		//NSLog(@"STEM SIZE - 1");
		layer = stemLayer;
		curTemplate = stemTemplate;
	}
	
	XRayTemplate *nextTemplate = [templateWindowController previousSizeForTemplate:curTemplate];

	if([nextTemplate sizeValue] < [curTemplate sizeValue])
	{
		//NSLog(@"Template SIZE : %@ -> %@", [curTemplate size], [nextTemplate size]);
		[self replaceLayer:layer usingTemplate:nextTemplate];
		NSArray *lines;
		if([[stepByStep currentStep] isEqualTo:stepCup])
		{
			[cupTemplate release];
			cupTemplate = nextTemplate;
			[cupTemplate retain];
			lines = [cupTemplate textualData];
		}
		else if([[stepByStep currentStep] isEqualTo:stepStem])
		{
			[stemTemplate release];
			stemTemplate = nextTemplate;
			[stemTemplate retain];
			lines = [stemTemplate textualData];
		}		
		if([lines objectAtIndex:0]) [layer setTextualBoxLine1:[lines objectAtIndex:0]];
		if([lines objectAtIndex:1]) [layer setTextualBoxLine2:[lines objectAtIndex:1]];
		if([lines objectAtIndex:2]) [layer setTextualBoxLine3:[lines objectAtIndex:2]];
		if([lines objectAtIndex:3]) [layer setTextualBoxLine4:[lines objectAtIndex:3]];
		if([lines objectAtIndex:4]) [layer setTextualBoxLine5:[lines objectAtIndex:4]];
	}
	[self updateInfoBoxROI];
}

- (void)rotateLeftCurrentTemplate;
{
	ROI *roi;
	if([[stepByStep currentStep] isEqualTo:stepCup])
		roi = cupLayer;
	else if([[stepByStep currentStep] isEqualTo:stepStem])
		roi = stemLayer;
	else
		return;
	[self rotateLayerROI:roi withAngle:-1.0];
}

- (void)rotateRightCurrentTemplate;
{
	ROI *roi;
	if([[stepByStep currentStep] isEqualTo:stepCup])
		roi = cupLayer;
	else if([[stepByStep currentStep] isEqualTo:stepStem])
		roi = stemLayer;
	else
		return;
	[self rotateLayerROI:roi withAngle:1.0];
}

- (void)rotateLayerROI:(ROI*)roi withAngle:(float)angle;
{		
	[roi rotate:angle :[roi clickPoint]];
}

#pragma mark -
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
	
	NSString *title, *name, *size, *manufacturer, *vOffset, *hOffset, *chosenSize, *angle, *degreeSign, *reference;
	
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
		
		reference = [NSString stringWithFormat:@"\nReference: %@", [cupTemplate reference]];
		
		[cupInfo appendString:title];
		[cupInfo appendString:name];
		[cupInfo appendString:size];
		[cupInfo appendString:manufacturer];
		[cupInfo appendString:reference];
		[cupInfo appendString:angle];
		
		if([title length]>maxLength) maxLength = [title length];
		if([name length]>maxLength) maxLength = [name length];
		if([size length]>maxLength) maxLength = [size length];
		if([manufacturer length]>maxLength) maxLength = [manufacturer length];
		if([angle length]>maxLength) maxLength = [angle length];
		if([reference length]>maxLength) maxLength = [reference length];
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
		
		reference = [NSString stringWithFormat:@"\nReference: %@", [stemTemplate reference]];
		
		[stemInfo appendString:title];
		[stemInfo appendString:name];
		[stemInfo appendString:size];
		[stemInfo appendString:manufacturer];
		[stemInfo appendString:reference];
		[stemInfo appendString:vOffset];
		[stemInfo appendString:hOffset];
		[stemInfo appendFormat:@"\nRotation: %.1f", [self femurRotationAngle]]; // remove this line !!!!
		
		if([[chosenSizeTextField stringValue] length]>0)[stemInfo appendString:chosenSize];

		if([title length]>maxLength) maxLength = [title length];
		if([name length]>maxLength) maxLength = [name length];
		if([size length]>maxLength) maxLength = [size length];
		if([manufacturer length]>maxLength) maxLength = [manufacturer length];		
		if([vOffset length]>maxLength) maxLength = [vOffset length];		
		if([hOffset length]>maxLength) maxLength = [hOffset length];
		if([reference length]>maxLength) maxLength = [reference length];
	}
	
	if(maxLength<30) maxLength = 30;
	
	NSString *separator = [@"_" stringByPaddingToLength:maxLength withString: @"_" startingAtIndex:0];

#ifdef BETAVERSION
	[text appendString:@"BETA VERSION - DON'T USE FOR CLINICAL DECISIONS"];
	[text appendString:@"\n"];
	[text appendString:separator];
	[text appendString:@"\n"];
#endif

	[text appendString:@"Infos"];
	[text appendString:@"\n"];
	[text appendString:separator];
	[text appendString:@"\n"];
	
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
		[text appendString:@"\n"];
	}
	
//	[text appendString:separator];
//	[text appendString:@"\n"];
	[text appendFormat:@"Leg inequality measurement (initial): %.2f mm", legInequality];
	if(pointA2)
	{
		[text appendString:@"\n"];
		[text appendFormat:@"Leg inequality measurement (final): %.2f mm", finalLegInequality];
	}
		
	if(cupInfo)
	{
		[text appendString:@"\n"];
		[text appendString:separator];

		[text appendString:cupInfo];
	}
	if(stemInfo)
	{
		[text appendString:@"\n"];
		[text appendString:separator];
		[text appendString:stemInfo];
	}
		
	[infoBoxROI setName:text];
//	[infoBoxROI setComments:text];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"roiChange" object:infoBoxROI userInfo:nil];
}

@end
