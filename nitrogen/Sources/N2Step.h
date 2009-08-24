//
//  N2Step.h
//  Nitrogen Framework
//
//  Created by Joris Heuberger on 02/04/07.
//  Edited by Alessandro Volz since 21/05/09.
//  Copyright 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* N2StepDidBecomeActiveNotification;
extern NSString* N2StepDidBecomeInactiveNotification;
extern NSString* N2StepDidBecomeEnabledNotification;
extern NSString* N2StepDidBecomeDisabledNotification;

@interface N2Step : NSObject {
	NSString* _title;
	NSView* _enclosedView;
	BOOL _isNecessary, _isActive, _isEnabled, _isDone;
}

@property(readonly) NSString* title;
@property(readonly) NSView* enclosedView;
@property(assign) BOOL isNecessary;
@property BOOL isActive;
@property BOOL isEnabled;
@property BOOL isDone;

-(id)initWithTitle:(NSString*)title enclosedView:(NSView*)view;

@end
