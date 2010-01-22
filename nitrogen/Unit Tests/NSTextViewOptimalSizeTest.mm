//
//  NSTextViewOptimalSizeTest.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 1/19/10.
//  Copyright 2010 OsiriX Team. All rights reserved.
//

#import "NSTextViewOptimalSizeTest.h"
#import <Nitrogen/N2Operators.h>
#import <Nitrogen/NSTextView+N2.h>
#import <Nitrogen/NSView+N2.h>


@implementation NSTextViewOptimalSizeTest

-(void)testOptimalSize {
	NSTextView* view = [[NSTextView alloc] initWithSize:NSZeroSize];
	[view setString:@"Test."];
	
	NSSize os = [view optimalSize];
	[view setFrame:NSMakeRect(NSZeroPoint, os)];
	
	NSSize nos = [view optimalSizeForWidth:os.width+[view sizeAdjust].size.width];
	
	STAssertEquals(os.width, nos.width, @"Widths not matching: [view optimalSize] = %f and [view optimalSizeForWidth:%f] = %f", os.width, os.width+[view sizeAdjust].size.width, nos.width);
	
	[view release];
}

@end
