//
//  XRayTemplatesPluginFilter.m
//  XRayTemplatesPlugin
//
//  Copyright (c) 2007 Joris Heuberger. All rights reserved.
//

#import "XRayTemplatesPluginFilter.h"
#import "BrowserController.h"

@implementation XRayTemplatesPluginFilter

- (long)filterImage:(NSString*) menuName;
{
	BOOL templatePanelFound = [self findTemplatePanel];
	BOOL stepByStepPanelFound = [self findStepByStepPanel];
	
	if([menuName isEqualToString:@"Template Panel"])
	{
		if(stepByStepPanelFound)
			[stepByStepController close];

		if(!templatePanelFound)
			windowController = [[XRayTemplateWindowController alloc] initWithWindowNibName:@"TemplatePanel"];
		
		[windowController showWindow:self];
	}
	else if([menuName isEqualToString:@"Arthroplasty Templating"])
	{
		// close any template panel found
		if(templatePanelFound)
			[windowController close];
		
		// create or show the step by step panel
		int returnValue = 1;

		if([[[viewerController roiList:0] objectAtIndex:0] count]>0)
		{
			returnValue = NSRunAlertPanel(@"Arthroplasty Templating Plugin", @"All the ROIs on this image will be removed.", @"OK", @"Cancel", nil);
		}
		
		if(returnValue==1)
		{	
			if(!stepByStepPanelFound)
			{
				stepByStepController = [[XRayTemplateStepByStepController alloc] initWithWindowNibName:@"StepByStepPanel"];
				[stepByStepController setViewerController:viewerController];
			}
			
			[viewerController roiDeleteAll:self];
			[stepByStepController resetStepByStepUpdatingView:YES];
			[stepByStepController showWindow:self];
		}
	}
	return 0;
}

- (BOOL)findTemplatePanel;
{
	long i;
	BOOL found = NO;
	NSArray *winList = [NSApp windows];
	for( i = 0; i < [winList count] && !found; i++)
	{
		if( [[[[winList objectAtIndex:i] windowController] className] isEqualToString:@"XRayTemplateWindowController"])
		{
			windowController = [[winList objectAtIndex:i] windowController];
			found = YES;
		}
	}
	return found;
}

- (BOOL)findStepByStepPanel;
{
	long i;
	BOOL found = NO;
	NSArray *winList = [NSApp windows];
	for( i = 0; i < [winList count] && !found; i++)
	{
		if( [[[[winList objectAtIndex:i] windowController] className] isEqualToString:@"XRayTemplateStepByStepController"])
		{
			stepByStepController = [[winList objectAtIndex:i] windowController];
			found = YES;
		}
	}
	return found;
}

@end
