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
#import "ViewerController.h"
#import "DCMView.h"
#import "GraphX/CTScatterPlotView.h"
//#import "PlotData.h"

@interface ResultsController : NSWindowController
{
	IBOutlet CTScatterPlotView *plotMean, *plotMin, *plotMax;
//	IBOutlet PlotData *plotMeanData, *plotMinData, *plotMaxData;
	IBOutlet NSTextField *roiName;
	
	ROI* curROI;
	float *rmean, *rmin, *rmax;
	int num;
	ViewerController *viewerController;
}

- (id) initWithROI:(ROI*) roi viewer:(ViewerController*) v;
- (void) updateData;

@end
