//
//  SBSView.h
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SBS, SBSStep;

@interface SBSView : NSView {
	NSMutableArray* _stepViews;
	IBOutlet SBS* _controller;
}

-(void)addStep:(SBSStep*)step;
-(void)setStep:(SBSStep*)step enabled:(BOOL)enabled;
-(void)expandStep:(SBSStep*)step;
-(void)collapseStep:(SBSStep*)step;
-(BOOL)isExpanded:(SBSStep*)step;
-(BOOL)isCollapsed:(SBSStep*)step;
-(void)recomputeSubviewFramesAndAdjustSizes;

@end
