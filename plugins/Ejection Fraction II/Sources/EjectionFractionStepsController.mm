//
//  EjectionFractionStepsController.mm
//  Ejection Fraction II
//
//  Created by Alessandro Volz on 7/20/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "EjectionFractionStepsController.h"
#import "EjectionFractionWorkflow.h"

@implementation EjectionFractionStepsController

-(id)initWithWorkflow:(EjectionFractionWorkflow*)workflow {
	self = [self initWithWindowNibName:@"EjectionFractionSteps"];
	_workflow = workflow;
	_activeSteps = [NSMutableArray arrayWithCapacity:8];
	
	[[self window] setDelegate:self];
	
	return self;
}

-(void)awakeFromNib {
	_viewAlgorithmOriginalFrameHeight = [_viewAlgorithm frame].size.height;
	
	[[_stepsView layout] setForeColor:[NSColor whiteColor]];
	[_stepsView setForeColor:[NSColor whiteColor]];
	[_stepsView setControlSize:NSSmallControlSize];
	
	[_steps addObject: _stepAlgorithm = [[N2Step alloc] initWithTitle:@"Algorithm" enclosedView:_viewAlgorithm]];
	//_stepDiasLong
	
	
	[self steps:_steps valueChanged:_viewAlgorithmChoice];
}

-(void)dealloc {
	NSLog(@"%X [EjectionFractionStepsController dealloc]", self);
	[_activeSteps release];
	[super dealloc];
}

-(void)windowWillClose:(NSNotification*)notification {
	//[self autorelease];
}

-(void)setAlgorithmImage:(NSString*)name {
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
}

-(void)steps:(N2Steps*)steps willBeginStep:(N2Step*)step {
	
}

-(void)steps:(N2Steps*)steps valueChanged:(id)sender {
	if (sender == _viewAlgorithmChoice) { // changed algorithm choice
		switch ([_viewAlgorithmChoice indexOfSelectedItem]) {
			case 0: // Monoplane
				[self setAlgorithmImage:@"PreviewMonoplane"];
				//[self showSteps:[NSArray arrayWithObjects: _stepAlgorithm, , NULL]];
				break;
			case 1: // Biplane
				[self setAlgorithmImage:@"PreviewBiplane"];
				break;
			case 2: // Hemi-ellipse
				[self setAlgorithmImage:@"PreviewHemi-ellipse"];
				break;
			case 3: // Simpson
				[self setAlgorithmImage:@"PreviewSimpson"];
				break;
			case 4: // Teichholz
				[self setAlgorithmImage:NULL];
				break;
		}
	}
}

-(BOOL)steps:(N2Steps*)steps shouldValidateStep:(N2Step*)step {
	return NO;
}

-(void)steps:(N2Steps*)steps validateStep:(N2Step*)step {
	
}

@end
