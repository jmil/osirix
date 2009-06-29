//
//  ArthroplastyTemplatingPlugin.m
//  Arthroplasty Templating II
//  Created by Joris Heuberger on 04/04/07.
//  Copyright (c) 2007-2009 OsiriX Foundation. All rights reserved.
//

#import "ArthroplastyTemplatingPlugin.h"
#import "ArthroplastyTemplatingStepByStepController.h"
#import "ArthroplastyTemplatingWindowController.h"
#import "BrowserController.h"


@implementation ArthroplastyTemplatingPlugin
@synthesize templatesWindowController = _templatesWindowController;

-(void)initialize {
	if (_initialized) return;
	_initialized = YES;
	
	_templatesWindowController = [[ArthroplastyTemplatingWindowController alloc] init];
	[_templatesWindowController window]; // force nib loading
}

- (void)initPlugin {
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:@"CloseViewerNotification" object:viewerController];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:@"NSWindowWillCloseNotification" object:nil];
}

- (long)filterImage:(NSString*) menuName {
	[self initialize];

	if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] intValue] < 5607) {
		NSAlert* alert = [NSAlert alertWithMessageText:@"The OsiriX application you are running is out of date." defaultButton:@"Close" alternateButton:NULL otherButton:NULL informativeTextWithFormat:@"OsiriX 3.6 is necessary for this plugin to execute."];
		[alert beginSheetModalForWindow:[viewerController window] modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
		return 0;
	}
	
	[self initialize];
	
	if ([[[viewerController roiList:0] objectAtIndex:0] count])
		if (!NSRunAlertPanel(@"Arthroplasty Templating II", @"All the ROIs on this image will be removed.", @"OK", @"Cancel", NULL))
			return 0;
	
	[[[ArthroplastyTemplatingStepByStepController alloc] initWithPlugin:self viewerController:viewerController] showWindow:self];
	
	return 0;
}

-(BOOL)handleEvent:(NSEvent*)event forViewer:(ViewerController*)controller {
	NSLog(@"handleEvent %@", event);
	return NO;
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
