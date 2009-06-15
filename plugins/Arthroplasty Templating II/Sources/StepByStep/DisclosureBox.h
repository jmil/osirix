//
//  DisclosureBox.h
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DisclosureBox : NSBox {
	NSButton* _button;
}

-(id)initWithTitle:(NSString*)title content:(NSView*)content;
-(void)setEnabled:(BOOL)flag;
-(BOOL)isExpanded;
-(void)toggle:(id)sender;
-(void)expand:(id)sender;
-(void)collapse:(id)sender;

@end
