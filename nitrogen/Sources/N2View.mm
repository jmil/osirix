//
//  NSView+N2.m
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/11/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Nitrogen/N2View.h>
#import <Nitrogen/N2LayoutManager.h>
#import <Nitrogen/N2LayoutDescriptor.h>
#import <Nitrogen/N2Operators.h>

NSString* N2ViewWillDeallocNotification = @"N2ViewWillDeallocNotification";

@implementation N2View
@synthesize minSize = _minSize, maxSize = _maxSize, layout = _layout, content = _n2rows, insertionRowIndex = _n2InsertionRowIndex;

-(id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	[self awakeFromNib];
	return self;
}

-(void)awakeFromNib {
	_n2rows = [[NSMutableArray arrayWithCapacity:4] retain];
	[self addRow];	
}

-(void)dealloc {
	[self setLayout:NULL];
	[_n2rows release];
	[super dealloc];
}

-(void)insertRow:(NSUInteger)index {
	if (index > [_n2rows count])
		[NSException raise:NSRangeException format:@"Row insertion index too high"];
	if (index < [_n2rows count] && [[_n2rows objectAtIndex:index] count] == 0)
		return;
	[_n2rows insertObject:[NSMutableArray arrayWithCapacity:4] atIndex:index];
	_n2InsertionRowIndex = index;
}

-(void)insertRow {
	[self insertRow:_n2InsertionRowIndex];
}

-(NSUInteger)addRow {
	NSUInteger index = [_n2rows count];
	if (index > 0 && [[_n2rows objectAtIndex:index-1] count] == 0)
		return _n2InsertionRowIndex = index-1;
	[self insertRow:index];
	return _n2InsertionRowIndex = index;
}

-(void)addDescriptor:(NSLayoutDescriptor*)descriptor {
	[[_n2rows objectAtIndex:_n2InsertionRowIndex] addObject:descriptor];
}

-(NSInteger)viewRow:(NSView*)view {
	for (NSUInteger i = 0; i < [_n2rows count]; ++i)
		for (id element in [_n2rows objectAtIndex:i])
			if ([element isEqual:view])
				return i;
	return -1;
}

-(void)setInsertionRowIndex:(NSUInteger)index {
	if (index >= [_n2rows count])
		[NSException raise:NSRangeException format:@"Insertion row index too high"];
	_n2InsertionRowIndex = index;
}

-(void)didAddSubview:(NSView*)view {
	[[_n2rows objectAtIndex:_n2InsertionRowIndex] addObject:view];
	if (_layout) [_layout didAddSubview:view];
//	if ([self autoresizesSubviews]) [self recalculate];
//	[super didAddSubview:view];
}

-(void)willRemoveSubview:(NSView*)view {
//	if (_layout) [_layout willRemoveSubview:view];
	NSInteger rowIndex = [self viewRow:view];
	if (rowIndex != -1) {
		[[_n2rows objectAtIndex:rowIndex] removeObject:view];
		_n2InsertionRowIndex = rowIndex;
		if ([[_n2rows objectAtIndex:rowIndex] count] == 0)
			[_n2rows removeObjectAtIndex:rowIndex];
//		if ([self autoresizesSubviews]) [self recalculate];
	}
//	[super didRemoveSubview:view];
}

-(NSUInteger)numberOfElementsInCurrentRow {
	return [[_n2rows objectAtIndex:_n2InsertionRowIndex] count];
}

-(void)recalculate {
	[self resizeSubviewsWithOldSize:[self bounds].size];
}

-(void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
	if (_layout && [[self subviews] count])
		[_layout recalculate:self];
}

@end

@implementation NSView (N2)

-(id)initWithSize:(NSSize)size {
	return [self initWithFrame:NSMakeRect(NSZeroPoint, size)];
}

@end
