//
//  MIRCCaseController.m
//  TeachingFile
//
//  Created by Lance Pysher on 8/8/05.
//  Copyright 2005 Macrad, LLC. All rights reserved.
//

#import "MIRCCaseController.h"
#import "MIRCController.h"

@implementation MIRCCaseController

- (void)dealloc{
	[self save];
	[_caseName release];
	[super dealloc];
}

- (void)awakeFromNib{
	NSMutableArray *cases = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"MIRCCases"] mutableCopy] autorelease];
	if (!cases)
		cases = [NSMutableArray array];
	[self setContent:cases];
	[tableView reloadData];
	if ([[self content] count] > 0) {
		[tableView selectRow:0 byExtendingSelection:NO];
		[self choose:nil];
	}
}

- (IBAction)controlAction: (id) sender{
	//NSLog(@"control Action");
	
	if ([sender selectedSegment] == 0) {
		[self addFolder:@"New Case"];
	}
	else if ([sender selectedSegment] == 1) {
		if ([tableView selectedRow] > -1 && [tableView selectedRow] < [[self content] count]) {
			[self removeFolder:[[self content] objectAtIndex:[tableView selectedRow]]];
			[(NSMutableArray *)[self content] removeObjectAtIndex:[tableView selectedRow]];
		}

	}
	[self save];
	[tableView reloadData];
	
	if ([sender selectedSegment] == 0) {
		int index = [[self content] count] - 1;
		//NSLog(@"index: %d", index);
		if (index > -1) {
			NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index] ;
			[tableView selectRowIndexes:indexSet byExtendingSelection:NO];
			[tableView editColumn:0 row:index withEvent:nil select:YES];
			//[tableView reloadData];
		}
	}
}

- (IBAction)choose: (id) sender{
	NSString *folder = [[self content] objectAtIndex:[tableView selectedRow]];
	NSLog(@"choose: %@", folder);
	[mircController setCaseName:folder];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTable{
	return [[self content] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
	return [[self content] objectAtIndex:rowIndex];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
	//NSLog(@"set object at index: %d", rowIndex);
	//replace only if name has changed
	NSString *oldValue = [[self content] objectAtIndex:rowIndex];
	if (![oldValue isEqualToString:(NSString *)anObject]){
		NSString *newName = [self replaceFolderName:oldValue withName:(NSString *)anObject];
		[(NSMutableArray *)[self content] replaceObjectAtIndex:rowIndex withObject:newName];
		[self save];
		[tableView reloadData];
	}
}

- (void)save{
	[[NSUserDefaults standardUserDefaults] setObject:[self content] forKey:@"MIRCCases"];
}

- (NSString *)caseName{
	return _caseName;
}

- (void)setCaseName:(NSString *)caseName{
	[_caseName release];
	_caseName = [caseName retain];
}

- (NSString *)replaceFolderName:(NSString *)caseString withName:(NSString *)newName{
	int i = 2;
	NSString *folderPath = [mircController path];
	NSString *source = [folderPath stringByAppendingPathComponent:caseString];
	NSString *destination = [folderPath stringByAppendingPathComponent:newName];
	while ([[NSFileManager defaultManager] fileExistsAtPath:destination])
		destination =  [[mircController path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %d", destination, i++]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager movePath:(NSString *)source toPath:(NSString *)destination handler:nil];
	return [destination lastPathComponent];
}

- (void)addFolder:(NSString *)folderName{
	int i = 2;
	//NSLog(@"Add Folder: %@", folderName);
	NSString *path = [[mircController path] stringByAppendingPathComponent:folderName];
	//NSLog(@"path: %@", path);
	while ([[NSFileManager defaultManager] fileExistsAtPath:path])
		path = [[mircController path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %d", folderName, i++]];
	//NSLog(@"path after: %@", path);
	[self addObject:[path lastPathComponent]];
	[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
}

- (void)removeFolder:(NSString *)folderName{
	[[NSFileManager defaultManager] removeFileAtPath: [[mircController path] stringByAppendingPathComponent:folderName]  handler:nil];
}


@end
