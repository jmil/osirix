//
//  StepView.h
//  StepByStepFramework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DisclosureBox.h"
#import "Step.h"

@interface StepView : DisclosureBox {
	Step* _step;
}

@property(readonly) Step* step;

-(id)initWithStep:(Step*)aStep;

@end
