//
//  SBSView.h
//  Nitrogen Framework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007-2009 OsiriX Team. All rights reserved.
//

#import "N2View.h"
@class N2Steps, N2Step, N2StepView, N2ColumnLayout;

@interface N2StepsView : N2View {
	IBOutlet N2Steps* _steps;
}

-(void)stepsDidAddStep:(NSNotification*)notification;
-(N2StepView*)stepViewForStep:(N2Step*)step;
-(void)layOut;

@end
