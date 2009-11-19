//
//  BullsEyeController.m
//  BullsEye
//
//  Created by Antoine Rosset on 18.11.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "BullsEyeController.h"
#import "ColorCell.h"
#import "BullsEyeView.h"

@implementation BullsEyeController

- (void) dealloc
{
	[super dealloc];
}

- (NSArray*) presetBullsEyeArray
{
	return [presetBullsEye arrangedObjects];
}

- (void) windowWillClose:(NSNotification*)notification
{
	if ([notification object] == [self window])
	{
		[[NSUserDefaults standardUserDefaults] setValue: [presetsList arrangedObjects] forKey: @"presetsBullsEyeList"];
		
		[[self window] orderOut: self];
		[self release];
	}
}
- (IBAction) refresh: (id) sender
{
	[[BullsEyeView view] refresh];
}

- (id) initWithWindowNibName:(NSString *)windowNibName
{
	if( [[NSUserDefaults standardUserDefaults] objectForKey: @"presetsBullsEyeList"] == nil)
	{
		NSDictionary *dict1, *dict2, *dict3, *dict4;
		
		dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"normal", @"state", [NSArchiver archivedDataWithRootObject: [NSColor whiteColor]], @"color", nil];
		dict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"hypokinesia", @"state", [NSArchiver archivedDataWithRootObject: [NSColor yellowColor]], @"color", nil];
		dict3 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"akinesia", @"state", [NSArchiver archivedDataWithRootObject: [NSColor orangeColor]], @"color", nil];
		dict4 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"dyskinesia", @"state", [NSArchiver archivedDataWithRootObject: [NSColor redColor]], @"color", nil];
		
		[[NSUserDefaults standardUserDefaults] setValue: [NSArray arrayWithObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSArray arrayWithObjects: dict1, dict2, dict3, dict4, nil], @"array", @"Wall Motion", @"name", nil]] forKey: @"presetsBullsEyeList"];
	}
	
	self = [super initWithWindowNibName: windowNibName];

	return self;
}

- (void) awakeFromNib
{
	NSTableColumn* column = [presetsTable tableColumnWithIdentifier: @"color"];	// get the first column in the table
	ColorCell* colorCell = [[[ColorCell alloc] init] autorelease];			// create the special color well cell
    [colorCell setEditable: YES];								// allow user to change the color
	[colorCell setTarget: self];								// set colorClick as the method to call
	[colorCell setAction: @selector (colorClick:)];				// when the color well is clicked on
	[column setDataCell: colorCell];							// sets the columns cell to the color well cell

	[[BullsEyeView view] refresh];
}

- (void) colorClick: (id) sender		// sender is the table view
{	
	NSColorPanel* panel = [NSColorPanel sharedColorPanel];
	[panel setTarget: self];			// send the color changed messages to colorChanged
	[panel setAction: @selector (colorChanged:)];
	[panel setShowsAlpha: YES];			// per ber to show the opacity slider
	[panel setColor: [NSUnarchiver unarchiveObjectWithData: [[[presetBullsEye arrangedObjects] objectAtIndex: [presetsTable selectedRow]] objectForKey: @"color"]]];	// set the starting color
	[panel makeKeyAndOrderFront: self];	// show the panel
}

- (void) colorChanged: (id) sender		// sender is the NSColorPanel
{	
	[[[presetBullsEye arrangedObjects] objectAtIndex: [presetsTable selectedRow]]  setObject: [NSArchiver archivedDataWithRootObject: [sender color]] forKey: @"color"]; // use saved row index to change the correct in the color array (the model)
}
@end
