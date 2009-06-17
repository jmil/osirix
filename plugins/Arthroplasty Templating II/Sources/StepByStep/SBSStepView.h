//
//  StepView.h
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DisclosureBox.h"
@class SBSStep;

@interface SBSStepView : DisclosureBox {
	SBSStep* _step;
}

@property(readonly) SBSStep* step;

-(id)initWithStep:(SBSStep*)step;

@end
