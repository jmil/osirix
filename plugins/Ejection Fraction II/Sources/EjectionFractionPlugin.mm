//
//  EjectionFraction.mm
//  Ejection Fraction II
//
//  Created by Alessandro Volz on 7/20/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "EjectionFractionPlugin.h"
#import "EjectionFractionWorkflow.h"
#import "EjectionFractionStepsController.h"
#import <OsiriX Headers/Notifications.h>

@implementation EjectionFractionPlugin

/*-(void)n2test {
	NSLog(@"n2test n2test n2test n2test n2test n2test n2test n2test n2test n2test n2test");
	N2Window* window = [[N2Window alloc] initWithContentRect:NSMakeRect(0, 0, 400, 300) styleMask:NSTitledWindowMask|NSClosableWindowMask|NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
	N2LayoutManager* layout = [[[N2LayoutManager alloc] initWithControlSize:NSRegularControlSize] autorelease];
//	[layout setForcesSuperviewSize:YES];
//	[layout setStretchesToFill:YES];
//	[layout setOccupiesEntireSuperview:YES];
	[[window contentView] setLayout:layout];
	
	NSTextView* temp;
	temp = [[NSTextView alloc] init];
	[temp setString:@"Random text content."];
	[temp setEditable:NO];
	[[window contentView] addSubview:[temp autorelease]];
	[temp adaptToContent];
	[[window contentView] addDescriptor:[N2LayoutDescriptor createWithAlignment:N2AlignmentRight]];
	temp = [[NSTextView alloc] init];
	[temp setString:@"Random text content."];
	[temp setEditable:NO];
	[[window contentView] addSubview:[temp autorelease]];
	[temp adaptToContent];
 
	
	[layout recalculate:[window contentView]];
	[window makeKeyAndOrderFront:self];
	NSLog(@"Ok");
}*/

-(void)initPlugin {
	_wfs = [[NSMutableArray alloc] initWithCapacity:1];
	
	//[self n2test];
	EjectionFractionStepsController* controller = [[EjectionFractionStepsController alloc] initWithWorkflow:NULL];
	[controller showWindow:NULL];
//	NSLog(@"controller window [%f, %f, %f, %f]", [[controller window] frame].origin.x, [[controller window] frame].origin.y, [[controller window] frame].size.width, [[controller window] frame].size.height);
}

-(void)dealloc {
	[_wfs release]; _wfs = NULL;
	[super dealloc];
}

-(void)addWorkflow:(EjectionFractionWorkflow*)workflow {
	[_wfs addObject:workflow];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepsWindowWillClose:) name:NSWindowWillCloseNotification object:[[workflow steps] window]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name:OsirixCloseViewerNotification object:[workflow viewer]];
}

-(void)removeWorkflow:(EjectionFractionWorkflow*)workflow {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:[[workflow steps] window]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OsirixCloseViewerNotification object:[workflow viewer]];
	[_wfs removeObject:workflow];
}

-(void)stepsWindowWillClose:(NSNotification*)notification {
	NSWindow* win = [notification object];
	
	EjectionFractionWorkflow* workflow = NULL;
	for (EjectionFractionWorkflow* wf in _wfs)
		if ([[wf steps] window] == win)
			workflow = wf;
	
	[workflow setSteps:NULL];
	[self removeWorkflow:workflow];
}

-(void)viewerWillClose:(NSNotification*)notification {
	ViewerController* viewer = [notification object];
	
	EjectionFractionWorkflow* workflow = NULL;
	for (EjectionFractionWorkflow* wf in _wfs)
		if ([wf viewer] == viewer)
			workflow = wf;
	
	[workflow setViewer:NULL];
	[self removeWorkflow:workflow];
}

-(long)filterImage:(NSString*)menuName {
	EjectionFractionWorkflow* workflow = NULL;
	for (EjectionFractionWorkflow* wf in _wfs)
		if ([wf viewer] == viewerController)
			workflow = wf;
	
	if (!workflow) [self addWorkflow: workflow = [[[EjectionFractionWorkflow alloc] initWithViewer:viewerController] autorelease]];
	[[[workflow steps] window] makeKeyAndOrderFront:self];

	return 0;
}

@end
