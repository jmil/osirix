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
- (IBAction)choose: (id) sender;
- (void)save;
- (NSString *)caseName;
- (void)setCaseName:(NSString *)caseName;
- (NSString *)replaceFolderName:(NSString *)caseString withName:(NSString *)newName;
- (void)addFolder:(NSString *)folderName;
- (void)removeFolder:(NSString *)folderName;

@end
