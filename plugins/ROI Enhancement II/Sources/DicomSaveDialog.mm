//
//  DicomSaveDialog.mm
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 5/12/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import "DicomSaveDialog.h"


@implementation DicomSaveDialog

-(void)awakeFromNib {
	[self setDefaultButtonCell:[_saveButton cell]];
	[self setDelegate:self];
	[_seriesName setDelegate:self];
	[self controlTextDidChange:NULL];
}

-(IBAction)buttonClicked:(id)sender {
	[NSApp endSheet:self returnCode:(sender==_saveButton?NSOKButton:NSCancelButton)];
	[self orderOut:self];
}

-(void)windowWillBeginSheet:(NSNotification*)notification {
	[self setSeriesName:@""];
}

-(void)controlTextDidChange:(NSNotification*)aNotification {
	[_saveButton setEnabled:([[_seriesName stringValue] length] > 0)];
}

-(NSColor*)imageBackgroundColor {
	return [_imageBackgroundColor color];
}

-(void)setImageBackgroundColor:(NSColor*)imageBackgroundColor {
	[_imageBackgroundColor setColor:imageBackgroundColor];
}

-(NSString*)seriesName {
	return [_seriesName stringValue];
}

-(void)setSeriesName:(NSString*)seriesName {
	[_seriesName setStringValue:seriesName];
}



@end
