//
//  ResultsController.h
//  ResultsController
//
//  Created by rossetantoine on Tue Jun 15 2004.
//  Copyright (c) 2004 Antoine Rosset. All rights reserved.
//

#import <AppKit/AppKit.h>

#import <WebKit/WebView.h>
#import "ROI.h"
#import "ResultsView.h"
#import "ViewerController.h"
#import "DCMView.h"

@interface ResultsController : NSWindowController
{
	IBOutlet	ResultsView		*view;
	IBOutlet	NSTextField		*roiName;
	
	ROI* curROI;
	float *rmean, *rmin, *rmax;
	int num;
	ViewerController *viewerController;
}

- (id) initWithROI:(ROI*) roi viewer:(ViewerController*) v;

@end
