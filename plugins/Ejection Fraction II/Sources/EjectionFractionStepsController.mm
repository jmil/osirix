//
//  EjectionFractionStepsController.mm
//  Ejection Fraction II
//
//  Created by Alessandro Volz on 7/20/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "EjectionFractionPlugin.h"
#import "EjectionFractionStepsController.h"
#import "EjectionFractionWorkflow.h"

@interface EjectionFractionStepsController (Private)
-(void)algorithmSelected:(NSMenuItem*)selection;
@end

@implementation EjectionFractionStepsController
@synthesize stepsView = _stepsView, stepROIs = _stepROIs;

-(id)initWithWorkflow:(EjectionFractionWorkflow*)workflow {
	self = [self initWithWindowNibName:@"EjectionFractionSteps"];
	_workflow = workflow;
//	_activeSteps = [NSMutableArray arrayWithCapacity:8];
	
	[[self window] setDelegate:self];
	
	return self;
}

-(void)addAlgorithm:(EjectionFractionAlgorithm*)algorithm {
	NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:[algorithm description] action:@selector(algorithmSelected:) keyEquivalent:@""] autorelease];
	[item setRepresentedObject:algorithm];
	[[_viewAlgorithmChoice menu] addItem:item];
	if ([_viewAlgorithmChoice numberOfItems] == 1)
		[self algorithmSelected:item];
}

-(void)awakeFromNib {
	_viewAlgorithmOriginalFrameHeight = [_viewAlgorithm frame].size.height;
	
	[[_stepsView layout] setForeColor:[NSColor whiteColor]];
	[_stepsView setForeColor:[NSColor whiteColor]];
	[_stepsView setControlSize:NSSmallControlSize];
	
	[_steps addObject: _stepAlgorithm = [[N2Step alloc] initWithTitle:@"Algorithm" enclosedView:_viewAlgorithm]];
	for (EjectionFractionAlgorithm* algorithm in [[_workflow plugin] algorithms]) [self addAlgorithm:algorithm];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(algorithmAddedNotification:) name:EjectionFractionAlgorithmAddedNotification object:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(algorithmRemovedNotification:) name:EjectionFractionAlgorithmRemovedNotification object:NULL];
	[_steps addObject: _stepROIs = [[N2Step alloc] initWithTitle:@"ROIs" enclosedView:_viewROIs]];
	[_stepROIs setActive:YES];
	
	//_stepDiasLong
	
	
	[self steps:_steps valueChanged:_viewAlgorithmChoice];
}

-(void)dealloc {
	NSLog(@"%X [EjectionFractionStepsController dealloc]", self);
//	[_activeSteps release];
	[super dealloc];
}

-(void)windowWillClose:(NSNotification*)notification {
	//[self autorelease];
}

-(void)algorithmAddedNotification:(NSNotification*)notification {
	EjectionFractionAlgorithm* algorithm = [notification object];
	[self addAlgorithm:algorithm];
}

-(void)algorithmRemovedNotification:(NSNotification*)notification {
	EjectionFractionAlgorithm* algorithm = [notification object];
	[_viewAlgorithmChoice removeItemWithTitle:[algorithm description]];
}

-(void)algorithmSelected:(NSMenuItem*)selection {
	[_workflow setAlgorithm:[selection representedObject]];
}

-(void)setSelectedAlgorithm:(EjectionFractionAlgorithm*)algorithm {
	for (NSMenuItem* item in [[_viewAlgorithmChoice menu] itemArray])
		if ([item representedObject] == algorithm) {
			[_viewAlgorithmChoice selectItem:item];
			break;
		}
	
	[_stepROIs setTitle:[NSString stringWithFormat:@"[%@] ROIs", [algorithm description]]];
	
	//[_steps setNeededROIs:[_algorithm neededROIs]];
	
	[_stepAlgorithm setDone:YES];
	[_steps setCurrentStep:_stepROIs];
}


-(void)steps:(N2Steps*)steps willBeginStep:(N2Step*)step {
	
}

-(void)steps:(N2Steps*)steps valueChanged:(id)sender {
}

-(BOOL)steps:(N2Steps*)steps shouldValidateStep:(N2Step*)step {
	return NO;
}

-(void)steps:(N2Steps*)steps validateStep:(N2Step*)step {
	
}

/*
 
 NSImage* image = name? [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"png"]] autorelease] : NULL;
 
 NSSize size = NSMakeSize([_viewAlgorithmPreview frame].size.width, 0);
 if (image) {
 NSSize imageSize = [image size];
 size.height = ceilf(imageSize.height/imageSize.width*size.width);
 }
 
 [_viewAlgorithmPreview setFrameSize:size];
 [_viewAlgorithmPreview setImage:image];
 
 if (image)
 size.height += 10;
 
 [_viewAlgorithm setFrameSize:NSMakeSize([_viewAlgorithm frame].size.width, _viewAlgorithmOriginalFrameHeight+size.height)];
 
 */

@end
