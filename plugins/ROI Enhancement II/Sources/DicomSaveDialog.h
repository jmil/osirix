//
//  DicomSaveDialog.h
//  ROI Enhancement II
//
//  Created by Alessandro Volz on 5/12/09.
//  Copyright 2009 HUG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Interface;

@interface DicomSaveDialog : NSWindow {
	IBOutlet Interface* _interface;
	IBOutlet NSTextField* _seriesName;
	IBOutlet NSColorWell* _imageBackgroundColor;
	IBOutlet NSButton* _saveButton;
	IBOutlet NSButton* _cancelButton;
}

-(IBAction)buttonClicked:(id)sender;

-(NSColor*)imageBackgroundColor;
-(void)setImageBackgroundColor:(NSColor*)imageBackgroundColor;
-(NSString*)seriesName;
-(void)setSeriesName:(NSString*)seriesName;	

@end
