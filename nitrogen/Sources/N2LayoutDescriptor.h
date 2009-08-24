//
//  NSLayoutDescriptor.h
//  Nitrogen Framework
//
//  Created by Alessandro Volz on 8/13/09.
//  Copyright 2009 OsiriX Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum N2Alignment {
	N2AlignmentLeft = 0,
	N2AlignmentCenter,
	N2AlignmentRight
};

@interface N2LayoutDescriptor : NSObject {
	N2Alignment _alignment;
}

@property N2Alignment alignment;

+(id)createWithAlignment:(N2Alignment)alignment;
-(id)initWithAlignment:(N2Alignment)alignment;

@end
