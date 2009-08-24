//
//  N2Window.m
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/12/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2Window.h>
#import <Nitrogen/N2View.h>


@implementation N2Window

-(id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
	self = [super initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation];
	[self setContentView:[[N2View alloc] initWithFrame:[[self contentView] frame]]];
	return self;
}

@end
