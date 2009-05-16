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

#import "PopUpMenuButton.h"


@implementation PopUpMenuButton

-(void)mouseDown:(NSEvent*)theEvent {
	if ([self menu]) {
		NSPopUpButtonCell* cell = [[[NSPopUpButtonCell alloc] initTextCell:@"Test" pullsDown:NO] autorelease];
		[cell setMenu:[self menu]];
		[cell setFont:[NSFont menuFontOfSize:[NSFont smallSystemFontSize]]];
		[cell performClickWithFrame:[self frame] inView:self];		
	}
}

@end
