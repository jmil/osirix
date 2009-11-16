//
//  N2GridLayout.h
//  Nitrogen
//
//  Created by Alessandro Volz on 11.11.09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import "N2Layout.h"


@interface N2ColumnLayout : N2Layout {
	NSArray* _columnDescriptors;
	NSMutableArray* _lines;
}

-(id)initForView:(N2View*)view columnDescriptors:(NSArray*)columnDescriptors controlSize:(NSControlSize)controlSize;

-(NSArray*)lineAtIndex:(NSUInteger)index;
-(NSUInteger)appendLine:(NSArray*)views;
-(void)insertLine:(NSArray*)views atIndex:(NSUInteger)index;
-(void)removeLineAtIndex:(NSUInteger)index;
-(void)removeAllLines;


@end
