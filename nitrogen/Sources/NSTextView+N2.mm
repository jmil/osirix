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

-(NSSize)optimalSizeForWidth:(CGFloat)width {
	return [[self textStorage] sizeForWidth:width height:CGFLOAT_MAX];
}

-(NSSize)optimalSize {
	return [self optimalSizeForWidth:CGFLOAT_MAX];
}

-(NSSize)adaptToContent {
	return [self adaptToContent:CGFLOAT_MAX];
}

-(NSSize)adaptToContent:(CGFloat)maxWidth {
	NSSize stringSize = [[self textStorage] sizeForWidth:maxWidth height:CGFLOAT_MAX];
	[self setFrame:NSMakeRect([self frame].origin, stringSize)];
	return stringSize;
}

@end
