//
//  NSTextView+N2.mm
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 07/08/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/NSTextView+N2.h>
#import <Nitrogen/NS(Attributed)String+Geometrics.h>
#import <Nitrogen/N2Operators.h>

@implementation NSTextView (N2)

-(NSSize)adaptToContent {
	return [self adaptToContent:MAXFLOAT];
}

-(NSSize)adaptToContent:(CGFloat)maxWidth {
	NSSize stringSize = [[self textStorage] sizeForWidth:maxWidth height:MAXFLOAT];
	[self setFrame:NSMakeRect([self frame].origin, stringSize)];
	return stringSize;
}

@end
