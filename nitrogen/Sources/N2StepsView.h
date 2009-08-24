//
//  SBSView.h
//  Nitrogen Framework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class N2Steps, N2Step;

@interface N2StepsView : NSView {
	IBOutlet N2Steps* _steps;
	NSMutableArray* _views;
}

//-(void)addStep:(N2Step*)step;
//-(void)recomputeSubviewFramesAndAdjustSizes;

@end
