//
//  DebugTest.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 1/21/10.
//  Copyright 2010 OsiriX Team. All rights reserved.
//

#import "DebugTest.h"
#import <Nitrogen/N2Debug.h>

@implementation DebugTest

-(void)testDebug {
	DLog(@"First, initial status...");
	[N2Debug setActive:YES];
	DLog(@"Second, after [N2Debug setActive:YES]");
	[N2Debug setActive:NO];
	DLog(@"Last, after [N2Debug setActive:NO]");
}

@end
