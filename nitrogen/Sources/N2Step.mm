//
//  N2Step.mm
//  Nitrogen Framework
//
//  Created by Joris Heuberger on 02/04/07.
//  Edited by Alessandro Volz since 21/05/09.
//  Copyright 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Nitrogen/N2Step.h>

NSString* N2StepDidBecomeActiveNotification = @"N2StepDidBecomeActiveNotification";
NSString* N2StepDidBecomeInactiveNotification = @"N2StepDidBecomeInactiveNotification";
NSString* N2StepDidBecomeEnabledNotification = @"N2StepDidBecomeEnabledNotification";
NSString* N2StepDidBecomeDisabledNotification = @"N2StepDidBecomeDisabledNotification";

@implementation N2Step
@synthesize enclosedView = _enclosedView, title = _title, isActive = _isActive, isNecessary = _isNecessary, isDone = _isDone, isEnabled = _isEnabled;

-(id)initWithTitle:(NSString*)aTitle enclosedView:(NSView*)aView {
	_enclosedView = [aView retain];
	_title = [aTitle retain];
	
	_isNecessary = YES;
	_isActive = NO;
	_isEnabled = YES;
	_isDone = NO;
	
	return self;
}

-(void)dealloc {
	[_enclosedView release];
	[_title release];
	[super dealloc];
}

-(void)setIsActive:(BOOL)isActive {
	if (_isActive != isActive) {
		_isActive = isActive;
		[[NSNotificationCenter defaultCenter] postNotificationName:(isActive ?N2StepDidBecomeActiveNotification :N2StepDidBecomeInactiveNotification) object:self];
	}
}

-(void)setIsEnabled:(BOOL)isEnabled {
	if (_isEnabled != isEnabled) {
		if (!isEnabled && _isActive)
			[self setIsActive:NO];
		_isEnabled = isEnabled;
		[[NSNotificationCenter defaultCenter] postNotificationName:(isEnabled ?N2StepDidBecomeEnabledNotification :N2StepDidBecomeDisabledNotification) object:self];
	}
}



@end
