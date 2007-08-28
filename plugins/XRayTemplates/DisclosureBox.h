//
//  DisclosureBox.h
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DisclosureButton : NSButton
{
	NSImage *clickedImage, *tempImage, *tempAlternateImage;
}

+ (NSImage*)_createTriangleImageWithPoint1:(NSPoint)p1 point2:(NSPoint)p2 point3:(NSPoint)p3;
+ (NSImage*)_createTriangleImageWithPoint1:(NSPoint)p1 point2:(NSPoint)p2 point3:(NSPoint)p3 color:(NSColor*)color;
- (void)setClickedImage:(NSImage*)img;
- (void)setColor:(NSColor*)color;

@end

@interface DisclosureBox : NSBox
{
	DisclosureButton *disclosureButton;
	NSTextField *titleTextField;
	BOOL isExpanded;
	NSView *enclosedView;
	NSColor *enabledColor, *disabledColor;
}

- (void)setEnclosedView:(NSView*)view;
- (void)toggle:(id)sender;
- (void)expand:(id)sender;
- (void)collapse:(id)sender;
- (BOOL)isExpanded;
- (void)setEnabled:(BOOL)flag;
- (void)setColor:(NSColor*)color;
- (void)setDisabledColor:(NSColor*)color;

@end
