//
//  BullsEyeController.h
//  BullsEye
//
//  Created by Antoine Rosset on 18.11.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BullsEyeController : NSWindowController
{
	IBOutlet NSTableView *presetsTable;
	IBOutlet NSArrayController *presetBullsEye, *presetsList;
}

- (NSArray*) presetBullsEyeArray;
- (IBAction) refresh: (id) sender;

@end
