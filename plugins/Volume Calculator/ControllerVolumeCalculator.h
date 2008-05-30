//
//  Controller.h
//  Mapping
//
//  Created by Antoine Rosset on Mon Aug 02 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "Graph.h"

@interface ControllerVolumeCalculator : NSWindowController
{
	IBOutlet		NSTextField			*diameter1, *diameter2;
	IBOutlet		NSTextField			*volume1, *volume2;
	IBOutlet		NSTextField			*change;
}

- (id) init: (VolumeCalculator*) f ;
- (IBAction) compute:(id) sender;
@end
