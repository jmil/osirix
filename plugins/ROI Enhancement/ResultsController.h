//
//  ResultsController.h
//  ResultsController
//
//  Created by rossetantoine on Tue Jun 15 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

#import <WebKit/WebView.h>

#import "ResultsView.h"

@interface ResultsController : NSWindowController {

	IBOutlet	ResultsView		*view;
	IBOutlet	NSTextField		*roiName;
}

- (ResultsView*) resultsView;
- (id) initWithName:(NSString*) name;

@end
