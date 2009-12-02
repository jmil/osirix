//
//  N2GridLayout.mm
//  Nitrogen
//
//  Created by Alessandro Volz on 11.11.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "N2ColumnLayout.h"
#import "N2ColumnDescriptor.h"
#import "NSView+N2.h"
#import "N2Operators.h"
#include <algorithm>
#include <cmath>

@implementation N2ColumnLayout

-(id)initForView:(N2View*)view columnDescriptors:(NSArray*)columnDescriptors controlSize:(NSControlSize)controlSize {
	self = [super initWithView:view controlSize:controlSize];
	
	_columnDescriptors = [columnDescriptors retain];
	_lines = [[NSMutableArray alloc] initWithCapacity:8];
	
	return self;
}

-(void)dealloc {
	[_lines release];
	[_columnDescriptors release];
	[super dealloc];
}

-(NSArray*)lineAtIndex:(NSUInteger)index {
	return [_lines objectAtIndex:index];
}

-(NSUInteger)appendLine:(NSArray*)views {
	NSUInteger i = [_lines count];
	[self insertLine:views atIndex:i];
	return i;
}

-(void)insertLine:(NSArray*)views atIndex:(NSUInteger)index {
	if ([views count] != [_columnDescriptors count])
		[NSException raise:NSGenericException format:@"The number of views in a line must match the number of columns"];
	[_lines insertObject:views atIndex:index];
	for (NSView* view in views)
		[_view addSubview:view];
	[self layOut];
}

-(void)removeLineAtIndex:(NSUInteger)index {
	NSArray* views = [_lines objectAtIndex:index];
	for (NSView* view in views)
		[view removeFromSuperview];
	[_lines removeObjectAtIndex:index];
}

-(void)removeAllLines {
	for (int l = [_lines count]-1; l >= 0; --l)
		[self removeLineAtIndex:l];
}

-(NSArray*)computeSizesForWidth:(CGFloat)width {
	NSUInteger linesCount = [_lines count];
	NSUInteger colsCount = [_columnDescriptors count];
	
	if (!linesCount)
		return NULL;
	
	CGFloat colWidth[colsCount];
	N2MinMax constraints[colsCount];
	for (NSUInteger i = 0; i < colsCount; ++i) {
		colWidth[i] = 0;
		constraints[i] = [(N2ColumnDescriptor*)[_columnDescriptors objectAtIndex:i] widthConstraints];
	}
	
	for (NSArray* line in _lines)
		for (NSUInteger i = 0; i < colsCount; ++i) {
			CGFloat optimalWidth;
			NSView* view = [line objectAtIndex:i];
			if ([view respondsToSelector:@selector(optimalSize)])
				optimalWidth = [(NSView<OptimalSize>*)view optimalSize].width;
			else optimalWidth = [view frame].size.width;
			colWidth[i] = std::max(colWidth[i], optimalWidth);
		}
	
	while (true) {
		// apply constraints
		CGFloat currentWidth = 0, targetWidth = width - _margin.size.width - _separation.width*std::max((int)colsCount-1, 0);
		for (NSUInteger i = 0; i < colsCount; ++i)
			currentWidth += colWidth[i] = std::ceil(N2MinMaxConstrainedValue(constraints[i], colWidth[i]));
		
		if (currentWidth == targetWidth)
			break;
		
		CGFloat deltaWidth = targetWidth-currentWidth; // if (deltaWidth > 0) increase
		BOOL colFixed[colsCount];
		int unfixedColsCount = 0;
		CGFloat unfixedRefWidth = 0;
		for (NSUInteger i = 0; i < colsCount; ++i)
			if (!(colFixed[i] = !((deltaWidth > 0 && colWidth[i] < constraints[i].max) || (deltaWidth < 0 && colWidth[i] > constraints[i].min)))) {
				++unfixedColsCount;
				unfixedRefWidth += colWidth[i];
			}
		
		if (!unfixedColsCount)
			break;
		
		for (NSUInteger i = 0; i < colsCount; ++i)
			if (!colFixed[i])
				colWidth[i] += deltaWidth*unfixedRefWidth/colWidth[i];
	}
	
	// get cell sizes and line heights
	NSSize sizes[linesCount][colsCount];
//	CGFloat lineHeights[linesCount];
	for (NSUInteger l = 0; l < linesCount; ++l) {
		NSArray* line = [_lines objectAtIndex:l];
//		lineHeights[l] = 0;
		for (NSUInteger i = 0; i < colsCount; ++i) {
			NSView* view = [line objectAtIndex:i];
			if ([view respondsToSelector:@selector(optimalSizeForWidth:)])
				sizes[l][i] = NSRoundSize([(NSView<OptimalSize>*)view optimalSizeForWidth:colWidth[i]]);
			else sizes[l][i] = NSRoundSize([view frame].size);
//			lineHeights[l] = std::max(lineHeights[l], sizes[l][i].height);
		}
	}
	
	NSMutableArray* resultSizes = [NSMutableArray arrayWithCapacity:linesCount];
	for (NSUInteger l = 0; l < linesCount; ++l) {
		NSMutableArray* resultLineSizes = [NSMutableArray arrayWithCapacity:colsCount];
		for (NSUInteger i = 0; i < colsCount; ++i)
			[resultLineSizes addObject:[NSValue valueWithSize:sizes[l][i]]];
		[resultSizes addObject:resultLineSizes];
	}
	NSMutableArray* resultColWidths = [NSMutableArray arrayWithCapacity:colsCount];
	for (NSUInteger i = 0; i < colsCount; ++i)
		[resultColWidths addObject:[NSNumber numberWithFloat:colWidth[i]]];
	return [NSArray arrayWithObjects: resultColWidths, resultSizes, NULL];
}

-(void)layOutImpl {
	NSUInteger linesCount = [_lines count];
	NSUInteger colsCount = [_columnDescriptors count];

	NSSize size = [_view frame].size;
	
	NSArray* sizesData = [self computeSizesForWidth:size.width];
	CGFloat colWidth[colsCount];
	for (NSUInteger i = 0; i < colsCount; ++i)
		colWidth[i] = [[[sizesData objectAtIndex:0] objectAtIndex:i] floatValue];
	NSSize sizes[linesCount][colsCount];
	CGFloat lineHeights[linesCount];
	for (NSUInteger l = 0; l < linesCount; ++l) {
		NSArray* linesizes = [[sizesData objectAtIndex:1] objectAtIndex:l];
		lineHeights[l] = 0;
		for (NSUInteger i = 0; i < colsCount; ++i) {
			sizes[l][i] = [[linesizes objectAtIndex:i] sizeValue];
			lineHeights[l] = std::max(lineHeights[l], sizes[l][i].height);
		}
	}
		
	// apply computed column widths
	CGFloat y = _margin.origin.y;
	CGFloat maxX = 0;
	for (NSInteger l = linesCount-1; l >= 0; --l) {
		NSArray* line = [_lines objectAtIndex:l];
		
		CGFloat x = _margin.origin.x;
		for (NSUInteger i = 0; i < colsCount; ++i) {
			NSView* view = [line objectAtIndex:i];
			NSPoint origin = NSMakePoint(x, y);
			NSSize size = sizes[l][i];
			if (size.width < colWidth[i]) size.width = colWidth[i];
			// TODO: position size in cell.size by changing origin (cell size must be known)
			[view setFrame:NSMakeRect(origin, size)];
			x += colWidth[i]+_separation.width;
		}
		x += _margin.size.width-_margin.origin.x - _separation.width;
		
		maxX = std::max(maxX, x);
		y += lineHeights[l]+_separation.height;
	}
	y += _margin.size.height-_margin.origin.y - _separation.height;
	
	// compute new size
	NSSize newSize = size;
	if (_forcesSuperviewWidth)
		newSize.width = maxX;
	if (_forcesSuperviewHeight)
		newSize.height = y;
	
	// apply new size
	NSWindow* window = [_view window];
	if (_forcesSuperviewWidth || _forcesSuperviewHeight)
		if (_view == [window contentView]) {
			NSRect frame = [window frame];
			NSSize oldFrameSize = frame.size;
			frame.size = [window frameRectForContentRect:NSMakeRect(NSZeroPoint, newSize)].size;
			frame.origin = frame.origin - (frame.size - oldFrameSize);
			[window setFrame:frame display:YES];
		} else
			[_view setFrameSize:newSize];
}

-(NSSize)optimalSizeForWidth:(CGFloat)width {
	NSUInteger linesCount = [_lines count];
	NSUInteger colsCount = [_columnDescriptors count];
	
	NSArray* sizesData = [self computeSizesForWidth:width];
	CGFloat colWidth[colsCount];
	for (NSUInteger i = 0; i < colsCount; ++i)
		colWidth[i] = [[[sizesData objectAtIndex:0] objectAtIndex:i] floatValue];
	NSSize sizes[linesCount][colsCount];
	CGFloat lineHeights[linesCount];
	for (NSUInteger l = 0; l < linesCount; ++l) {
		NSArray* linesizes = [[sizesData objectAtIndex:1] objectAtIndex:l];
		lineHeights[l] = 0;
		for (NSUInteger i = 0; i < colsCount; ++i) {
			sizes[l][i] = [[linesizes objectAtIndex:i] sizeValue];
			lineHeights[l] = std::max(lineHeights[l], sizes[l][i].height);
		}
	}
	
	// sum up sizes
	CGFloat y = _margin.origin.y;
	CGFloat maxX = 0;
	for (NSInteger l = linesCount-1; l >= 0; --l) {
		CGFloat x = _margin.origin.x;
		for (NSUInteger i = 0; i < colsCount; ++i)
			x += colWidth[i]+_separation.width;
		x += _margin.size.width-_margin.origin.x - _separation.width;
		
		maxX = std::max(maxX, x);
		y += lineHeights[l]+_separation.height;
	}
	y += _margin.size.height-_margin.origin.y - _separation.height;
	
	return NSMakeSize(maxX, y);
}

-(NSSize)optimalSize {
	return [self optimalSizeForWidth:CGFLOAT_MAX];
}

@end
