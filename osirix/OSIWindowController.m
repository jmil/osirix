/*=========================================================================
  Program:   OsiriX

  Copyright (c) OsiriX Team
  All rights reserved.
  Distributed under GNU - GPL
  
  See http://www.osirix-viewer.com/copyright.html for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
=========================================================================*/

#import "OSIWindowController.h"
//#import "WindowLayoutManager.h"

@implementation OSIWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName{
	if (self = [super initWithWindowNibName:(NSString *)windowNibName])
	{
	}
	return self;
}

 - (BOOL) FullScreenON
 {
	return NO;
 }

- (void)dealloc{
	[super dealloc];
}

- (void) addToUndoQueue:(NSString*) what
{
	NSLog( @"OSIWindowController addToUndoQueue CALL SUPER ??");
}

- (IBAction) redo:(id) sender
{
	NSLog( @"OSIWindowController redo CALL SUPER ??");
}

- (IBAction) undo:(id) sender
{
	NSLog( @"OSIWindowController undo CALL SUPER ??");
}

- (NSMutableArray*) pixList{
	// let subclasses handle it for now
	return nil;
}

- (int)blendingType{
	return _blendingType;
}

- (void) applyShading:(id) sender
{
	NSLog( @"OSIWindowController applyShading - CALL SUPER ??");
}

#pragma mark-
#pragma mark current Core Data Objects
- (NSManagedObject *)currentStudy{
	return nil;
}
- (NSManagedObject *)currentSeries{
	return nil;
}
- (NSManagedObject *)currentImage{
	return nil;
}

-(float)curWW{
	return 0.0;
}

-(float)curWL{
	return 0.0;
}
	

@end
