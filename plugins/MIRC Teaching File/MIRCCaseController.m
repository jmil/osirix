//
//  MIRCCaseController.m
//  TeachingFile
//
//  Created by Lance Pysher on 8/8/05.
//  Copyright 2005 Macrad, LLC. All rights reserved.
//

#import "MIRCCaseController.h"
#import "MIRCController.h"
#import "MIRCXMLController.h"
#import "CoreDataToMIRCXMLConverter.h"

@implementation MIRCCaseController

- (void)dealloc{
	[self save];
	[_caseName release];
	[_mircEditor release];
	[super dealloc];
}



- (IBAction)controlAction: (id) sender{	
	if ([sender selectedSegment] == 0) {
		[self add:self];
	}
	else if ([sender selectedSegment] == 1) {
			[self remove:self];
	}
}




- (void)save{
	[mircController save];
}

- (IBAction)create:(id)sender{
	if (_mircEditor) 
		[_mircEditor release];
	_mircEditor = [[MIRCXMLController alloc] initWithTeachingFile:[self teachingFile] managedObjectContext:[self managedObjectContext]];
	[_mircEditor showWindow:self];
}

- (IBAction)send{
	id teachingFile = [self teachingFile];
	// Create Temp Folder
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *tempPath= @"/tmp/TeachingFile";
	if ([manager fileExistsAtPath:tempPath])
		[manager removeFileAtPath:tempPath handler:nil];
	[manager createDirectoryAtPath:tempPath attributes:nil];
	//Create XML
	CoreDataToMIRCXMLConverter *converter = [[CoreDataToMIRCXMLConverter alloc] initWithTeachingFile:teachingFile];
	NSXMLDocument  *xmlDocument = [converter xmlDocument];
	[[xmlDocument XMLData] writeToFile:[tempPath stringByAppendingPathComponent:@"teachingFile.xml"] atomically:YES];
	[converter release];
	//Add movies
	NSLog(@"copy Movies");
	if ([teachingFile valueForKey:@"historyMovie"])
		[[teachingFile valueForKey:@"historyMovie"] writeToFile:[tempPath stringByAppendingPathComponent:@"history.mov"] atomically:YES];
	if ([teachingFile valueForKey:@"historyMovie"])
		[[teachingFile valueForKey:@"discussionMovie"] writeToFile:[tempPath stringByAppendingPathComponent:@"discussion.mov"] atomically:YES];
		
	// Add Images;
	NSEnumerator *enumerator = [teachingFile valueForKey:@"images"];
	id image;
	NSLog(@"copy images");
	while (image = [enumerator nextObject]) {
		NSString *index = [[image valueForKey:@"index"] stringValue];
		[[image valueForKey:@"primary"] writeToFile:
			[tempPath stringByAppendingPathComponent:[index stringByAppendingPathExtension:@"jpg"]] atomically:YES];
			
		[[image valueForKey:@"originalDimension"] writeToFile:
			[tempPath stringByAppendingPathComponent:[[index stringByAppendingString:@"-OD"] 
			stringByAppendingPathExtension:[image valueForKey:@"originalDimensionExtension"]]] atomically:YES];
			
		[[image valueForKey:@"annotation"] writeToFile:
			[tempPath stringByAppendingPathComponent:[[index stringByAppendingString:@"-ANN"]
			stringByAppendingPathExtension:@"jpg"]] atomically:YES];
			
		[[image valueForKey:@"originalFormat"] writeToFile:
			[tempPath stringByAppendingPathComponent:[[index stringByAppendingString:@"-OF"]
			stringByAppendingPathExtension:[image valueForKey:@"originalFormatExtension"]]] atomically:YES];
	}
	
	//Create Archive
	manager = [NSFileManager defaultManager];
	NSString *path = @"/tmp/archive.zip";
	if ([manager fileExistsAtPath:path])
			[manager removeFileAtPath:path handler:nil];
		//create Zip with NSTask
	NSTask *task = [[NSTask alloc] init];
	[task setCurrentDirectoryPath:tempPath];
	[task setLaunchPath:@"/usr/bin/zip/"];
	NSMutableArray*args = [NSMutableArray arrayWithObject:path];
	[args addObjectsFromArray:[[NSFileManager defaultManager] directoryContentsAtPath:tempPath]];
	[task setArguments:args];
	NSLog(@"Create archive args: %@ path: %@", args, path);
	[task  launch];
	[task waitUntilExit];
	[task release];
	
	// send
	NSString *destination = nil;
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *dirPath = [bundle resourcePath];
	task = [[NSTask alloc] init];
	[task setCurrentDirectoryPath:dirPath];
	[task setLaunchPath:@"/usr/bin/java/"];
	args = [NSArray arrayWithObjects:@"-jar", @"fs.jar", @"/tmp/archive.zip", destination, nil];
	[task setArguments:args];
	NSLog(@"send archive args: %@", args);
	[task  launch];
	[task waitUntilExit];
	[task release];
	
	
}

- (id)teachingFile {
	return [[self selectedObjects] objectAtIndex:0];
}








@end
