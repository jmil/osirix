//
//  DisclosureBox.h
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ATButtonCell;

@interface DisclosureBox : NSBox {
	BOOL _showingExpanded;
	NSView* _content;
	CGFloat _contentHeight;
}

-(id)initWithTitle:(NSString*)title content:(NSView*)view;
-(void)setEnabled:(BOOL)flag;
-(BOOL)isExpanded;
-(void)toggle:(id)sender;
-(void)expand:(id)sender;
-(void)collapse:(id)sender;

@end
