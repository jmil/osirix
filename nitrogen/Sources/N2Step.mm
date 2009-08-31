//
//  N2Step.mm
//  Nitrogen Framework
//
//  Created by Joris Heuberger on 02/04/07.
//  Edited by Alessandro Volz since 21/05/09.
//  Copyright 2007-2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2Step.h>

NSString* N2StepDidBecomeActiveNotification = @"N2StepDidBecomeActiveNotification";
NSString* N2StepDidBecomeInactiveNotification = @"N2StepDidBecomeInactiveNotification";
NSString* N2StepDidBecomeEnabledNotification = @"N2StepDidBecomeEnabledNotification";
NSString* N2StepDidBecomeDisabledNotification = @"N2StepDidBecomeDisabledNotification";

@implementation N2Step
@synthesize enclosedView = _enclosedView, title = _title, active = _active, necessary = _necessary, done = _done, enabled = _enabled, shouldStayVisibleWhenInactive = _shouldStayVisibleWhenInactive;

-(id)initWithTitle:(NSString*)aTitle enclosedView:(NSView*)aView {
	_enclosedView = [aView retain];
	_title = [aTitle retain];
	
	_necessary = YES;
	_active = NO;
	_enabled = YES;
	_done = NO;
	
	return self;
}

-(void)dealloc {
	[_enclosedView release];
	[_title release];
	[super dealloc];
}

-(void)setActive:(BOOL)active {
	if (_active != active) {
		_active = active;
		[[NSNotificationCenter defaultCenter] postNotificationName:(active ?N2StepDidBecomeActiveNotification :N2StepDidBecomeInactiveNotification) object:self];
	}
}

-(void)setEnabled:(BOOL)enabled {
	if (_enabled != enabled) {
		if (!enabled && _active)
			[self setActive:NO];
		_enabled = enabled;
		[[NSNotificationCenter defaultCenter] postNotificationName:(enabled ?N2StepDidBecomeEnabledNotification :N2StepDidBecomeDisabledNotification) object:self];
	}
}



@end
