//
//  NSView+N2.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/11/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* N2ViewWillDeallocNotification;

@class N2LayoutManager, NSLayoutDescriptor;

@interface N2View : NSView {
	NSSize _minSize, _maxSize;
	NSMutableArray* _n2rows;
	NSUInteger _n2rowIndex;
	N2LayoutManager* _layout;
}

@property NSSize minSize, maxSize;
@property(retain) N2LayoutManager* layout;
@property(readonly) NSArray* content;

-(void)insertRow:(NSUInteger)index;
-(NSUInteger)addRow;
-(void)addDescriptor:(NSLayoutDescriptor*)descriptor;
-(NSInteger)viewRow:(NSView*)view;
-(void)setInsertRow:(NSUInteger)row;

-(void)recalculate;

@end

