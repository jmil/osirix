//
//  EjectionFraction.mm
//  Ejection Fraction II
//
//  Created by Alessandro Volz on 7/20/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "EjectionFractionPlugin.h"
#import "EjectionFractionStepsController.h"

@implementation EjectionFractionPlugin

/*-(void)n2test {
	NSLog(@"n2test n2test n2test n2test n2test n2test n2test n2test n2test n2test n2test");
	N2Window* window = [[N2Window alloc] initWithContentRect:NSMakeRect(0, 0, 400, 300) styleMask:NSTitledWindowMask|NSClosableWindowMask|NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
	N2LayoutManager* layout = [[[N2LayoutManager alloc] initWithControlSize:NSRegularControlSize] autorelease];
//	[layout setForcesSuperviewSize:YES];
//	[layout setStretchesToFill:YES];
//	[layout setOccupiesEntireSuperview:YES];
	[[window contentView] setLayout:layout];
	
	NSTextView* temp;
	temp = [[NSTextView alloc] init];
	[temp setString:@"Random text content."];
	[temp setEditable:NO];
	[[window contentView] addSubview:[temp autorelease]];
	[temp adaptToContent];
	[[window contentView] addDescriptor:[N2LayoutDescriptor createWithAlignment:N2AlignmentRight]];
	temp = [[NSTextView alloc] init];
	[temp setString:@"Random text content."];
	[temp setEditable:NO];
	[[window contentView] addSubview:[temp autorelease]];
	[temp adaptToContent];
 
	
	[layout recalculate:[window contentView]];
	[window makeKeyAndOrderFront:self];
	NSLog(@"Ok");
}*/

-(void)initPlugin {
	//[self n2test];
	EjectionFractionStepsController* controller = [[EjectionFractionStepsController alloc] initWithPlugin:self];
	[controller showWindow:NULL];
//	NSLog(@"controller window [%f, %f, %f, %f]", [[controller window] frame].origin.x, [[controller window] frame].origin.y, [[controller window] frame].size.width, [[controller window] frame].size.height);
}

-(long)filterImage:(NSString*)menuName {
	return 0;
}

@end
