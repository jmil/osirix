//
//  XRayTemplatesPluginFilter.m
//  XRayTemplatesPlugin
//
//  Copyright (c) 2007 Joris. All rights reserved.
//

#import "XRayTemplatesPluginFilter.h"
#import "BrowserController.h"

//#define BETAVERSION

@implementation XRayTemplatesPluginFilter

//- (void)initPlugin;
//{
//	//NSLog(@"initPlugin XRayTemplatesPluginFilter");
////	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:@"CloseViewerNotification" object:nil];
////	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:@"NSWindowWillCloseNotification" object:nil];
//}

//- (void)dealloc;
//{
//	//NSLog(@"dealloc XRayTemplatesPluginFilter");
//	//[windowController release];
//	//[stepByStepController release];
//	[super dealloc];
//}


- (long)filterImage:(NSString*) menuName;
{
	//NSLog(@"XRayTemplatesPluginFilter : filterImage");

#ifdef BETAVERSION
	NSDate *today = [NSDate date];
	NSDate *endDate = [NSDate dateWithNaturalLanguageString:@"9/1/2007"];
	
	if([today compare:endDate]==NSOrderedDescending)
	{
		NSRunCriticalAlertPanel(@"Arthroplasty Templating Plugin", @"This plugin is out dated and should not be used. Please visit OsiriX web site for a newer version.", @"OK", nil, nil);
		return 0;
	}
	else
	{
		NSRunAlertPanel(@"Arthroplasty Templating Plugin", @"This is a beta version of a plugin being developped by Joris Heuberger for the University Hospital of Geneva.\n\nIt should never be used for clinical practice.\n\nThis plugin will expire on September 1, 2007.", @"OK", nil, nil);
	}
	
#endif

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
