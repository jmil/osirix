//
//  MIRCCaseController.h
//  TeachingFile
//
//  Created by Lance Pysher on 8/8/05.
//  Copyright 2005 Macrad, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class MIRCController;

@interface MIRCCaseController : NSArrayController {
	IBOutlet NSTableView *tableView;
	IBOutlet MIRCController *mircController;
	NSString *_caseName;
}

- (IBAction)controlAction: (id) sender;


@end
