//
//  PopUpMenuButton.mm
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 4/23/09.
//  Copyright 2009 HUG. All rights reserved.
//

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
