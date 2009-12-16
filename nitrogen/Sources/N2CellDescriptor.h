//
//  NSLayoutDescriptor.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/13/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "N2MinMax.h"
#import "N2Alignment.h"

@interface N2CellDescriptor : NSObject {
	NSView* _view;
	N2Alignment _alignment;
	N2MinMax _widthConstraints;
//	NSUInteger _rowSpan;
	NSUInteger _colSpan;
}

@property(retain) NSView* view;
@property N2Alignment alignment;
@property N2MinMax widthConstraints;
//@property NSUInteger rowSpan;
@property NSUInteger colSpan;

+(N2CellDescriptor*)descriptor;
+(N2CellDescriptor*)descriptorWithView:(NSView*)view;
+(N2CellDescriptor*)descriptorWithWidthConstraints:(const N2MinMax&)widthConstraints;
+(N2CellDescriptor*)descriptorWithWidthConstraints:(const N2MinMax&)widthConstraints alignment:(N2Alignment)alignment;

-(N2CellDescriptor*)view:(NSView*)view;
-(N2CellDescriptor*)alignment:(N2Alignment)alignment;
-(N2CellDescriptor*)widthConstraints:(const N2MinMax&)widthConstraints;
//-(N2CellDescriptor*)rowSpan:(NSUInteger)rowSpan;
-(N2CellDescriptor*)colSpan:(NSUInteger)colSpan;

-(NSSize)optimalSize;
-(NSSize)optimalSizeForWidth:(CGFloat)width;

#pragma mark Deprecated
-(N2CellDescriptor*)initWithWidthConstraints:(const N2MinMax&)widthConstraints alignment:(N2Alignment)alignment DEPRECATED_ATTRIBUTE;

@end

@interface N2ColumnDescriptor : N2CellDescriptor
@end
