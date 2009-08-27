//
//  SBSView.h
//  Nitrogen Framework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007-2009 OsiriX Team. All rights reserved.
//

#import "N2View.h"
@class N2Steps, N2Step;

@interface N2StepsView : N2View {
	IBOutlet N2Steps* _steps;
	NSColor* _foreColor;
	NSControlSize _controlSize;
//	NSMutableArray* _views;
}

@property(retain) NSColor* foreColor;
@property NSControlSize controlSize;

//-(void)addStep:(N2Step*)step;
//-(void)recomputeSubviewFramesAndAdjustSizes;
-(void)stepsDidAddStep:(NSNotification*)notification;

@end
