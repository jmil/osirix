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

@interface N2ColumnDescriptor : NSObject {
	N2Alignment _alignment;
	N2MinMax _widthConstraints;
}

@property N2Alignment alignment;
@property N2MinMax widthConstraints;

+(N2ColumnDescriptor*)descriptor;
+(N2ColumnDescriptor*)descriptorWithWidthConstraints:(const N2MinMax&)widthConstraints alignment:(N2Alignment)alignment;
-(N2ColumnDescriptor*)init;
-(N2ColumnDescriptor*)initWithWidthConstraints:(const N2MinMax&)widthConstraints alignment:(N2Alignment)alignment;

@end
