//
//  CaseImageArrayController.h
//  TeachingFile
//
//  Created by Lance Pysher on 2/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DCMView;
@interface CaseImageArrayController : NSArrayController {
	IBOutlet NSTableView *tableView;
}

- (void)insertImageAtRow:(int)row FromViewer:(DCMView *)vi;
- (IBAction)selectCurrentImage:(id)sender;
- (IBAction)addOrDelete:(id)sender;


@end
