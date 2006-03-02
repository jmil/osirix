//
//  MIRCAuthorController.m
//  TeachingFile
//
//  Created by Lance Pysher on 8/10/05.
//  Copyright 2005 Macrad, LLC. All rights reserved.
//

#import "MIRCAuthorController.h"
#import "MIRCAuthor.h"


@implementation MIRCAuthorController

- (void)addObject:(id)object{
	[object setAuthorName:@"New Author"];
	[super addObject:object];
	[tableView selectRow:[tableView numberOfRows] - 1 byExtendingSelection:NO];
}



@end
