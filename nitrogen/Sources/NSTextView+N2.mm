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

+(NSTextView*)labelWithText:(NSString*)text {
	return [self labelWithText:text alignment:NSNaturalTextAlignment];
}

+(NSTextView*)labelWithText:(NSString*)text alignment:(NSTextAlignment)alignment {
	NSTextView* ret = [[NSTextView alloc] initWithSize:NSZeroSize];
	[ret setString:text];
	[ret setAlignment:alignment];
	[ret setEditable:NO];
	[ret setSelectable:NO];
	return [ret autorelease];
}

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
	NSSize stringSize = [self optimalSizeForWidth:maxWidth];
	[self setFrame:NSMakeRect([self frame].origin, stringSize)];
	return stringSize;
}

@end
