//
//  EjectionFractionStepsController.mm
//  Ejection Fraction II
//
//  Created by Alessandro Volz on 7/20/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "EjectionFractionStepsController.h"

@implementation EjectionFractionStepsController

-(id)initWithPlugin:(EjectionFractionPlugin*)plugin {
	self = [self initWithWindowNibName:@"EjectionFractionSteps"];
	_plugin = plugin;
	_activeSteps = [NSMutableArray arrayWithCapacity:8];
	
	[self window];
	
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
	[_activeSteps release];
	[super dealloc];
}

-(void)setAlgorithmImage:(NSImage*)image {
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
				[self setAlgorithmImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"PreviewMonoplane" ofType:@"png"]]];
				//[self showSteps:[NSArray arrayWithObjects: _stepAlgorithm, , NULL]];
				break;
			case 1: // Biplane
				[self setAlgorithmImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"PreviewBiplane" ofType:@"png"]]];
				break;
			case 2: // Hemi-ellipse
				[self setAlgorithmImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"PreviewHemi-ellipse" ofType:@"png"]]];
				break;
			case 3: // Simpson
				[self setAlgorithmImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"PreviewSimpson" ofType:@"png"]]];
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
