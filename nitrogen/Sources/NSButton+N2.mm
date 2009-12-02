//
//  NSButton+N2.mm
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 07/09/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/NSButton+N2.h>
#import <Nitrogen/NS(Attributed)String+Geometrics.h>
#import <Nitrogen/N2Operators.h>

@implementation NSButton (N2)

-(id)initWithOrigin:(NSPoint)origin title:(NSString*)title font:(NSFont*)font {
	NSSize size = [title sizeForWidth:MAXFLOAT height:MAXFLOAT font:font];
	self = [self initWithFrame:NSMakeRect(origin, size+NSMakeSize(4,1)*2)];
	[self setTitle:title];
	[self setFont:font];
	return self;
}

-(NSSize)optimalSizeForWidth:(CGFloat)width {
	NSSize size = [[self cell] cellSize];
	if (size.width > width) size.width = width;
	
	switch ([self bezelStyle]) {
		case NSRecessedBezelStyle: {
			if ([[self cell] controlSize] == NSMiniControlSize) size.height -= 4;
		} break;
	}
	
	return size;
}

-(NSSize)optimalSize {
	return [self optimalSizeForWidth:CGFLOAT_MAX];
}

@end
