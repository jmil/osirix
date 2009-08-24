//
//  StepView.h
//  Nitrogen Framework
//
//  Created by Joris Heuberger on 30/03/07.
//  Copyright 2007-2009 OsiriX Foundation. All rights reserved.
//

#import <Nitrogen/N2DisclosureBox.h>
@class N2Step;

@interface N2StepView : N2DisclosureBox {
	N2Step* _step;
}

@property(readonly) N2Step* step;

-(id)initWithStep:(N2Step*)step;

@end
