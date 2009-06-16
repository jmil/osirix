//
//  Step.h
//  StepByStepFramework
//
//  Created by Joris Heuberger on 02/04/07.
//  Copyright 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBSStep : NSObject {
	NSView* _enclosedView;
	NSString* _title;
	BOOL _isNecessary;
	BOOL _isDone;
}

@property(readonly,retain) NSView* enclosedView;
@property(readonly,retain) NSString* title;
@property(assign) BOOL isNecessary;
@property(assign) BOOL isDone;

-(id)initWithTitle:(NSString*)aTitle enclosedView:(NSView*)aView;

@end
