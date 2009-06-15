//
//  SBSView.h
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StepView.h"
@class StepByStep;

@interface SBSView : NSView {
	NSMutableArray *stepViews;
	IBOutlet StepByStep *controller;
}

- (void)addStep:(Step*)step;

//- (void)setControlColor:(NSColor*)color;
//- (void)setDisabledControlColor:(NSColor*)color;

- (void)computeStepViewFrames;
- (void)adjustWindow;

- (void)expandStepAtIndex:(unsigned)index;
- (void)collapseStepAtIndex:(unsigned)index;

- (void)stepViewWillExpandNotification:(NSNotification*)notification;
- (void)stepViewDidExpandNotification:(NSNotification*)notification;
- (void)stepViewDidCollapseNotification:(NSNotification*)notification;
- (void)stepViewDidToggleNotification:(NSNotification*)notification;

- (void)setStepAtIndex:(unsigned)index enabled:(BOOL)enabled;

@end
