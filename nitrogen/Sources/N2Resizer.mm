//
//  N2Resizer.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 16.11.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "N2Resizer.h"
#import "N2View.h"
#import "N2Operators.h"


@implementation N2Resizer
@synthesize observed = _observed, affected = _affected;

-(id)initByObservingView:(NSView*)observed affecting:(NSView*)affected {
	self = [super init];
	[self setObserved:observed];
	[self setAffected:affected];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observedBoundsSizeDidChange:) name:N2ViewBoundsSizeDidChangeNotification object:observed];
	return self;
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self setObserved:NULL];
	[self setAffected:NULL];
	[super dealloc];
}

-(void)observedBoundsSizeDidChange:(NSNotification*)notification {
	if (_resizing) return;
	_resizing = YES;
	
	NSValue* value = [[notification userInfo] objectForKey:N2ViewBoundsSizeDidChangeNotificationOldBoundsSize];
	NSSize oldBoundsSize = [value sizeValue], currBoundsSize = [_observed bounds].size;
	if (currBoundsSize != oldBoundsSize)
		[_affected setFrameSize:[_affected frame].size+(currBoundsSize-oldBoundsSize)];
	[_observed setFrameSize:currBoundsSize];
	
	_resizing = NO;
}

@end
