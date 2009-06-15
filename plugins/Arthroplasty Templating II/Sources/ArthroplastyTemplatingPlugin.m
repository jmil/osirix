//
//  ArthroplastyTemplatingPlugin.m
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "ArthroplastyTemplatingPlugin.h"
#import "ArthroplastyTemplatingStepByStepController.h"
#import "BrowserController.h"


@implementation ArthroplastyTemplatingPlugin

- (void)initPlugin {
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:@"CloseViewerNotification" object:viewerController];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:@"NSWindowWillCloseNotification" object:nil];
}

- (long)filterImage:(NSString*) menuName {
	int returnValue = NSOKButton;
	if ([[[viewerController roiList:0] objectAtIndex:0] count])
		returnValue = NSRunAlertPanel(@"Arthroplasty Templating Plugin", @"All the ROIs on this image will be removed.", @"OK", @"Cancel", nil);
	if (!returnValue)
		return 0;
	
	NSArray *winList = [NSApp windows];
	long i;
	for(i = 0; i < [winList count]; i++)
		if ([[[[winList objectAtIndex:i] windowController] className] isEqualToString:@"ArthroplastyTemplatingStepByStepController"]) {
			stepByStepController = [[winList objectAtIndex:i] windowController];
			break;
		}
	
	if(!stepByStepController) {
		stepByStepController = [[ArthroplastyTemplatingStepByStepController alloc] initWithWindowNibName:@"StepByStepPanel"];
		[stepByStepController setViewerController:viewerController];
	}
	
	[viewerController roiDeleteAll:self];
	[stepByStepController resetStepByStepUpdatingView:YES];
	[stepByStepController showWindow:self];
	

	return 0;
}

//- (void)viewerWillClose:(NSNotification*)notification;
//{
//	if(stepByStepController) [stepByStepController close];
//}

//- (void)windowWillClose:(NSNotification *)aNotification
//{
//	NSLog(@"windowWillClose ArthroplastyTemplatingsPluginFilter");
//	if(stepByStepController)
//	{
//		if([[aNotification object] isEqualTo:[stepByStepController window]])
//		{
//			[stepByStepController release];
//			stepByStepController = nil;
//		}
//	}
//}

@end
